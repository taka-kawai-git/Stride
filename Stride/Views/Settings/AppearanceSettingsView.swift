//
//  AppearanceSettingsView.swift
//  Stride
//

import SwiftUI

struct AppearanceSettingsView: View {
    @Binding var appearance: SharedAppearance
    @Environment(\.dismiss) private var dismiss

    // -------- Gradient themes --------

    private let gradientOptions: [GradientOption] = [
        .init(id: "redBlueCyan"),
        .init(id: "greenMintBlue"),
        .init(id: "pinkPurple"),
        .init(id: "tealBlueIndigo"),
        .init(id: "peachPinkPurple"),
        .init(id: "magentaVioletIndigo"),
        .init(id: "peachCoralOrange"),
        .init(id: "lavenderPurpleIndigo"),
        .init(id: "oliveBrown"),
        // Pastel solid
        .init(id: "pastelPink"),
        .init(id: "pastelMint"),
        .init(id: "pastelLavender"),
        .init(id: "pastelSky"),
        // Pastel gradient
        .init(id: "pastelSunrise"),
        .init(id: "pastelOcean"),
        .init(id: "pastelCottonCandy"),
        .init(id: "pastelMeadow")
    ]

    var body: some View {
        NavigationStack {
            Form {

                // -------- Color Theme Grid --------

                Section {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0)], spacing: 0) {
                        ForEach(Array(gradientOptions.enumerated()), id: \.element.id) { index, option in
                            let isSelected = appearance.gradientID == option.id
                            gradient(for: option.id)
                                .frame(width: 80, height: 22)
                                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                                .overlay(alignment: .trailing) {
                                    if isSelected {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.blue)
                                            .offset(x: 28)
                                    }
                                }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .overlay(alignment: .bottom) {
                                if index / 2 < (gradientOptions.count - 1) / 2 {
                                    Divider()
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                appearance.gradientID = option.id
                                SharedStore.saveAppearance(appearance)
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(AppColors.secondaryBackground)
                    .overlay {
                        AppColors.separator
                            .frame(width: 1 / UIScreen.main.scale)
                    }
                } header: {
                    Text("カラーテーマ")
                        .font(.caption)
                        .listRowInsets(EdgeInsets())
                }

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

                // -------- Widget Section --------

                Section {
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

private struct GradientOption: Identifiable {
    let id: String
}
