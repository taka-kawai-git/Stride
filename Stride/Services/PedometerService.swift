import Foundation
import HealthKit
import os.log

enum PedometerServiceError: Error {
    case healthDataUnavailable
    // case authorizationDenied
}

actor PedometerService {
    // private let healthStore = HKHealthStore()
    private lazy var healthStore = HKHealthStore() 
    private let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    private var activeObserverQuery: HKObserverQuery?
    private var backgroundStepUpdateHandler: ((Int) async -> Void)?

    private let log = Logger(category: "service")

    func configure(backgroundStepUpdateHandler: @escaping (Int) async -> Void) {
        self.backgroundStepUpdateHandler = backgroundStepUpdateHandler
    }

    // ================ Health Data Availability ================

    func isHealthDataAvailable() ->  Bool {
        return HKHealthStore.isHealthDataAvailable() 
    }

    // ================ Request Autorization ================

    func requestAuthorization() async throws {
        // guard HKHealthStore.isHealthDataAvailable() else {
        //     throw PedometerServiceError.healthDataUnavailable
        // }
        try await healthStore.requestAuthorization(toShare: [], read: [stepType])

        // let status = await readAuthorizationRequestStatus()
        // guard case .unnecessary = status else {
        //     throw PedometerServiceError.authorizationDenied
        // }

        try await enableBackgroundDelivery()
    }

    func authorizationRequestStatus() async -> HKAuthorizationRequestStatus {
        await withCheckedContinuation { cont in
            healthStore.getRequestStatusForAuthorization(toShare: [], read: [stepType]) { status, _ in
                cont.resume(returning: status)
            }
        }
    }

    func ensureBackgroundDeliveryEnabled() async {
        do {
            try await enableBackgroundDelivery()
        } catch {
            log.tError("Failed to enableBackgroundDelivery: \(error.localizedDescription)")
        }
    }

    // ================ Background Delivery ================

    private func enableBackgroundDelivery() async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate) { success, error in
                if let error { return cont.resume(throwing: error) }
                guard success else { return cont.resume(throwing: NSError(domain: "HK", code: -1)) }
                cont.resume(returning: ())
            }
        }
    }

     // ================ Observer ================

    func observeCurrentSteps() -> AsyncThrowingStream<Int, Error> {
        AsyncThrowingStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            Task { [weak self] in
                guard let self else { return }
                do {

                    // -------- Fetch initial steps --------

                    let initialSteps = try await self.fetchCurrentStepsOnce()
                    await self.backgroundStepUpdateHandler?(initialSteps)
                    continuation.yield(initialSteps)
                    
                    // -------- Setup Observer --------

                    try await self.startObserver(continuation)
                } catch {
                    continuation.finish(throwing: error)
                }
            }

            // -------- Terminate observer --------

            continuation.onTermination = { @Sendable [weak self] _ in
                Task { await self?.stopObserver() }
            }
        }
    }

    private func startObserver(_ continuation: AsyncThrowingStream<Int, Error>.Continuation) async throws {
        // guard activeObserverQuery == nil else { return }
        if let q = activeObserverQuery {
            healthStore.stop(q)
            activeObserverQuery = nil
        }

        let query = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, completion, error in
            guard let self else { completion(); return }
            if let error {
                continuation.finish(throwing: error)
                completion()
                return
            }
            Task {
                do {
                    let steps = try await self.fetchCurrentStepsOnce()
                    await self.backgroundStepUpdateHandler?(steps)
                    self.log.tDebug("HKObserverQuery fetched steps: \(steps) steps")
                    continuation.yield(steps)
                } catch {
                    continuation.finish(throwing: error)
                }
                completion()
            }
        }
        healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate) { _, _ in }
        activeObserverQuery = query
        healthStore.execute(query)
        log.tDebug("Executed ObserverQuery for CurrentSteps")
    }

    private func stopObserver() {
        if let q = activeObserverQuery {
            healthStore.stop(q)
            activeObserverQuery = nil
        }
    }

    func fetchCurrentStepsOnce() async throws -> Int {
        try await withCheckedThrowingContinuation { cont in
            let now = Date()
            let startOfDay = Calendar.current.startOfDay(for: now)
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

            let q = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                if let error { return cont.resume(throwing: error) }
                let steps = Int(result?.sumQuantity()?.doubleValue(for: .count()) ?? 0)
                self.log.tDebug("HKOStatisticQuery fetched steps: \(steps) steps")
                cont.resume(returning: steps)
            }
            log.tDebug("Executed StatisticsQuery for CurrentSteps")
            self.healthStore.execute(q)
        }
    }

    // ================ Fetch Daily Step Counts ================

    func fetchDailyStepCounts(days: Int, calendar: Calendar = .current) async throws -> [Date: Int] {
        let end = calendar.startOfDay(for: Date())
        let start = calendar.date(byAdding: .day, value: -(days - 1), to: end)!
        let interval = DateComponents(day: 1)
        let anchor = end

        return try await withCheckedThrowingContinuation { (cont: CheckedContinuation<[Date: Int], Error>) in
            let q = HKStatisticsCollectionQuery(quantityType: stepType,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchor,
                                                intervalComponents: interval)
            q.initialResultsHandler = { _, collection, error in
                if let error { return cont.resume(throwing: error) }
                guard let collection else { return cont.resume(returning: [:]) }

                var result: [Date: Int] = [:]
                collection.enumerateStatistics(from: start, to: end) { stats, _ in
                    let day = calendar.startOfDay(for: stats.startDate)
                    let count = Int(stats.sumQuantity()?.doubleValue(for: .count()) ?? 0)
                    result[day] = count
                }
                cont.resume(returning: result)
            }
            log.tDebug("Executed StatisticsCollectionQuery for DailyStepCounts")
            self.healthStore.execute(q)
        }
    }
}
