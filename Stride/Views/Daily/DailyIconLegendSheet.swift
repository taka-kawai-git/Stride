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

    private let items: [LegendItem] = [
        LegendItem(imageName: "ThinkingFace",  range: "0〜24%",   description: "まだまだこれから"),
        LegendItem(imageName: "ThumbsUp",      range: "25〜49%",  description: "いい調子！"),
        LegendItem(imageName: "Trophy",        range: "50〜74%",  description: "もうひと踏ん張り！"),
        LegendItem(imageName: "PartyPopper",   range: "75〜100%", description: "目標達成！"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("アイコンの説明")
                .font(.headline)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 12)

            ForEach(items.indices, id: \.self) { i in
                let item = items[i]
                let isActive = isActiveItem(index: i)

                VStack(spacing: 0) {
                    HStack(spacing: 16) {
                        Image(item.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.range)
                                .font(.subheadline.bold())
                            Text(item.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if isActive {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.green)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(isActive ? Color(.systemGray6) : Color.clear)

                    if i < items.count - 1 {
                        Divider()
                            .padding(.leading, 84)
                    }
                }
            }

            Spacer()
        }
        .presentationDetents([.medium])
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
