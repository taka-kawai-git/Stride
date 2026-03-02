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

    @Binding var showOneYearView: Bool

    private let displayWeeks: Int = 12
    private let fetchWeeks: Int = 52
    private let log = Logger(category: "view")

    // -------- init --------

    init(stepViewModel: StepViewModel, appearanceViewModel: AppearanceViewModel, showOneYearView: Binding<Bool>, onGoalTap: (() -> Void)? = nil) {
        self.stepViewModel = stepViewModel
        self.appearanceViewModel = appearanceViewModel
        self._showOneYearView = showOneYearView
        self.onGoalTap = onGoalTap
    }
    
    // -------- body --------

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
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
                        image: progressIcon,
                        iconScale: 0.9,
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
                    weeks: displayWeeks,
                    goal: appearanceViewModel.appearance.goal
                )
                .padding(.horizontal, 25)

                // -------- OneYear Link Card --------

                Button {
                    showOneYearView = true
                } label: {
                    Card {
                        HStack {
                            Image(systemName: "lock.fill")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("過去1年のアクティビティを見る")
                                .font(.subheadline.bold())
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(10)
                    }
                }
                .buttonStyle(.plain)
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


    private var progressIcon: Image {
        let progress = stepProgressRate(steps: stepViewModel.currentSteps, goal: appearanceViewModel.appearance.goal)
        switch progress {
        case ..<0.25:
            return Image("ThinkingFace")
        case 0.25..<0.5:
            return Image("ThumbsUp")
        case 0.5..<0.75:
            return Image("Trophy")
        default:
            return Image("PartyPopper")
        }
    }

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
        await stepViewModel.loadDailyStepCounts(weeks: fetchWeeks)
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
