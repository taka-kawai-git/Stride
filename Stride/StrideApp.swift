//
//  StrideApp.swift
//  Stride
//
//  Created by 川井孝之 on 2025/11/07.
//

import SwiftUI

@MainActor
@main
struct StrideApp: App {
    @StateObject private var viewModel = StepViewModel(
        pedometerService: PedometerService(onStepsUpdated: { SharedStore.saveCurrentSteps($0) })
    )

    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: viewModel)
        }
    }
}
