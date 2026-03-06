//
//  ColorThemeSettingsView.swift
//  Stride
//

import SwiftUI

struct ColorThemeSettingsView: View {
    @Binding var appearance: SharedAppearance
    @StateObject private var subscription = SubscriptionViewModel.shared
    @State private var showPaywall = false

    /// 無料で使えるグラデーションテーマ数
    private let freeGradientCount = 6

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
        .init(id: "oliveBrown")
    ]

    // -------- Solid color themes --------

    private let solidOptions: [SolidOption] = [
        .init(id: "solidWhite"),
        .init(id: "solidBlack"),
        .init(id: "solidRed"),
        .init(id: "solidBlue"),
        .init(id: "solidGreen"),
        .init(id: "solidOrange"),
        .init(id: "solidPurple"),
        .init(id: "solidYellow")
    ]

    // -------- Pastel themes --------

    private let pastelOptions: [PastelOption] = [
        // Solid
        .init(id: "pastelPink"),
        .init(id: "pastelMint"),
        .init(id: "pastelLavender"),
        .init(id: "pastelSky"),
        // Gradient
        .init(id: "pastelSunrise"),
        .init(id: "pastelOcean"),
        .init(id: "pastelCottonCandy"),
        .init(id: "pastelMeadow")
    ]

    var body: some View {
        Form {

            // -------- Color Theme Grid --------

            Section {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0)], spacing: 0) {
                    ForEach(Array(gradientOptions.enumerated()), id: \.element.id) { index, option in
                        let isSelected = appearance.gradientID == option.id
                        let isLocked = index >= freeGradientCount && !subscription.isPremium
                        gradient(for: option.id)
                            .frame(width: 80, height: 22)
                            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                            .opacity(isLocked ? 0.4 : 1.0)
                            .overlay(alignment: .leading) {
                                if isLocked {
                                    Image(systemName: "lock.fill")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .offset(x: -22)
                                }
                            }
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
                            if isLocked { showPaywall = true; return }
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

            // -------- Solid Color Grid --------

            Section {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0)], spacing: 0) {
                    ForEach(Array(solidOptions.enumerated()), id: \.element.id) { index, option in
                        let isSelected = appearance.gradientID == option.id
                        let isLocked = !subscription.isPremium
                        solidColor(for: option.id)
                            .frame(width: 80, height: 22)
                            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                            .opacity(isLocked ? 0.4 : 1.0)
                            .overlay(alignment: .leading) {
                                if isLocked {
                                    Image(systemName: "lock.fill")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .offset(x: -22)
                                }
                            }
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
                            if index / 2 < (solidOptions.count - 1) / 2 {
                                Divider()
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if isLocked { showPaywall = true; return }
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
                Text("単色")
                    .font(.caption)
                    .listRowInsets(EdgeInsets())
            }

            // -------- Pastel Theme Grid --------

            Section {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0)], spacing: 0) {
                    ForEach(Array(pastelOptions.enumerated()), id: \.element.id) { index, option in
                        let isSelected = appearance.gradientID == option.id
                        let isLocked = !subscription.isPremium
                        gradient(for: option.id)
                            .frame(width: 80, height: 22)
                            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                            .opacity(isLocked ? 0.4 : 1.0)
                            .overlay(alignment: .leading) {
                                if isLocked {
                                    Image(systemName: "lock.fill")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .offset(x: -22)
                                }
                            }
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
                            if index / 2 < (pastelOptions.count - 1) / 2 {
                                Divider()
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if isLocked { showPaywall = true; return }
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
                Text("パステルカラー")
                    .font(.caption)
                    .listRowInsets(EdgeInsets())
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("カラーテーマ")
                    .font(.headline)
            }
            if !subscription.isPremium {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showPaywall = true
                    } label: {
                        Label("プレミアム", systemImage: "crown.fill")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(red: 0.95, green: 0.76, blue: 0.25), Color(red: 0.90, green: 0.55, blue: 0.10)],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                    }
                }
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

private struct GradientOption: Identifiable {
    let id: String
}

private struct PastelOption: Identifiable {
    let id: String
}

private struct SolidOption: Identifiable {
    let id: String
}