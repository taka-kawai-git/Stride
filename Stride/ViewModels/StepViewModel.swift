import Foundation
import WidgetKit
import os.log


@MainActor
final class StepViewModel: ObservableObject {
    @Published var currentSteps: Int = 0
    @Published var dailyStepCounts: [Date: Int] = [:]
    // @Published var requestState: RequestState = .shouldRequest
    @Published var isAuthorizationRequested = false
    @Published var isHealthKitAvailable = true

    private let pedometerService: PedometerService
    private var stepUpdatesTask: Task<Void, Never>?
    private var isInitialized = false 
    
    private var isLoadingDailyCounts = false
    private var hasLoadedDailyCounts = false
    
    
    private var lastSavedSteps: Int = 0
    private var lastSavedDate: Date = .distantPast

    private let log = Logger(category: "model")

    // ================ init ================

    init(pedometerService: PedometerService) {
        self.pedometerService = pedometerService

        let initialStep = SharedStore.loadCurrentSteps()
        self.currentSteps = initialStep
        self.lastSavedSteps = initialStep
        self.isAuthorizationRequested = SharedStore.hasRequestedAuthorization()

        // memo: use SharedStore?
        Task {
            self.isHealthKitAvailable = await pedometerService.isHealthDataAvailable()
        }        

        // Task { [weak self] in
        //     guard let self else { return }
        //     await pedometerService.ensureBackgroundDeliveryEnabled()
        //     self.startStepUpdates()
        // }

        // Task { [weak self] in
        //     await self?.initializePedometer()
        // }
    }

    func initializePedometer() async {
        guard !isInitialized else { return }
        isInitialized = true

        // Task { [weak self] in
        //     guard let self else { return }
        //     let state = await pedometerService.readAuthorizationRequestStatus()
        //     self.requestState = state
        //     if case .unnecessary = state {
        //         await pedometerService.ensureObserversActive()
        //         self.fetchCurrentSteps()
        //     }
        // }
        
        await pedometerService.ensureBackgroundDeliveryEnabled()
        startStepUpdates()
    }
    
    deinit {
        stepUpdatesTask?.cancel()
    }

    // ================ Auth ================
    
     func requestAuthorization() {
        Task {
            do {
                try await pedometerService.requestAuthorization()
                SharedStore.saveDidRequestAuthorization(true)
                self.isAuthorizationRequested = true
                // requestState = .unnecessary
                startStepUpdates()
            } catch {
                if let error = error as? PedometerServiceError, error == .healthDataUnavailable {
                    // requestState = .unavailable
                    self.isHealthKitAvailable = false
                } else {
                    log.tError("Request error, but HealthKit is available")
                }
            }
        }
    }

    // ================ Fetching Data ================

    func fetchCurrentSteps() {
        Task { [weak self] in
            guard let self else { return }
            do {
                let steps = try await pedometerService.fetchCurrentStepsOnce()
                // requestState = .unnecessary
                updateStepsAndSyncIfNeeded(steps: steps, forceSync: true)
            } catch {
                // requestState = .shouldRequest
                log.tError("Failed to fetch steps: \(error)")
            }
        }
    }

    func ensureDailyCountsLoaded(weeks: Int) async {
        guard !hasLoadedDailyCounts && !isLoadingDailyCounts else { return }
        
        isLoadingDailyCounts = true
        defer { isLoadingDailyCounts = false }
        
        await loadDailyCounts(weeks: weeks)
        hasLoadedDailyCounts = true
    }

    // ================ Private Functions ================

    private func fetchDailyStepCounts(days: Int) async -> [Date: Int] {
        do {
            return try await pedometerService.fetchDailyStepCounts(days: days)
        } catch {
            return [:]
        }
    }

    private func loadDailyCounts(weeks: Int) async {
        let days = weeks * 7
        let stats = await fetchDailyStepCounts(days: days)
        dailyStepCounts = stats
    }

    private func startStepUpdates() {
        stepUpdatesTask?.cancel()
        stepUpdatesTask = Task { [weak self] in
            guard let self else { return }
            do {
                for try await steps in await pedometerService.stepUpdates() {
                    await MainActor.run {
                        // self.requestState = .unnecessary
                        self.currentSteps = steps
                        SharedStore.saveCurrentSteps(steps)
                        WidgetCenter.shared.reloadTimelines(ofKind: StrideWidgetKind.kind)
                    }
                }
            } catch {
                if !(error is CancellationError) {
                    log.tError("Step update stream error: \(error)")
                }
                // await MainActor.run {
                //     self.requestState = .shouldRequest
                // }
            }
        }
    }

    private func updateStepsAndSyncIfNeeded(steps: Int, forceSync: Bool) {
    // 1. UI用変数は即時更新（アプリの見た目はリアルタイムに）
        self.currentSteps = steps

        // 2. ディスク保存とWidget更新の条件チェック
        let stepDiff = abs(steps - lastSavedSteps)
        let timeInterval = Date().timeIntervalSince(lastSavedDate)

        // 「値が大きく変わった(50歩以上)」 または 「前回保存から時間が経った(5分以上)」 または 「強制更新」
        // ※HealthKit利用で頻度が低いなら、stepDiffの条件はもっと小さくても良い（例: 1歩でも変われば更新など）
        if forceSync || stepDiff >= 50 || timeInterval > 300 {
            
            SharedStore.saveCurrentSteps(steps)
            
            // Widget更新は特に慎重に行う（Budget節約）
            WidgetCenter.shared.reloadTimelines(ofKind: StrideWidgetKind.kind)
            
            lastSavedDate = Date()
            lastSavedSteps = steps
            print("Synced steps: \(steps)")
        }
    }

    enum RequestState {
        case shouldRequest
        case unnecessary
        case unknown
    }
}
