import SwiftUI

func solidColor(for id: String) -> LinearGradient {
    switch id {
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
        return LinearGradient(colors: [.gray, Color(red: 0.45, green: 0.45, blue: 0.47)], startPoint: .bottomLeading, endPoint: .topTrailing)
    }
}
