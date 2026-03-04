import SwiftUI

func solidColor(for id: String) -> LinearGradient {
    let color: Color
    switch id {
    case "solidWhite":  color = .white
    case "solidBlack":  color = .black
    case "solidRed":    color = Color(red: 0.90, green: 0.20, blue: 0.20)
    case "solidBlue":   color = Color(red: 0.20, green: 0.40, blue: 0.90)
    case "solidGreen":  color = Color(red: 0.20, green: 0.75, blue: 0.30)
    case "solidOrange": color = Color(red: 1.00, green: 0.55, blue: 0.10)
    case "solidPurple": color = Color(red: 0.60, green: 0.20, blue: 0.90)
    case "solidYellow": color = Color(red: 1.00, green: 0.85, blue: 0.10)
    default:            color = .gray
    }
    return LinearGradient(colors: [color], startPoint: .bottomLeading, endPoint: .topTrailing)
}
