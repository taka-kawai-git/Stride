//
//  WeeklyProgressViewForOneYear.swift
//  Stride
//

import SwiftUI

struct WeeklyProgressViewForOneYear: View {
    @ObservedObject var stepViewModel: StepViewModel
    @ObservedObject var appearanceViewModel: AppearanceViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                PastWeeklyProgressView(
                    stepViewModel: stepViewModel,
                    appearanceViewModel: appearanceViewModel,
                    weeks: 52
                )
            }
            .padding(.horizontal, 25)
            .padding(.vertical)
        }
        .navigationTitle("過去1年")
        .navigationBarTitleDisplayMode(.inline)
    }
}