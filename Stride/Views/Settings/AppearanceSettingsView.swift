//
//  AppearanceSettingsView.swift
//  Stride
//

import SwiftUI

struct AppearanceSettingsView: View {
    @Binding var appearance: SharedAppearance
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {

                // -------- Goal Setting --------

                Section {
                    Stepper(value: $appearance.goal, in: 1_000...40_000, step: 500) {
                        Text(String(format: String(localized: "%@ 歩"), appearance.goal.formatted()))
                            .font(.headline)
                    }
                    .onChange(of: appearance.goal) {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        SharedStore.saveAppearance(appearance)
                    }
                    .listRowBackground(AppColors.secondaryBackground)
                } header: {
                    Text("目標歩数")
                        .font(.caption)
                        .listRowInsets(EdgeInsets())
                }

                // -------- Links Section --------

                Section {
                    NavigationLink {
                        ColorThemeSettingsView(appearance: $appearance)
                    } label: {
                        Label("カラーテーマ", systemImage: "paintpalette")
                    }
                    .foregroundStyle(.primary)
                    .listRowBackground(AppColors.secondaryBackground)

                    NavigationLink {
                        WidgetExplanationView()
                    } label: {
                        Label("ウィジェットについて", systemImage: "square.grid.2x2")
                    }
                    .foregroundStyle(.primary)
                    .listRowBackground(AppColors.secondaryBackground)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.background, for: .navigationBar)

            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("設定")
                        .font(.headline)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") { dismiss() }
                }
            }
        }
    }
}