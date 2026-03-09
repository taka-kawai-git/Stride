//
//  DailyIconLegendSheet.swift
//  Stride
//

import SwiftUI

struct DailyIconLegendSheet: View {
    let currentProgress: CGFloat

    private struct LegendItem {
        let imageName: String
        let range: String
        let description: String
    }

    private var items: [LegendItem] {[
        LegendItem(imageName: "ThinkingFace",  range: "0〜24%",   description: String(localized: "まだまだこれから")),
        LegendItem(imageName: "ThumbsUp",      range: "25〜49%",  description: String(localized: "いい調子！")),
        LegendItem(imageName: "Trophy",        range: "50〜74%",  description: String(localized: "もうひと踏ん張り！")),
        LegendItem(imageName: "PartyPopper",   range: "75〜100%", description: String(localized: "目標達成！")),
    ]}

    @State private var contentHeight: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            ForEach(items.indices, id: \.self) { i in
                let item = items[i]
                let isActive = isActiveItem(index: i)

                VStack(spacing: 0) {
                    HStack(spacing: 16) {
                        Image(item.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.range)
                                .font(.headline)
                            Text(item.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(isActive ? Color(.systemGray6) : Color.clear)

                    if i < items.count - 1 {
                        Divider()
                    }
                }
            }
        }
        .padding(.top, 30)
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear { contentHeight = geo.size.height }
            }
        )
        .presentationDetents([.height(contentHeight)])
        .presentationDragIndicator(.visible)
    }

    private func isActiveItem(index: Int) -> Bool {
        switch index {
        case 0: return currentProgress < 0.25
        case 1: return currentProgress >= 0.25 && currentProgress < 0.5
        case 2: return currentProgress >= 0.5 && currentProgress < 0.75
        case 3: return currentProgress >= 0.75
        default: return false
        }
    }
}
