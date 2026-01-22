import Foundation
import SwiftUI

// 過去の週ごとの進捗を表すデータモデル
struct PastWeeklyReport: Identifiable, Equatable {
    let id = UUID()
    let startOfWeek: Date
    let endOfWeek: Date
    let totalSteps: Int
    let dailyGoal: Int
    
    // 週の目標（1日 × 7）
    var weeklyGoal: Int { dailyGoal * 7 }
    
    // 進捗率 (0.0 ~ 1.0 ...)
    var progress: Double {
        guard weeklyGoal > 0 else { return 0 }
        return Double(totalSteps) / Double(weeklyGoal)
    }
    
    // UI表示用の%（100分率の整数）
    var percentageValue: Int {
        Int((progress * 100).rounded())
    }
    
    // 表示用の日付範囲文字列 (例: "1/15 - 1/21")
    func dateRangeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
    }
}

@MainActor
final class PastWeeklyProgressViewModel: ObservableObject {
    @Published var reports: [PastWeeklyReport] = []
    
    // カレンダー設定（月曜始まり）
    private var calendar: Calendar {
        var cal = Calendar.current
        cal.firstWeekday = 2 // 1: Sunday, 2: Monday
        return cal
    }

    /// StepViewModelのデータと目標値を受け取って計算を行う
    func calculateHistory(dailySteps: [Date: Int], dailyGoal: Int) {
        // バックグラウンドスレッドで重い計算を行う場合を考慮してTaskで囲むことも可能ですが、
        // データ量が膨大でなければMainActor上で処理しても通常は問題ありません。
        // ここでは安全に計算ロジックを実装します。

        var weeklyGroups: [Date: Int] = [:] // 週の開始日 : 合計歩数
        
        for (date, steps) in dailySteps {
            // その日付が属する週の「月曜日」を取得
            // .yearForWeekOfYear と .weekOfYear を使用して週を特定
            let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
            
            if let startOfWeek = calendar.date(from: components) {
                weeklyGroups[startOfWeek, default: 0] += steps
            }
        }
        
        // 日付の新しい順（降順）にソート
        let sortedKeys = weeklyGroups.keys.sorted(by: >)
        
        let newReports = sortedKeys.map { startOfWeek -> PastWeeklyReport in
            // 週の終わり（日曜日）を計算 (月曜 + 6日)
            let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? startOfWeek
            let total = weeklyGroups[startOfWeek] ?? 0
            
            return PastWeeklyReport(
                startOfWeek: startOfWeek,
                endOfWeek: endOfWeek,
                totalSteps: total,
                dailyGoal: dailyGoal
            )
        }
        
        self.reports = newReports
    }
}