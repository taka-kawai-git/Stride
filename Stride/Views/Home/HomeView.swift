//
//  ContentView.swift
//  Stride
//

import SwiftUI
import os.log


struct HomeView: View {
    @Environment(\.openURL) private var openURL
    @StateObject private var viewModel: StepViewModel
    @State private var appearance: SharedAppearance = .default
    @State private var showingSettings = false
    private let weeks: Int = 12
    private let log = Logger(subsystem: "Stride", category: "HomeView")

    init(viewModel: StepViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // ================ Body ================

    var body: some View {
        Group {
            switch viewModel.requestState {
            case .unnecessary:
                mainContent
            case .shouldRequest:
                authorizationPrompt
            case .unknown, .unavailable:
                Text("Undefined")
            }
        }
        .task {
            await loadInitialData()
        }
        .onChange(of: viewModel.requestState) { status in
            guard case .unnecessary = status else { return }
            Task { await loadPermittedData() }
        }
        .sheet(isPresented: $showingSettings) {
            AppearanceSettingsView(appearance: $appearance)
        }
    }
    
    // ================ UI ================
    
    private var mainContent: some View {
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
    }

    private var authorizationPrompt: some View {
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
    
    private func loadInitialData() async {
        appearance = SharedStore.loadAppearance()
        await loadPermittedData()
    }

    private func loadPermittedData() async {
        guard case .unnecessary = viewModel.requestState else { return }
        viewModel.fetchCurrentSteps()
        await viewModel.ensureDailyCountsLoaded(weeks: weeks)
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(url)
    }
}
