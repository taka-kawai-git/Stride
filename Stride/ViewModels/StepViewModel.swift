import Foundation
import WidgetKit
import os.log

@MainActor
final class StepViewModel: ObservableObject {
    @Published var currentSteps: Int = 0
    @Published var dailyStepCounts: [Date: Int] = [:]
    @Published var isAuthorizationRequested = false
    @Published var isHealthKitAvailable = true
    @Published var isInitialDataLoaded = false

    private let pedometerService: PedometerService
    private var stepUpdatesTask: Task<Void, Never>?
    
    private var lastSavedSteps: Int = 0
    private var lastSavedDate: Date = .distantPast

    private let log = Logger(category: "model")

    // ---------------- init ----------------

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
            startObserveStepUpdates()
        }
    }
    
    deinit {
        stepUpdatesTask?.cancel()
    }

    // ---------------- Auth ----------------
    
     func requestAuthorization() {
        Task {
            do {
                try await pedometerService.requestAuthorization()
                SharedStore.saveDidRequestAuthorization(true)
                self.isAuthorizationRequested = true
                startObserveStepUpdates()
            } catch {
                if let error = error as? PedometerServiceError, error == .healthDataUnavailable {
                    self.isHealthKitAvailable = false
                } else {
                    log.tError("Request error, but HealthKit is available")
                }
            }
        }
    }

    // ---------------- Fetching Data ----------------

    func loadCurrentSteps() async {
        do {
            let steps = try await pedometerService.fetchCurrentStepsOnce()
            self.currentSteps = steps
            await StepBackgroundManager.shared.handleStepUpdate(steps: steps)
        } catch {
            self.currentSteps = 0
            SharedStore.saveCurrentSteps(0)
            log.tError("Failed to fetch steps: \(error)")
        }
    }

    func loadDailyStepCounts(weeks: Int) async {
        let days = weeks * 7
        do {
            let stats = try await pedometerService.fetchDailyStepCounts(days: days)
            dailyStepCounts = stats
        } catch {
            dailyStepCounts = [:]
        }
    }


    // ======================================== Private Functions ========================================

    
    private func startObserveStepUpdates() {
        stepUpdatesTask?.cancel()
        stepUpdatesTask = nil
        
        stepUpdatesTask = Task { [weak self] in
            guard let self else { return }
            do {
                for try await steps in await pedometerService.observeCurrentSteps() {
                    self.currentSteps = steps
                    await StepBackgroundManager.shared.handleStepUpdate(steps: steps)
                }
            } catch {
                if !(error is CancellationError) {
                    self.currentSteps = 0
                    SharedStore.saveCurrentSteps(0)
                    log.tError("Step update stream error: \(error)")
                }
            }
        }
    }

    // enum RequestState {
    //     case shouldRequest
    //     case unnecessary
    //     case unknown
    // }
}
