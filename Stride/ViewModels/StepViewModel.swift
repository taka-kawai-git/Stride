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
    @Published var isInitialDataLoaded = false

    private let pedometerService: PedometerService
    private var stepUpdatesTask: Task<Void, Never>?
    // private var isInitialized = false 
    
    // private var isLoadingDailyCounts = false
    // private var hasLoadedDailyCounts = false
    
    private var lastSavedSteps: Int = 0
    private var lastSavedDate: Date = .distantPast

    private let log = Logger(category: "model")

    // ================ init ================

     init(service: PedometerService) {
        self.pedometerService = service

        let initialStep = SharedStore.loadCurrentSteps()
        self.currentSteps = initialStep
        self.lastSavedSteps = initialStep
        self.isAuthorizationRequested = SharedStore.hasRequestedAuthorization()

        // memo: use SharedStore?
        Task {
            self.isHealthKitAvailable = await pedometerService.isHealthDataAvailable()
            await pedometerService.ensureBackgroundDeliveryEnabled()
        }

        if self.isAuthorizationRequested {
            startStepUpdates()
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

    // func loadInitialData() async {
    //     guard !isInitialDataLoaded else { return }
        
        // 1. UserDefaults等はここで非同期的に読む（メインスレッドをブロックしない）
        // let savedSteps = SharedStore.loadCurrentSteps()
        // let hasRequested = SharedStore.hasRequestedAuthorization()
        
        // 2. HealthKitの可用性チェック
        // let isAvailable = await pedometerService.isHealthDataAvailable()
        
        // 3. UIへの反映（MainActorなので安全）
        // self.currentSteps = savedSteps
        // self.lastSavedSteps = savedSteps
        // self.isAuthorizationRequested = hasRequested
        // self.isHealthKitAvailable = isAvailable
        
        // 4. バックグラウンド配信の確認と更新開始
    //     if isAvailable && hasRequested {
    //         Task {
    //             await pedometerService.ensureBackgroundDeliveryEnabled()
    //             startStepUpdates()
    //         }
    //     }
        
    //     self.isInitialDataLoaded = true
    // }

    // func initializePedometer() async {
    //     guard !isInitialized else { return }
    //     isInitialized = true

    //     // Task { [weak self] in
    //     //     guard let self else { return }
    //     //     let state = await pedometerService.readAuthorizationRequestStatus()
    //     //     self.requestState = state
    //     //     if case .unnecessary = state {
    //     //         await pedometerService.ensureObserversActive()
    //     //         self.fetchCurrentSteps()
    //     //     }
    //     // }
        
    //     await pedometerService.ensureBackgroundDeliveryEnabled()
    //     startStepUpdates()
    // }
    
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

    func loadCurrentSteps() async {
        // Task { [weak self] in
        //     guard let self else { return }
            do {
                let steps = try await pedometerService.fetchCurrentStepsOnce()
                // requestState = .unnecessary
                // updateStepsAndSyncIfNeeded(steps: steps, forceSync: true)
                self.currentSteps = steps
            } catch {
                // requestState = .shouldRequest
                log.tError("Failed to fetch steps: \(error)")
            }
        // }
    }

    // func ensureDailyCountsLoaded(weeks: Int) async {
    //     guard !hasLoadedDailyCounts && !isLoadingDailyCounts else { return }
        
    //     isLoadingDailyCounts = true
    //     defer { isLoadingDailyCounts = false }
        
    //     await loadDailyStepCounts(weeks: weeks)
    //     hasLoadedDailyCounts = true
    // }

    func loadDailyStepCounts(weeks: Int) async {
        let days = weeks * 7
        do {
            let stats = try await pedometerService.fetchDailyStepCounts(days: days)
            dailyStepCounts = stats
        } catch {
            dailyStepCounts = [:]
        }
    }

    // ================ Private Functions ================

    // private func loadDailyCounts(weeks: Int) async {
    //     let stats = await fetchDailyStepCounts(weeks: weeks)
    //     dailyStepCounts = stats
    // }

    private func startStepUpdates() {
        stepUpdatesTask?.cancel()
        stepUpdatesTask = nil
        
        stepUpdatesTask = Task { [weak self] in
            guard let self else { return }
            do {
                for try await steps in await pedometerService.stepUpdates() {
                    // await MainActor.run {
                    //     // self.requestState = .unnecessary
                    //     // self.currentSteps = steps
                    //     // SharedStore.saveCurrentSteps(steps)
                    //     // WidgetCenter.shared.reloadTimelines(ofKind: StrideWidgetKind.kind)
                    //     self.updateStepsAndSyncIfNeeded(steps: steps, forceSync: false)
                    // }
                    self.currentSteps = steps
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

    // private func updateStepsAndSyncIfNeeded(steps: Int, forceSync: Bool) {
    // // 1. UI用変数は即時更新（アプリの見た目はリアルタイムに）
    //     self.currentSteps = steps

    //     // 2. ディスク保存とWidget更新の条件チェック
    //     let stepDiff = abs(steps - lastSavedSteps)
    //     let timeInterval = Date().timeIntervalSince(lastSavedDate)

    //     // 「値が大きく変わった(50歩以上)」 または 「前回保存から時間が経った(5分以上)」 または 「強制更新」
    //     // ※HealthKit利用で頻度が低いなら、stepDiffの条件はもっと小さくても良い（例: 1歩でも変われば更新など）
    //     if forceSync || stepDiff >= 50 || timeInterval > 300 {
            
    //         SharedStore.saveCurrentSteps(steps)
            
    //         // Widget更新は特に慎重に行う（Budget節約）
    //         WidgetCenter.shared.reloadTimelines(ofKind: StrideWidgetKind.kind)
            
    //         lastSavedDate = Date()
    //         lastSavedSteps = steps
    //         print("Synced steps: \(steps)")
    //     }
    // }

    enum RequestState {
        case shouldRequest
        case unnecessary
        case unknown
    }
}
