//
//  ContentView.swift
//  Stride
//

import SwiftUI
import os.log

struct HomeView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var stepViewModel: StepViewModel
    @StateObject private var appearanceViewModel = AppearanceViewModel()

    @State private var showingSettings = false

    private let weeks: Int = 12
    private let log = Logger(category: "view")

//    init() {
        // _viewModel = StateObject(wrappedValue: StepViewModel(pedometerService: pedometerService))
//        _viewModel = StateObject(wrappedValue: viewModel)
        // appearance = SharedStore.loadAppearance()
//        self.viewModel = viewModel
//    }
    init(pedometerService: PedometerService) {
        _stepViewModel = StateObject(wrappedValue: StepViewModel(service: pedometerService))
    }
    

    // ================ Body ================

    var body: some View {
        Group {
            if !appearanceViewModel.isLoaded  {
                Color.blue.ignoresSafeArea()
            } else if !stepViewModel.isHealthKitAvailable {
                Text("HealthKit is not available")
            } else if stepViewModel.isAuthorizationRequested {
                mainContentView
            } else {
                // RequestAuthorizationView {
                //     stepViewModel.requestAuthorization()
                // }
                WelcomeView {
                    stepViewModel.requestAuthorization()
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            AppearanceSettingsView(appearance: $appearanceViewModel.appearance)
        }
    }
    
    // ================ UI ================
    
    private var mainContentView: some View {
        ScrollView {
            VStack(spacing: 24) {

                // -------- AppHeaderView --------

                AppHeaderView {
                    showingSettings = true
                }
                .padding(.horizontal)

                // -------- WeeklyProgressView --------

                WeeklyProgressView(
                    stepViewModel: stepViewModel,
                    appearanceViewModel: appearanceViewModel
                )
                .padding(.horizontal, 25)

                // -------- StepProgressCard --------

                StepProgressCardView(
                    steps: stepViewModel.currentSteps,
                    appearance: appearanceViewModel.appearance
                )
                .padding(.horizontal, 25)

                if stepViewModel.currentSteps == 0 {
                    dataMissingHintView
                        .padding(.horizontal, 25)
                }

                // -------- ContributionHeatmapCard --------

                StepHeatmapCard(
                    stats: stepViewModel.dailyStepCounts,
                    weeks: weeks,
                    goal: appearanceViewModel.appearance.goal
                )
                .padding(.horizontal, 25)
            }
            .padding(.vertical)
        }
        .onChange(of: scenePhase, initial: true) { old, new in
            guard new == .active else { return }
            Task { await loadMainContentData() }
        }
    }

    private var dataMissingHintView: some View {
        VStack(spacing: 12) {
            Text("🤔")
                .font(.system(size: 44))

            Text("歩数が表示されませんか？")
                .font(.callout.bold())
                .foregroundStyle(.secondary)
            
            Text("設定アプリ > ヘルスケア > データアクセスとデバイス > Stride > 歩数をオンにしてください")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 8)

            Button("設定アプリを開く") {
                openAppSettings()
            }
            .font(.subheadline)
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(.sRGB, red: 0.22, green: 0.18, blue: 0.08, opacity: 0.95),
                            Color(.sRGB, red: 0.14, green: 0.12, blue: 0.05, opacity: 0.92)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    Color(.sRGB, red: 0.45, green: 0.35, blue: 0.10, opacity: 0.35)
                )
        )
    }
    
    // ================ Private Functions ================
    
    // private func loadInitialData() async {
    //     appearance = SharedStore.loadAppearance()
    //     // await loadPermittedData()
    //     await viewModel.initializePedometer()
    // }

    private func loadMainContentData() async {
        log.tDebug("load main content data")
        // await viewModel.initializePedometer()
        // guard !stepViewModel.isHealthKitAvailable && stepViewModel.isAuthorizationRequested else { return }
        await stepViewModel.loadCurrentSteps()
        await stepViewModel.loadDailyStepCounts(weeks: weeks)
    }

    private func openAppSettings() {
        let rootSettingsURL = URL(string: "App-prefs:") ?? URL(string: "App-Prefs:")

        if let rootSettingsURL, UIApplication.shared.canOpenURL(rootSettingsURL) {
            openURL(rootSettingsURL)
            return
        }

        guard let appSettingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(appSettingsURL)
    }
}
