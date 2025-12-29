import SwiftUI

struct WeeklyProgressIconView: View {
    var gradientID: String
    var iconName: String = "AppIconTransparent"
    var iconSize: CGFloat = 150

    private var haloSize: CGFloat { iconSize * 0.7 }

    var body: some View {
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

            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
        }
        .compositingGroup()
    }
}
