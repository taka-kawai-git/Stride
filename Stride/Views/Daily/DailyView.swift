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
    var onGoalTap: (() -> Void)? = nil

    private let weeks: Int = 12
    private let log = Logger(category: "view")

    // -------- init --------

    init(stepViewModel: StepViewModel, appearanceViewModel: AppearanceViewModel, onGoalTap: (() -> Void)? = nil) {
        self.stepViewModel = stepViewModel
        self.appearanceViewModel = appearanceViewModel
        self.onGoalTap = onGoalTap
    }
    
    // -------- body --------

    var body: some View {
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
                        image: Image("ThumbsUp"),
                        onGoalTap: onGoalTap
                    )
                    .padding(.horizontal, 50)
                }

                // -------- if data is missing, show HintView --------

                if stepViewModel.currentSteps == 0 {
                    dataMissingHintView
                        .padding(.horizontal, 25)
                }

                // -------- HeatmapCard --------

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


    // ======================================== Private Functions ========================================


    private var dataMissingHintView: some View {
        VStack(spacing: 12) {
            Text("🤔")
                .font(.system(size: 44))

            Text("歩数が表示されませんか？")
                .font(.callout.bold())
                .foregroundStyle(colorScheme == .dark ? AnyShapeStyle(.secondary) : AnyShapeStyle(Color.black))
            
            Text("設定アプリ > アプリ（iOS18以上） > ヘルスケア > データアクセスとデバイス > Stride > 歩数をオンにしてください")
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
                        colors: AppColors.dataMissingGradientColors(for: colorScheme),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppColors.dataMissingStrokeColor(for: colorScheme))
        )
    }
    
    private func loadMainContentData() async {
        log.tDebug("load main content data")
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
