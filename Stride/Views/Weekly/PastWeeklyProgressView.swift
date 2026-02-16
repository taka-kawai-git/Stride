
import SwiftUI

struct PastWeeklyProgressView: View {
    @ObservedObject var stepViewModel: StepViewModel
    @ObservedObject var appearanceViewModel: AppearanceViewModel
    
    @StateObject private var historyViewModel = PastWeeklyProgressViewModel()
    
    // -------- init --------

    init(stepViewModel: StepViewModel, appearanceViewModel: AppearanceViewModel) {
        self._stepViewModel = ObservedObject(wrappedValue: stepViewModel)
        self._appearanceViewModel = ObservedObject(wrappedValue: appearanceViewModel)
    }

    // -------- body --------
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // -------- Report List --------

            LazyVStack(spacing: 12) {
                ForEach(historyViewModel.reports) { report in
                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                        
                            // -------- Date & Steps --------

                            VStack(alignment: .leading, spacing: 4) {
                                Text(report.dateRangeString())
                                    .font(.headline)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                Text("\(report.totalSteps) 歩")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(width: 110, alignment: .leading)
                            
                            // -------- Progress Bar --------

                            AnimatedGradientBar(
                                    progress: report.progress,
                                    gradientID: self.appearanceViewModel.appearance.gradientID
                                )
                                .frame(height: 12)
                            
                            // -------- Percentage --------

                            VStack(alignment: .trailing, spacing: 4) {
                                (Text("\(report.percentageValue)")
                                    .font(.custom("AvenirNext-Bold", size: 20))
                                + Text("%")
                                    .font(.custom("AvenirNext-Bold", size: 12)))
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


    // ======================================== Private Functions ========================================
    
    
    private func refreshData() {
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
                    .fill(AppColors.progressBarTrack)
                
                // グラデーションの進捗バー
                Capsule()
                    .fill(gradient(for: gradientID)) // ここでグラデーション関数を使用
                    .frame(width: animatedProgress > 0 ? max(proxy.size.width * animatedProgress, 8) : 0)
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
