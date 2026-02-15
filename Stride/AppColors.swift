import SwiftUI

enum AppColors {

    // MARK: - Background

    /// メイン背景色 (`systemBackground`)
    static let background = Color(.systemBackground)

    /// カード・セクション背景色 (`secondarySystemBackground`)
    static let secondaryBackground = Color(.secondarySystemBackground)

    /// グループ化された背景色 (`secondarySystemGroupedBackground`)
    static let groupedBackground = Color(.secondarySystemGroupedBackground)

    // MARK: - Stroke / Border

    /// カード・ボタンの薄い枠線
    static let subtleBorder = Color.black.opacity(0.05)

    /// セパレーター
    static let separator = Color(uiColor: .separator)

    // MARK: - Shadow

    /// カード影色
    static let cardShadow = Color.black.opacity(0.15)

    // MARK: - Progress Bar

    /// プログレスバー未達成部分の背景
    static let progressBarTrack = Color.gray.opacity(0.15)

    // MARK: - Badge

    /// パーセンテージバッジの文字色
    static let badgeForeground = Color.accentColor

    /// パーセンテージバッジの背景色
    static let badgeBackground = Color.accentColor.opacity(0.15)

    // MARK: - Selection

    /// 選択ハイライト
    static let selectionHighlight = Color.accentColor.opacity(0.08)

    // MARK: - Halo / Glow

    /// アイコン周辺のハロー効果
    static let haloGlow = Color.white.opacity(0.3)

    // MARK: - Onboarding

    /// オンボーディング画面のヒーロー背景
    static let onboardingHero = Color.blue

    // MARK: - Heatmap

    /// ヒートマップの色（歩数比率に応じた色を返す）
    static func heatmapColor(for value: Int, maxValue: Int) -> Color {
        guard maxValue > 0 else { return progressBarTrack }

        let ratio = Double(value) / Double(maxValue)
        switch ratio {
        case ..<0.1:
            return progressBarTrack
        case ..<0.3:
            return Color.blue.opacity(0.35)
        case ..<0.5:
            return Color.blue.opacity(0.55)
        case ..<0.8:
            return Color.blue.opacity(0.75)
        default:
            return Color.blue
        }
    }

    // MARK: - Data Missing Hint

    /// データ欠損ヒントカードの背景グラデーション
    static func dataMissingGradientColors(for colorScheme: ColorScheme) -> [Color] {
        colorScheme == .dark ? [
            Color(.sRGB, red: 0.22, green: 0.18, blue: 0.08, opacity: 0.95),
            Color(.sRGB, red: 0.14, green: 0.12, blue: 0.05, opacity: 0.92)
        ] : [
            Color(.sRGB, red: 1.0, green: 0.98, blue: 0.90, opacity: 1),
            Color(.sRGB, red: 1.0, green: 0.95, blue: 0.80, opacity: 1)
        ]
    }

    /// データ欠損ヒントカードの枠線色
    static func dataMissingStrokeColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(.sRGB, red: 0.45, green: 0.35, blue: 0.10, opacity: 0.35)
            : Color(.sRGB, red: 1.0, green: 0.8, blue: 0.4, opacity: 0.2)
    }
}
