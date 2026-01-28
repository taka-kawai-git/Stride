//
//  RootView.swift
//  Stride
//

import SwiftUI
import os.log

struct RootView: View {
    @StateObject private var stepViewModel: StepViewModel
    @StateObject private var appearanceViewModel = AppearanceViewModel()
    
    private let log = Logger(category: "view")
    
    init(pedometerService: PedometerService) {
        _stepViewModel = StateObject(wrappedValue: StepViewModel(service: pedometerService))
    }
    
    var body: some View {
        Group {
            if !appearanceViewModel.isLoaded {
                // ローディング画面
                Color.blue.ignoresSafeArea()
            } else if !stepViewModel.isHealthKitAvailable {
                // HealthKit利用不可
                Text("HealthKit is not available")
            } else if stepViewModel.isAuthorizationRequested {
                // 認証済み → タブビュー
                MainTabContainerView(
                    stepViewModel: stepViewModel,
                    appearanceViewModel: appearanceViewModel
                )
            } else {
                // 未認証 → ウェルカム画面
                WelcomeView {
                    stepViewModel.requestAuthorization()
                }
            }
        }
    }
}
