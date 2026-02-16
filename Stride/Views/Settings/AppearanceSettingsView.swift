//
//  AppearanceSettingsView.swift
//  Stride
//

import SwiftUI

struct AppearanceSettingsView: View {
    @Binding var appearance: SharedAppearance
    @Environment(\.dismiss) private var dismiss

    @State private var workingAppearance: SharedAppearance

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

    init(appearance: Binding<SharedAppearance>) {
        _appearance = appearance
        _workingAppearance = State(initialValue: appearance.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            Form {

                // -------- Color Theme Grid --------

                Section {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0)], spacing: 0) {
                        ForEach(Array(gradientOptions.enumerated()), id: \.element.id) { index, option in
                            let isSelected = workingAppearance.gradientID == option.id
                            ZStack {
                                gradient(for: option.id)
                                    .frame(height: 22)
                                    .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                                    .padding(.horizontal, 40)
                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.white, .blue)
                                        .font(.title3)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(isSelected ? AppColors.selectionHighlight : Color.clear)
                            .overlay(alignment: .bottom) {
                                if index / 2 < (gradientOptions.count - 1) / 2 {
                                    Divider()
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                workingAppearance.gradientID = option.id
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
                        .font(.subheadline.bold())
                        .listRowInsets(EdgeInsets())
                }

                // -------- Goal Setting --------

                Section {
                    Stepper(value: $workingAppearance.goal, in: 1_000...40_000, step: 500) {
                        Text("\(workingAppearance.goal.formatted()) 歩")
                            .font(.headline)
                    }
                    .onChange(of: workingAppearance.goal) {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                    .listRowBackground(AppColors.secondaryBackground)
                } header: {
                    Text("目標歩数")
                        .font(.subheadline.bold())
                        .listRowInsets(EdgeInsets())
                }

                // -------- Widget Section --------

                Section {
                    NavigationLink {
                        WidgetExplanationView()
                    } label: {
                        Label("ウィジェットについて", systemImage: "square.grid.2x2")
                    }
                    .listRowBackground(AppColors.secondaryBackground)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("設定")
            .toolbarBackground(AppColors.background, for: .navigationBar)

            // -------- Cancel / Save button --------

            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { saveChanges() }
                }
            }
        }
    }


    // ======================================== Private functions ========================================


    private func saveChanges() {
        appearance = workingAppearance
        SharedStore.saveAppearance(workingAppearance)
        dismiss()
    }
}

private struct GradientOption: Identifiable {
    let id: String
}
