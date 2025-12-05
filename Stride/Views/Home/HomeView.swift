//
//  ContentView.swift
//  Stride
//

import SwiftUI
import os.log

struct HomeView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel: StepViewModel
    @State private var appearance: SharedAppearance = .default
    @State private var showingSettings = false

    private let weeks: Int = 12
    private let log = Logger(category: "view")

    init(viewModel: StepViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        appearance = SharedStore.loadAppearance()
    }

    // ================ Body ================

    var body: some View {
        Group {
            if !viewModel.isHealthKitAvailable {
                Text("HealthKit is not available")
            } else if viewModel.isAuthorizationRequested {
                mainContentView
            } else {
                requestAuthorizationView
            }
        }
        .task {
            await viewModel.initializePedometer()
        }
        .sheet(isPresented: $showingSettings) {
            AppearanceSettingsView(appearance: $appearance)
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

                // -------- StepProgressCard --------

                StepProgressCard(
                    steps: viewModel.currentSteps,
                    appearance: appearance
                )
                .padding(.horizontal, 25)

                if viewModel.currentSteps == 0 {
                    dataMissingHint
                        .padding(.horizontal, 25)
                }

                // -------- ContributionHeatmapCard --------

                StepHeatmapCard(
                    stats: viewModel.dailyStepCounts,
                    weeks: weeks,
                    goal: appearance.goal
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

    private var requestAuthorizationView: some View {
        VStack(spacing: 16) {
            Text("ヘルスケアの権限が必要です")
                .font(.title3.bold())
            Button("権限をリクエスト") {
                viewModel.requestAuthorization()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private var dataMissingHint: some View {
        VStack(spacing: 8) {
            Text("歩数が表示されませんか？")
                .font(.footnote.bold())
                .foregroundStyle(.secondary)
            
            Text("HealthKitの権限が許可されていない可能性があります。設定を確認してください。")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)

            Button("設定アプリを開く") {
                openAppSettings()
            }
            .font(.caption)
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
    
    // ================ Private Functions ================
    
    // private func loadInitialData() async {
    //     appearance = SharedStore.loadAppearance()
    //     // await loadPermittedData()
    //     await viewModel.initializePedometer()
    // }

    private func loadMainContentData() async {
        log.tDebug("load current steps")
        // await viewModel.initializePedometer()
        // guard !viewModel.isHealthKitAvailable && viewModel.isAuthorizationRequested else { return }
        viewModel.fetchCurrentSteps()
        await viewModel.ensureDailyCountsLoaded(weeks: weeks)
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(url)
    }
}
