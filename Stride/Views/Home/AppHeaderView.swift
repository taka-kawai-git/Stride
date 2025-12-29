//
//  AppHeaderView.swift
//  Stride
//

import SwiftUI

struct AppHeaderView: View {
    var onSettingsTapped: (() -> Void)?

    private let iconSize: CGFloat = 48

    var body: some View {
        HStack(spacing: 16) {
            
            // -------- AppIcon --------
            
            // Image("AppIconTransparent")
            //     .resizable()
            //     .scaledToFit()
            //     .frame(width: iconSize, height: iconSize)
                
            Spacer()
            
            // -------- Settings --------

            Button {
                onSettingsTapped?()
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            .accessibilityLabel("設定を開く")
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.black.opacity(0.05), lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, 12)
    }
}
