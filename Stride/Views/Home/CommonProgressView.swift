import SwiftUI

private let smallNumberFont = Font.custom("AvenirNext-Bold", size: 28)
private let mediumNumberFont = Font.custom("AvenirNext-Bold", size: 34)
private let mediumBadgeNumberFont = Font.custom("AvenirNext-Bold", size: 12)

private func stepProgressRate(steps: Int, goal: Int) -> CGFloat {
    guard goal > 0 else { return 0 }
    return min(CGFloat(steps) / CGFloat(goal), 1)
}

private func stepProgressPercentageText(rate: CGFloat) -> String {
    String(format: "%.0f%%", rate * 100)
}


// MARK: - Medium

struct CommonProgressView: View {
    var steps: Int
    var goal: Int
    var gradientID: String
    var image: Image = Image(systemName: "figure.run")

    private let iconSize: CGFloat = 100
    private var haloSize: CGFloat { iconSize * 0.9 }
    private var targetProgress: CGFloat { stepProgressRate(steps: steps, goal: goal) }
    // 表示用のテキスト（最終値を表示）
    private var progressPercentage: String { stepProgressPercentageText(rate: targetProgress) }

     @State private var animatedProgress: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Spacer()
                ZStack {
                    Circle()
                        .fill(gradient(for: gradientID))
                        .frame(width: haloSize, height: haloSize)
                        .blur(radius: 15)
                        .opacity(0.45)

                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: haloSize * 0.75, height: haloSize * 0.75)
                        .blur(radius: 18)
                        .opacity(0.55)
                
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: iconSize)
                        .padding(.vertical, 18)
                }
                Spacer()
            }
             HStack(spacing: 12) {

                 VStack(alignment: .leading, spacing: -3) {
                     HStack(alignment: .firstTextBaseline, spacing: 2) {
                         Text("\(steps)")
                             .font(mediumNumberFont)
                             .fontWeight(.bold)
                         Text("歩")
                             .font(.caption)
                             .fontWeight(.bold)
                         progressBadge(text: progressPercentage)
                             .padding(.leading, 15)
                             .offset(y: -5)                    }

                     Text("目標 \(goal.formatted())歩")
                         .font(.caption2)
                         .foregroundStyle(.secondary)
                 }
             }

             GeometryReader { proxy in
                 ZStack(alignment: .leading) {
                     Capsule()
                         .fill(Color.gray.opacity(0.15))
                     Capsule()
                         .fill(gradient(for: gradientID))
                         .frame(width: proxy.size.width * animatedProgress)
                 }
             }
             .frame(height: 25)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animatedProgress = targetProgress
            }
        }
        // ★歩数や目標が変わった場合もアニメーションで追従
        .onChange(of: steps) { _ in updateProgress() }
        .onChange(of: goal) { _ in updateProgress() }
    }
    
    // アニメーション更新用メソッド
    private func updateProgress() {
        withAnimation(.easeOut(duration: 1.0)) {
            animatedProgress = targetProgress
        }
    }

    private func progressBadge(text: String) -> some View {
        Text(text)
            .font(mediumBadgeNumberFont)
            .foregroundStyle(Color.accentColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.accentColor.opacity(0.15))
            )
    }
}
