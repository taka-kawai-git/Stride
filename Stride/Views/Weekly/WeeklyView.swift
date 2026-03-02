//
//  HistoryView.swift
//  Stride
//

import SwiftUI

struct WeeklyView: View {
    @ObservedObject var stepViewModel: StepViewModel
    @ObservedObject var appearanceViewModel: AppearanceViewModel
    var onGoalTap: (() -> Void)? = nil
    @Binding var showOneYearView: Bool
    @StateObject private var weeklyViewModel = WeeklyProgressViewModel()

    // -------- Body --------
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                
                // -------- WeeklyProgressView --------

                VStack(spacing: 0) {
                    HStack {
                        Text("今週")
                            .font(.system(size: 24, weight: .bold))
                        
                        Spacer()
                        
                        WeeklyInfoButton()
                    }
                    .padding(.horizontal, 25)

                    CommonProgressView(
                        steps: weeklyViewModel.weeklyProgress.totalSteps,
                        goal: weeklyViewModel.weeklyProgress.targetSteps,
                        gradientID: appearanceViewModel.appearance.gradientID,
                        image: progressIcon,
                        onGoalTap: onGoalTap
                    )
                    .padding(.horizontal, 50)
                }

                // -------- PastWeeklyProgressView --------

                Card {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("過去12週")
                            .font(.system(size: 22, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 10)
                            .padding(.top, 10)

                        PastWeeklyProgressView(
                            stepViewModel: stepViewModel,
                            appearanceViewModel: appearanceViewModel,
                            weeks: 12
                        )
                    }
                }
                .padding(.horizontal, 25)

                // -------- OneYear Link Card --------

                Button {
                    showOneYearView = true
                } label: {
                    Card {
                        HStack {
                            Image(systemName: "calendar")
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
        .onAppear {
            updateWeeklyProgress()
        }
        .onChange(of: stepViewModel.dailyStepCounts) { _ in
            updateWeeklyProgress()
        }
        .onChange(of: appearanceViewModel.appearance.goal) { _ in
            updateWeeklyProgress()
        }
    }

    private var progressIcon: Image {
        let progress = stepProgressRate(steps: weeklyViewModel.weeklyProgress.totalSteps, goal: weeklyViewModel.weeklyProgress.targetSteps)
        switch progress {
        case ..<0.25:
            return Image("AppIconTransparent")
        case 0.25..<0.5:
            return Image("ShoeBronze")
        case 0.5..<0.75:
            return Image("ShoeSilver")
        default:
            return Image("ShoeGold")
        }
    }

    private func updateWeeklyProgress() {
        weeklyViewModel.update(
            dailyCounts: stepViewModel.dailyStepCounts,
            goal: appearanceViewModel.appearance.goal
        )
    }
}
