//
//  MainTabContainerView.swift
//  Stride
//

import SwiftUI

struct MainTabContainerView: View {
    @ObservedObject var stepViewModel: StepViewModel
    @ObservedObject var appearanceViewModel: AppearanceViewModel
    
    @State private var selectedTab: Int = 0
    @State private var showingSettings = false
    
    private let tabs: [LocalizedStringKey] = ["Daily", "Weekly"]
    
    var body: some View {
        VStack(spacing: 0) {

            // -------- AppHeaderView --------

            AppHeaderView {
                showingSettings = true
            }
           .padding(.horizontal)

            // -------- Tab Bar --------

            TopTabBar(selectedTab: $selectedTab, tabs: tabs)
                .padding(.top, 8)
            
            Divider()
            
            // -------- Tab Contents --------

            TabView(selection: $selectedTab) {

                // -------- DailyView --------
                
                DailyView(
                    stepViewModel: stepViewModel,
                    appearanceViewModel: appearanceViewModel,
                    onGoalTap: { showingSettings = true }
                )
                .tag(0)

                // -------- WeeklyView --------


                WeeklyView(
                    stepViewModel: stepViewModel,
                    appearanceViewModel: appearanceViewModel,
                    onGoalTap: { showingSettings = true }
                )
                .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .sheet(isPresented: $showingSettings) {

            // -------- Show AppearanceSettingsView if gear is tapped --------

            AppearanceSettingsView(appearance: $appearanceViewModel.appearance)
                .presentationBackground(AppColors.background)
        }
    }
}
