import Foundation
import HealthKit
import WidgetKit
import os.log

enum PedometerServiceError: Error {
    case healthDataUnavailable
}

extension AuthorizationState {
    static func from(_ status: HKAuthorizationRequestStatus) -> AuthorizationState {
        switch status {
        case .unnecessary:    return .authorized
        case .shouldRequest:  return .notDetermined
        case .unknown:        return .unavailable
        @unknown default:     return .unavailable
        }
    }
}

final class PedometerService {
    private let healthStore = HKHealthStore()
    private let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    private let log = Logger(subsystem: "Stride", category: "Pedometer")

    // ================ Authorization ================
    
    func currentAuthorizationState() async -> AuthorizationState {
        guard HKHealthStore.isHealthDataAvailable() else { return .unavailable }
        return await withCheckedContinuation { cont in
            healthStore.getRequestStatusForAuthorization(toShare: [], read: [stepType]) { status, _ in
                cont.resume(returning: AuthorizationState.from(status))
            }
        }
    }
    
    func ensureObserversActiveIfAuthorized() async {
        let state = await currentAuthorizationState()
        guard case .authorized = state else { return }
        do {
            try await enableBackgroundDelivery()
            startStepObserver()
        } catch {
            log.error("ensureObserversActiveIfAuthorized: \(error.localizedDescription, privacy: .public)")
        }
    }

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw PedometerServiceError.healthDataUnavailable
        }
        try await healthStore.requestAuthorization(toShare: [], read: [stepType])
        try await enableBackgroundDelivery()
        startStepObserver()
    }

    // ================ Background Delovery ================

    private func enableBackgroundDelivery() async throws {
        log.debug("enableBackgroundDelivery: start")
        try await withCheckedThrowingContinuation {(cont: CheckedContinuation<Void, Error>) in
            healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate) { success, error in
                if let error = error {
                    self.log.error("enableBackgroundDelivery: error \(error.localizedDescription, privacy: .public)")
                    cont.resume(throwing: error)
                } else if success {
                    self.log.debug("enableBackgroundDelivery: success")
                    cont.resume(returning: ())
                } else {
                    self.log.error("enableBackgroundDelivery: failed with success=false")
                    cont.resume(throwing: NSError(domain: "HK", code: -1))
                }
            }
        }
    }

    private func startStepObserver() {
        log.debug("startStepObserver: registering observer")
        let query = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, completion, error in
            guard let self else { completion(); return }
            if let error {
                self.log.error("HKObserverQuery error: \(error.localizedDescription, privacy: .public)")
                completion()
                return
            }
            self.log.debug("Pedometer 0000")
            self.updateData {completion()}
        }
        healthStore.execute(query)
    }

    private func updateData(_ done: @escaping () -> Void) {
        log.debug("Pedometer 1111")
        fetchCurrentSteps { result in
            self.log.debug("Pedometer 2222")
            if case let .success(steps) = result {
                self.log.debug("Pedometer 3333")
                SharedStore.saveCurrentSteps(steps)
            }
            done()
        }
    }
    
    // ================ Fetching Data ================

    func fetchCurrentSteps(handler: @escaping (Result<Int, Error>) -> Void) {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            if let error = error {
                handler(.failure(error))
                return
            }
            guard let quantity = result?.sumQuantity() else {
                handler(.success(0))
                return
            }
            let steps = Int(quantity.doubleValue(for: .count()))
            handler(.success(steps))
        }
        healthStore.execute(query)
    }

    func fetchDailyStepCounts(days: Int, calendar: Calendar = .current) async throws -> [Date: Int] {
        let end = calendar.startOfDay(for: Date())
        let start = calendar.date(byAdding: .day, value: -(days - 1), to: end)!  // 例: days=84なら84日分
        let interval = DateComponents(day: 1)
        let anchor = end

        return try await withCheckedThrowingContinuation {(cont: CheckedContinuation<[Date: Int], Error>) in
            let query = HKStatisticsCollectionQuery(
                quantityType: stepType,
                quantitySamplePredicate: nil,
                options: .cumulativeSum,
                anchorDate: anchor,
                intervalComponents: interval
            )
            query.initialResultsHandler = { _, collection, error in
                if let error = error { return cont.resume(throwing: error) }
                guard let collection else { return cont.resume(returning: [:]) }

                var result: [Date: Int] = [:]
                collection.enumerateStatistics(from: start, to: end) { stats, _ in
                    let day = calendar.startOfDay(for: stats.startDate)
                    let count = Int(stats.sumQuantity()?.doubleValue(for: .count()) ?? 0)
                    result[day] = count
                }
                cont.resume(returning: result)
            }
            self.healthStore.execute(query)
        }
    }
}
