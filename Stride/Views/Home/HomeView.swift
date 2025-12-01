//
//  ContentView.swift
//  Stride
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: StepViewModel
    @State private var appearance: SharedAppearance = .default
    @State private var showingSettings = false
    private let weeks: Int = 12

    init(viewModel: StepViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // ================ Body ================

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                AppHeaderView {
                    showingSettings = true
                }
                .padding(.horizontal)


                // -------- StepProgressCard --------
                
                StepProgressCard(
                    steps: viewModel.currentSteps,
                    appearance: appearance
                )
                .padding(.horizontal, 25)


                // -------- ContributionHeatmapCard --------
                
                StepHeatmapCard(
                    stats: viewModel.dailyStepCounts,
                    weeks: weeks,
                    goal: appearance.goal
                )
                .padding(.horizontal, 25)

                // -------- Buttons --------
                
                actionButtons
            }
            .padding(.vertical)
        }
        .task {
            await loadInitialData()
        }
        .sheet(isPresented: $showingSettings) {
            AppearanceSettingsView(appearance: $appearance)
        }
    }
    
    // ================ UI ================
    
    private var actionButtons: some View {
            HStack {
                Button("権限をリクエスト") {
                    viewModel.requestAuthorization()
                }
                Button("計測を開始") {
                    viewModel.fetchCurrentSteps()
                }
                .disabled(viewModel.authorizationStatus != .authorized)
            }
            .buttonStyle(.borderedProminent)
        }
    
    // ================ Functions ================
    
    private func loadInitialData() async {
        appearance = SharedStore.loadAppearance()
        await viewModel.ensureDailyCountsLoaded(weeks: weeks)
    }
}
