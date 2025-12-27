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
    // @StateObject private var viewModel = StepViewModel(
    //     pedometerService: PedometerService()
    // )
    private let pedometerService = PedometerService()

    init() {
        let service = pedometerService
        Task {
            await service.configure { steps in
                await StepBackgroundManager.shared.handleStepUpdate(steps: steps)
            }
            if await service.isHealthDataAvailable() {
                Task {
                    for try await _ in await service.stepUpdates() { break }
                }
            }
        }
    }


    var body: some Scene {
        WindowGroup {
            HomeView(pedometerService: pedometerService)
        }
    }
}
