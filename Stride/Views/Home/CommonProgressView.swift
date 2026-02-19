import SwiftUI

// MARK: - Medium

struct CommonProgressView: View {
    var steps: Int
    var goal: Int
    var gradientID: String
    var image: Image = Image(systemName: "figure.run")
    var onGoalTap: (() -> Void)? = nil

    private let iconSize: CGFloat = 100
    private var haloSize: CGFloat { iconSize * 0.9 }
    private var targetProgress: CGFloat { stepProgressRate(steps: steps, goal: goal) }
    private var progressPercentage: String { stepProgressPercentageText(rate: targetProgress) }

     @State private var animatedProgress: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // -------- Icon --------

            HStack {
                Spacer()
                ZStack {
                    Circle()
                        .fill(gradient(for: gradientID))
                        .frame(width: haloSize, height: haloSize)
                        .blur(radius: 15)
                        .opacity(0.45)

                    Circle()
                        .fill(AppColors.haloGlow)
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
             // -------- Step Count and %, goal--------

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

                     Text(String(format: String(localized: "目標 %@歩"), goal.formatted()))
                         .font(.caption2)
                         .foregroundStyle(.secondary)
                         .onTapGesture {
                             onGoalTap?()
                         }
                 }
             }

             // -------- Progress Bar --------

             GeometryReader { proxy in
                 ZStack(alignment: .leading) {
                     Capsule()
                         .fill(AppColors.progressBarTrack)
                     Capsule()
                         .fill(gradient(for: gradientID))
                         .frame(width: animatedProgress > 0 ? max(proxy.size.width * animatedProgress, 15) : 0)
                 }
             }
             .frame(height: 25)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animatedProgress = targetProgress
            }
        }
        .onChange(of: steps) { _ in updateProgress() }
        .onChange(of: goal) { _ in updateProgress() }
    }
    

   // ======================================== Private Functions ========================================
    

    private func updateProgress() {
        withAnimation(.easeOut(duration: 1.0)) {
            animatedProgress = targetProgress
        }
    }

    private func progressBadge(text: String) -> some View {
        Text(text)
            .font(mediumBadgeNumberFont)
            .foregroundStyle(AppColors.badgeForeground)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule(style: .continuous)
                    .fill(AppColors.badgeBackground)
            )
    }
}
