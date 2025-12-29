//
//  WeeklyProgressView.swift
//  Stride
//

import SwiftUI

struct WeeklyProgressView: View {
    @ObservedObject var stepViewModel: StepViewModel
    @ObservedObject var appearanceViewModel: AppearanceViewModel
    @StateObject private var weeklyViewModel = WeeklyProgressViewModel()

    private var percentageFont: Font {
        .custom("AvenirNext-Bold", size: 40)
    }

    private var percentageSymbolFont: Font {
        .custom("AvenirNext-Bold", size: 24)
    }

    var body: some View {
        let weekly = weeklyViewModel.weeklyProgress
        let percentageValue = Int((weekly.clampedProgress * 100).rounded())

        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly")
                .font(.title2.weight(.bold))

            HStack(alignment: .center, spacing: 18) {
                WeeklyProgressIconView(
                    gradientID: appearanceViewModel.appearance.gradientID
                )

                VStack(alignment: .leading, spacing: -5) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(percentageValue)")
                            .font(percentageFont)

                        Text("%")
                            .font(percentageSymbolFont)
                    }

                    Text("\(weekly.totalSteps.formatted()) / \(weekly.targetSteps.formatted()) 歩")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 20)

                    progressBar(progress: weekly.clampedProgress)
                        .frame(height: 14)
                }

                Spacer()
            }
        }
        .onAppear(perform: refresh)
        .onChange(of: stepViewModel.dailyStepCounts) { _ in refresh() }
        .onChange(of: appearanceViewModel.appearance.goal) { _ in refresh() }
    }

    private func refresh() {
        weeklyViewModel.update(
            dailyCounts: stepViewModel.dailyStepCounts,
            goal: appearanceViewModel.appearance.goal
        )
    }

    private func progressBar(progress: Double) -> some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.15))
                Capsule()
                    .fill(gradient(for: appearanceViewModel.appearance.gradientID))
                    .frame(width: proxy.size.width * progress)
            }
        }
    }
}
