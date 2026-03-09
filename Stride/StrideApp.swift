//
//  StrideApp.swift
//  Stride
//
//  Created by 川井孝之 on 2025/11/07.
//

import SwiftUI
import RevenueCat

// TODO: Replace with your actual RevenueCat API key from the RevenueCat dashboard
private let kRevenueCatAPIKey = "appl_tJBesXkyZveDpQcDgAhfbTvLtPa"

@MainActor
@main
struct StrideApp: App {
    // @StateObject private var viewModel = StepViewModel(
    //     pedometerService: PedometerService()
    // )
    private let pedometerService = PedometerService()

    init() {
        Purchases.configure(withAPIKey: kRevenueCatAPIKey)
        // Uncomment to enable verbose logging during development:
        // Purchases.logLevel = .debug

        let service = pedometerService
        Task {
            await service.configure(backgroundStepUpdateHandler: { steps in
                await StepBackgroundManager.shared.handleStepUpdate(steps: steps)
            })
            if await service.isHealthDataAvailable() {
                Task {
                    for try await _ in await service.observeCurrentSteps() { break }
                }
            }
        }
    }


    var body: some Scene {
        WindowGroup {
            RootView(pedometerService: pedometerService)
        }
    }
}
