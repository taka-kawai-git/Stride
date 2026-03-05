import SwiftUI

func gradient(for id: String) -> LinearGradient {
    switch id {
    case "redBlueCyan":
        return LinearGradient(colors: [.red, .pink, .blue, .blue, .cyan, .cyan], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "greenMintBlue":
        return LinearGradient(colors: [.green, .mint, .blue], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "pinkPurple":
        return LinearGradient(colors: [.pink, .purple], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "orangeRedPink":
        return LinearGradient(colors: [.orange, .red, .pink], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "tealBlueIndigo":
        return LinearGradient(colors: [.teal, .blue, .indigo], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "mintGreenBrown":
        return LinearGradient(colors: [.mint, .green, .brown], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "purpleIndigoBlack":
        return LinearGradient(colors: [.purple, .indigo, .black.opacity(0.7)], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "grayBlack":
        return LinearGradient(colors: [.gray, .black], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "yellowOrange":
        return LinearGradient(colors: [.yellow, .orange], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "peachPinkPurple":
        return LinearGradient(colors: [Color(red: 1, green: 0.82, blue: 0.67), .pink, .purple], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "magentaVioletIndigo":
        return LinearGradient(colors: [.pink, Color(red: 0.7, green: 0, blue: 0.5), .indigo], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "cyanTeal":
        return LinearGradient(colors: [.cyan, .teal], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "blueCyanSky":
        return LinearGradient(colors: [.blue, .cyan, Color(red: 0.53, green: 0.81, blue: 0.92)], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "peachCoralOrange":
        return LinearGradient(colors: [Color(red: 1, green: 0.74, blue: 0.55), .orange, Color(red: 1, green: 0.4, blue: 0.45)], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "lavenderPurpleIndigo":
        return LinearGradient(colors: [Color(red: 0.78, green: 0.69, blue: 0.97), .purple, .indigo], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "redMaroonBrown":
        return LinearGradient(colors: [.red, Color(red: 0.5, green: 0, blue: 0), Color(red: 0.36, green: 0.15, blue: 0.15)], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "mintLimeGreen":
        return LinearGradient(colors: [.mint, Color(red: 0.7, green: 0.95, blue: 0.5), .green], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "oliveBrown":
        return LinearGradient(colors: [Color(red: 0.6, green: 0.55, blue: 0.39), .brown, Color(red: 0.36, green: 0.25, blue: 0.18)], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "sunsetOrange":
        return LinearGradient(colors: [.orange, .red, .pink], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "oceanBlue":
        return LinearGradient(colors: [.teal, .blue, .indigo], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "forest":
        return LinearGradient(colors: [.mint, .green, .brown], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "midnight":
        return LinearGradient(colors: [.purple, .indigo, .black.opacity(0.7)], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "mono":
        return LinearGradient(colors: [.gray], startPoint: .bottomLeading, endPoint: .topTrailing)

    // Pastel solid colors
    case "pastelPink":
        return LinearGradient(colors: [Color(red: 1.0, green: 0.84, blue: 0.90), Color(red: 0.93, green: 0.68, blue: 0.78)], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "pastelMint":
        return LinearGradient(colors: [Color(red: 0.78, green: 0.98, blue: 0.90), Color(red: 0.60, green: 0.88, blue: 0.78)], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "pastelLavender":
        return LinearGradient(colors: [Color(red: 0.88, green: 0.84, blue: 1.0), Color(red: 0.75, green: 0.70, blue: 0.92)], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "pastelSky":
        return LinearGradient(colors: [Color(red: 0.78, green: 0.92, blue: 1.0), Color(red: 0.62, green: 0.80, blue: 0.93)], startPoint: .bottomLeading, endPoint: .topTrailing)

    // Pastel gradients
    case "pastelSunrise":
        return LinearGradient(colors: [Color(red: 1.0, green: 0.76, blue: 0.84), Color(red: 1.0, green: 0.88, blue: 0.72), Color(red: 1.0, green: 0.97, blue: 0.70)], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "pastelOcean":
        return LinearGradient(colors: [Color(red: 0.70, green: 0.93, blue: 0.87), Color(red: 0.70, green: 0.87, blue: 0.97), Color(red: 0.82, green: 0.78, blue: 0.97)], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "pastelCottonCandy":
        return LinearGradient(colors: [Color(red: 1.0, green: 0.78, blue: 0.88), Color(red: 0.85, green: 0.78, blue: 0.97)], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "pastelMeadow":
        return LinearGradient(colors: [Color(red: 0.98, green: 0.96, blue: 0.72), Color(red: 0.72, green: 0.95, blue: 0.83), Color(red: 0.70, green: 0.87, blue: 0.97)], startPoint: .bottomLeading, endPoint: .topTrailing)

    // Solid colors
    case "solidWhite":
        return LinearGradient(colors: [.white, Color(red: 0.90, green: 0.90, blue: 0.92)], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "solidBlack":
        return LinearGradient(colors: [Color(red: 0.18, green: 0.18, blue: 0.20), .black], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "solidRed":
        return LinearGradient(colors: [Color(red: 0.95, green: 0.28, blue: 0.28), Color(red: 0.78, green: 0.12, blue: 0.12)], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "solidBlue":
        return LinearGradient(colors: [Color(red: 0.30, green: 0.50, blue: 0.95), Color(red: 0.15, green: 0.30, blue: 0.80)], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "solidGreen":
        return LinearGradient(colors: [Color(red: 0.28, green: 0.82, blue: 0.38), Color(red: 0.15, green: 0.65, blue: 0.22)], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "solidOrange":
        return LinearGradient(colors: [Color(red: 1.00, green: 0.62, blue: 0.20), Color(red: 0.92, green: 0.45, blue: 0.05)], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "solidPurple":
        return LinearGradient(colors: [Color(red: 0.68, green: 0.30, blue: 0.95), Color(red: 0.50, green: 0.12, blue: 0.80)], startPoint: .bottomLeading, endPoint: .topTrailing)
    case "solidYellow":
        return LinearGradient(colors: [Color(red: 1.00, green: 0.90, blue: 0.20), Color(red: 0.92, green: 0.78, blue: 0.05)], startPoint: .bottomLeading, endPoint: .topTrailing)

    default:
        return LinearGradient(colors: [.green, .mint, .blue], startPoint: .leading, endPoint: .trailing)
    }
}
