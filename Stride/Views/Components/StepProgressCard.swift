//
//  StepProgressCard.swift
//  Stride
//

import SwiftUI

struct StepProgressCard: View {
    let steps: Int
    let appearance: SharedAppearance

    var body: some View {
        Card {
            StepProgressView(
                steps: steps,
                goal: appearance.goal,
                emoji: appearance.emoji,
                gradientID: appearance.gradientID,
                layout: .medium
            )
            .frame(maxWidth: .infinity)
        }
    }
}
