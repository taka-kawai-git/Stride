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
    
    private let tabs = ["Daily", "Weekly"]
    
    var body: some View {
        VStack(spacing: 0) {

            // -------- AppHeaderView --------

            AppHeaderView {
                showingSettings = true
            }
           .padding(.horizontal)

            // 上部タブバー
            TopTabBar(selectedTab: $selectedTab, tabs: tabs)
                .padding(.top, 8)
            
            Divider()
            
            // タブコンテンツ
            TabView(selection: $selectedTab) {
                DailyView(
                    stepViewModel: stepViewModel,
                    appearanceViewModel: appearanceViewModel
                )
                .tag(0)
                
                WeeklyView(
                    stepViewModel: stepViewModel,
                    appearanceViewModel: appearanceViewModel
                )
                .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .sheet(isPresented: $showingSettings) {
            AppearanceSettingsView(appearance: $appearanceViewModel.appearance)
        }
    }
}
