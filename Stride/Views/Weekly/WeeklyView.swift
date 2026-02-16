//
//  HistoryView.swift
//  Stride
//

import SwiftUI

struct WeeklyView: View {
    @ObservedObject var stepViewModel: StepViewModel
    @ObservedObject var appearanceViewModel: AppearanceViewModel
    var onGoalTap: (() -> Void)? = nil
    @StateObject private var weeklyViewModel = WeeklyProgressViewModel()

    // -------- Body --------
    
    var body: some View {
        ScrollView {
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
                        image: Image("AppIconTransparent"),
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
                            appearanceViewModel: appearanceViewModel
                        )
                    }
                }
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

    private func updateWeeklyProgress() {
        weeklyViewModel.update(
            dailyCounts: stepViewModel.dailyStepCounts,
            goal: appearanceViewModel.appearance.goal
        )
    }
}
