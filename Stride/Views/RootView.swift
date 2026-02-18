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

                // -------- loading --------

                Color.blue.ignoresSafeArea()
            } else if !stepViewModel.isHealthKitAvailable {
                
                // -------- HealthKit is not available --------
                
                Text("HealthKitが利用できません")
            } else if stepViewModel.isAuthorizationRequested {
                
                // -------- Authorize already requested --------
                
                MainTabContainerView(
                    stepViewModel: stepViewModel,
                    appearanceViewModel: appearanceViewModel
                )
            } else {

                // -------- Authorize not requested --------

                WelcomeView {
                    stepViewModel.requestAuthorization()
                }
            }
        }
    }
}
