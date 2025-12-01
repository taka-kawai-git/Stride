//
//  AppearanceSettingsView.swift
//  Stride
//

import SwiftUI

struct AppearanceSettingsView: View {
    @Binding var appearance: SharedAppearance
    @Environment(\.dismiss) private var dismiss

    @State private var workingAppearance: SharedAppearance

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
                Section(header: Text("カラーテーマ")) {
                    ForEach(gradientOptions) { option in
                        HStack {
                            gradient(for: option.id)
                                .frame(width: 80, height: 22)
                                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                            Spacer()
                            if workingAppearance.gradientID == option.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            workingAppearance.gradientID = option.id
                        }
                    }
                }

                Section(header: Text("目標歩数")) {
                    Stepper(value: $workingAppearance.goal, in: 1_000...40_000, step: 500) {
                        Text("\(workingAppearance.goal.formatted()) 歩")
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("設定")
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

    private func saveChanges() {
        appearance = workingAppearance
        SharedStore.saveAppearance(workingAppearance)
        dismiss()
    }
}

private struct GradientOption: Identifiable {
    let id: String
}
