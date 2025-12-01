import Foundation
import WidgetKit

@MainActor
final class StepViewModel: ObservableObject {
    @Published var currentSteps: Int = 0
    @Published var dailyStepCounts: [Date: Int] = [:]
    @Published var authorizationStatus: AuthorizationState = .notDetermined

    private let pedometerService: PedometerService
    private var notifObserver: NSObjectProtocol?
    private var hasLoadedDailyCounts = false

    init(pedometerService: PedometerService) {
        self.pedometerService = pedometerService
        self.currentSteps = SharedStore.loadCurrentSteps()
        
        Task { [weak self] in
            guard let self else { return }
            let state = await pedometerService.currentAuthorizationState()
            self.authorizationStatus = state
            if case .authorized = state {
                await pedometerService.ensureObserversActiveIfAuthorized()
                self.fetchCurrentSteps()
            }
        }
        
        notifObserver = NotificationCenter.default.addObserver(
                    forName: .stepsDidUpdate, object: nil, queue: .main
            ) { [weak self] note in
                guard let self else { return }
            if let steps = note.userInfo?["steps"] as? Int {
                self.currentSteps = steps
            } else {
                self.currentSteps = SharedStore.loadCurrentSteps()
            }
        }
    }
    
    deinit {
        if let o = notifObserver { NotificationCenter.default.removeObserver(o) }
    }
    
    func requestAuthorization() {
        Task {
            do {
                try await pedometerService.requestAuthorization()
                authorizationStatus = .authorized
            } catch {
                if let error = error as? PedometerServiceError, error == .healthDataUnavailable {
                    authorizationStatus = .unavailable
                } else {
                    authorizationStatus = .denied
                }
            }
        }
    }

    func fetchCurrentSteps() {
        var kind = StrideWidgetKind.kind
        pedometerService.fetchCurrentSteps { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let steps):
                    self.currentSteps = steps
                    SharedStore.saveCurrentSteps(steps)
                    WidgetCenter.shared.reloadTimelines(ofKind: kind)
                case .failure:
                    break
                }
            }
        }
    }

    func loadDailyCounts(weeks: Int) async {
        let days = weeks * 7
        let stats = await fetchDailyStepCounts(days: days)
        dailyStepCounts = stats
    }

    func ensureDailyCountsLoaded(weeks: Int) async {
        guard !hasLoadedDailyCounts else { return }
        await loadDailyCounts(weeks: weeks)
        hasLoadedDailyCounts = true
    }

    func fetchDailyStepCounts(days: Int) async -> [Date: Int] {
        do {
            return try await pedometerService.fetchDailyStepCounts(days: days)
        } catch {
            return [:]
        }
    }
}

enum AuthorizationState {
    case notDetermined
    case authorized
    case denied
    case unavailable
}
