//
//  StepProgressCard.swift
//  Stride
//

import SwiftUI

struct StepProgressCardView: View {
    let steps: Int
    let appearance: SharedAppearance

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 0){
                Text("Today")
                    .font(.title2)
                    .bold()
                StepProgressViewMedium(
                    steps: steps,
                    goal: appearance.goal,
                    emoji: appearance.emoji,
                    gradientID: appearance.gradientID
                )
                .frame(maxWidth: .infinity)
            }
            .padding(.top, 10)
            .padding(.horizontal, 10)
        }
    }
}
