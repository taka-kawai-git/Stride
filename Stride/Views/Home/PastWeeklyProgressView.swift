
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
            
            // レポートリスト
            LazyVStack(spacing: 12) {
                ForEach(historyViewModel.reports) { report in
                    VStack(spacing: 0) {
                        HStack(spacing: 12) { // 各要素間のスペースを指定
                        
                        // 1. 左側のテキストエリア
                        VStack(alignment: .leading, spacing: 4) {
                            Text(report.dateRangeString())
                                .font(.headline)
                                .lineLimit(1) // 改行防止
                                .minimumScaleFactor(0.8) // 文字が長い場合に少し縮小を許容
                            Text("\(report.totalSteps) 歩")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(width: 110, alignment: .leading) // ★ここが重要: 幅を固定して揃える
                        
                        // 2. プログレスバー (Spacerの代わりに配置)
                        AnimatedGradientBar(
                                progress: report.progress,
                                // お使いのappearanceViewModelにcolorIDなどがなければ、
                                // 任意のID文字列や、reportの状態に応じたIDを渡してください
                                gradientID: self.appearanceViewModel.appearance.gradientID
                            )
                            .frame(height: 12) // バーの高さを少し太く調整（好みで）
                        
                        // 3. 右側のパーセンテージ
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(report.percentageValue)%")
                                .font(.title3.bold())
                                .foregroundStyle(report.progress >= 1.0 ? .green : .primary)
                        }
                        .frame(width: 50, alignment: .trailing) 
                        }
                        .padding(.vertical, 12)
                        
                        Divider()
                        .padding(.horizontal, -12)
                    }
                }
            }
        }
        .onAppear {
            if historyViewModel.reports.isEmpty {
                refreshData()
            }
        }
        .onChange(of: stepViewModel.dailyStepCounts) { _ in refreshData() }
        .onChange(of: appearanceViewModel.appearance.goal) { _ in refreshData() }
    }
    
    private func refreshData() {
        // ここで依存を注入して計算させる
        historyViewModel.calculateHistory(
            dailySteps: stepViewModel.dailyStepCounts,
            dailyGoal: appearanceViewModel.appearance.goal
        )
    }
}

struct AnimatedGradientBar: View {
    let progress: Double
    let gradientID: String
    
    // アニメーション用の状態変数。最初は0にしておく。
    @State private var animatedProgress: CGFloat = 0
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                // 背景のトラック
                Capsule()
                    .fill(Color.gray.opacity(0.15))
                
                // グラデーションの進捗バー
                Capsule()
                    .fill(gradient(for: gradientID)) // ここでグラデーション関数を使用
                    .frame(width: proxy.size.width * animatedProgress)
            }
        }
        // Viewが表示された瞬間にアニメーションを開始
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                // 1.0 (100%) を超えないように制限
                animatedProgress = min(CGFloat(progress), 1.0)
            }
        }
        // データ更新時にアニメーション付きで追従させる場合
        .onChange(of: progress) { newValue in
            withAnimation(.easeOut(duration: 1.0)) {
                animatedProgress = min(CGFloat(newValue), 1.0)
            }
        }
    }
}
