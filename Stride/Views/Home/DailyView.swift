//
//  ContentView.swift
//  Stride
//

import SwiftUI
import os.log

struct DailyView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var colorScheme

    @ObservedObject var stepViewModel: StepViewModel
    @ObservedObject var appearanceViewModel: AppearanceViewModel

    private let weeks: Int = 12
    private let log = Logger(category: "view")

    init(stepViewModel: StepViewModel, appearanceViewModel: AppearanceViewModel) {
        self.stepViewModel = stepViewModel
        self.appearanceViewModel = appearanceViewModel
    }
    

    // ================ Body ================

    var body: some View {
        mainContentView
    }
    
    // ================ UI ================
    
    private var mainContentView: some View {
        ScrollView {
            VStack(spacing: 24) {

                // -------- StepProgressCard --------

                VStack(spacing: 0) {
                    Text("今日")
                        .font(.system(size: 24, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 25)

                    CommonProgressView(
                        steps: stepViewModel.currentSteps,
                        goal: appearanceViewModel.appearance.goal,
                        gradientID: appearanceViewModel.appearance.gradientID,
                        image: Image("ThumbsUp")
                    )
                    .padding(.horizontal, 50)
                }

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
                .foregroundStyle(colorScheme == .dark ? AnyShapeStyle(.secondary) : AnyShapeStyle(Color.black))
            
            Text("設定アプリ > ヘルスケア > データアクセスとデバイス > Stride > 歩数をオンにしてください")
                .font(.caption2)
                .foregroundStyle(colorScheme == .dark ? AnyShapeStyle(.tertiary) : AnyShapeStyle(Color.black))
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
                        colors: colorScheme == .dark ? [
                            Color(.sRGB, red: 0.22, green: 0.18, blue: 0.08, opacity: 0.95),
                            Color(.sRGB, red: 0.14, green: 0.12, blue: 0.05, opacity: 0.92)
                        ] : [
                            Color(.sRGB, red: 1.0, green: 0.98, blue: 0.90, opacity: 1),
                            Color(.sRGB, red: 1.0, green: 0.95, blue: 0.80, opacity: 1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    colorScheme == .dark
                        ? Color(.sRGB, red: 0.45, green: 0.35, blue: 0.10, opacity: 0.35)
                        : Color(.sRGB, red: 1.0, green: 0.8, blue: 0.4, opacity: 0.2)
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
