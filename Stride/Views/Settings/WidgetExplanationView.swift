//
//  WidgetExplanationView.swift
//  Stride
//

import SwiftUI

struct WidgetExplanationView: View {
    @State private var isAnimating = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {

                // -------- Header --------

                VStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Today")
                            .font(.subheadline)
                            .bold()
                        StepProgressViewSmall(steps: 6_248)
                    }
                    .padding()
                    .frame(width: 155, height: 155)
                    .background(AppColors.groupedBackground, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: AppColors.cardShadow, radius: 8, x: 0, y: 4)
                    .rotation3DEffect(
                        .degrees(isAnimating ? 8 : -8),
                        axis: (x: isAnimating ? 0.3 : -0.3, y: 1, z: 0),
                        perspective: 0.5
                    )
                    .onAppear {
                        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                            isAnimating = true
                        }
                    }

                    Spacer().frame(height: 4)

                    Text("ホーム画面にウィジェットを追加しよう")
                        .font(.title.bold())
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 12)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 16)
                .padding(.top, 12)

                // -------- Steps --------

                VStack(alignment: .leading, spacing: 16) {
                    stepRow(number: 1, text: "ホーム画面の空白部分を長押しします")
                    stepRow(number: 2, text: "左上の「編集」ボタンをタップします")
                    stepRow(number: 3, text: "検索欄で「Stride」と入力します")
                    stepRow(number: 4, text: "好きなサイズを選んで「ウィジェットを追加」をタップします")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(AppColors.secondaryBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                // -------- Notes --------

                VStack(alignment: .leading, spacing: 12) {
                    Label("注意", systemImage: "exclamationmark.triangle.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)

                    noteRow(
                        systemName: "clock.arrow.circlepath",
                        text: "iOSの仕組みにより、ウィジェットの歩数は１時間に１回程度更新されます"
                    )
                    noteRow(
                        systemName: "battery.25percent",
                        text: "iOSの制限により、バッテリーを低電力モードにしている場合は更新がされません"
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
            }
            .padding()
        }
        .navigationTitle("ウィジェット")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews

    private func stepRow(number: Int, text: String) -> some View {
        HStack(alignment: .center, spacing: 14) {
            Text("\(number)")
                .font(.subheadline.bold())
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(AppColors.badgeForeground, in: Circle())

            Text(text)
                .font(.system(size: 16))
                .padding(.top, 4)
        }
    }

    private func noteRow(systemName: String, text: String) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: systemName)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(width: 24)

            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func widgetSizeCard(title: String, systemName: String, size: CGFloat) -> some View {
        VStack(spacing: 8) {
            Image(systemName: systemName)
                .font(.system(size: size * 0.45))
                .foregroundStyle(.secondary)
                .frame(width: size, height: size * (systemName.contains("rectangle") ? 0.55 : 1))
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.groupedBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}