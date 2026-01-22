
import SwiftUI

struct PastWeeklyProgressView: View {
    @ObservedObject var stepViewModel: StepViewModel
    @ObservedObject var appearanceViewModel: AppearanceViewModel
    
    // 作成したViewModel
    @StateObject private var historyViewModel = PastWeeklyProgressViewModel()
    
    // 明示的なイニシャライザ
    init(stepViewModel: StepViewModel, appearanceViewModel: AppearanceViewModel) {
        self._stepViewModel = ObservedObject(wrappedValue: stepViewModel)
        self._appearanceViewModel = ObservedObject(wrappedValue: appearanceViewModel)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // セクションタイトル
            Text("過去の週次進捗")
                .font(.headline)
                .foregroundStyle(.primary)
            
            // レポートリスト
            LazyVStack(spacing: 12) {
                ForEach(historyViewModel.reports) { report in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(report.dateRangeString())
                                .font(.headline)
                            Text("目標: \(report.weeklyGoal)歩")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(report.percentageValue)%")
                                .font(.title3.bold())
                                .foregroundStyle(report.progress >= 1.0 ? .green : .primary)
                            
                            Text("\(report.totalSteps) 歩")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.systemBackground))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color(.systemGray5), lineWidth: 1)
                    )
                }
            }
        }
        .onAppear {
            refreshData()
        }
        // 歩数データが更新されたら再計算
        .onChange(of: stepViewModel.dailyStepCounts) { _ in
            refreshData()
        }
        // 目標が変わったら再計算
        .onChange(of: appearanceViewModel.appearance.goal) { _ in
            refreshData()
        }
    }
    
    private func refreshData() {
        // ここで依存を注入して計算させる
        historyViewModel.calculateHistory(
            dailySteps: stepViewModel.dailyStepCounts,
            dailyGoal: appearanceViewModel.appearance.goal
        )
    }
}