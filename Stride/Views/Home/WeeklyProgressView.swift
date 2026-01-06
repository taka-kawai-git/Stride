//
//  WeeklyProgressView.swift
//  Stride
//

import SwiftUI

struct WeeklyProgressView: View {
    @ObservedObject var stepViewModel: StepViewModel
    @ObservedObject var appearanceViewModel: AppearanceViewModel
    @StateObject private var weeklyViewModel = WeeklyProgressViewModel()
    @State private var showingInfo = false

    private var percentageFont: Font {
        .custom("AvenirNext-Bold", size: 40)
    }

    private var percentageSymbolFont: Font {
        .custom("AvenirNext-Bold", size: 24)
    }

    var body: some View {
        let weekly: WeeklyProgressViewModel.WeeklyProgress = weeklyViewModel.weeklyProgress
        let percentageValue = Int((weekly.clampedProgress * 100).rounded())

        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly")
                .font(.title2.weight(.bold))

            HStack(alignment: .center, spacing: 18) {
                WeeklyProgressIconView(
                    gradientID: appearanceViewModel.appearance.gradientID
                )

                VStack(alignment: .leading, spacing: -5) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {

                        weeklyPercentage(percentageValue: percentageValue)
                        
                        Spacer()
                        
                        info()
                    }

                    weeklyStepsAndGoal(weekly: weekly)
                    
                    weeklyProgressBar(progress: weekly.clampedProgress)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
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

    private func weeklyPercentage(percentageValue: Int) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text("\(percentageValue)")
                .font(percentageFont)

            Text("%")
                .font(percentageSymbolFont)
        }
        .alignmentGuide(.firstTextBaseline) { d in d[.top] }
    }

    private func info() -> some View {
        Button {
            showingInfo = true
        } label: {
            Image(systemName: "info.circle")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
        .buttonStyle(.plain)
        .alignmentGuide(.firstTextBaseline) { d in d[.top] }
        .popover(
            isPresented: $showingInfo,
            attachmentAnchor: .rect(.bounds),
            arrowEdge: .top
        ) {

        Text("月曜~現在までの合計歩数を週の目標歩数(1日の目標歩数×7)で割った数値が表示されます")
            .font(.footnote)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .presentationCompactAdaptation(.none)
            .padding(15)
            .frame(maxWidth: 260, alignment: .leading)
        }
    }

    private func weeklyStepsAndGoal(weekly:WeeklyProgressViewModel.WeeklyProgress) -> some View {
         HStack(spacing: 0) {
            Text("\(weekly.totalSteps.formatted()) / \(weekly.targetSteps.formatted()) 歩")
                .font(.custom("AvenirNext-DemiBold", size: 15))
                .foregroundStyle(.secondary)
        }
        .padding(.bottom, 20)
    }

    private func weeklyProgressBar(progress: Double) -> some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.15))
                Capsule()
                    .fill(gradient(for: appearanceViewModel.appearance.gradientID))
                    .frame(width: proxy.size.width * progress)
            }
        }
        .frame(height: 14)
    }
}
