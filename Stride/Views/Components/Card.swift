//
//  Card.swift
//  Stride
//

import SwiftUI

struct Card<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 20, style: .continuous)
        content
            .padding(12)
            .background(shape.fill(AppColors.secondaryBackground))
            .overlay(
                shape
                    .stroke(AppColors.subtleBorder, lineWidth: 1)
            )
            .clipShape(shape)
//            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}
