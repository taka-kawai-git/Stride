//
//  AppHeaderView.swift
//  Stride
//

import SwiftUI

struct AppHeaderView: View {
    var onSettingsTapped: (() -> Void)?

    private let iconSize: CGFloat = 48

    var body: some View {
        HStack(spacing: 0) {
                
            Spacer()
            
            // -------- Settings --------

            Button {
                onSettingsTapped?()
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("設定を開く"))
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppColors.secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(AppColors.subtleBorder, lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, 0)
    }
}
