import SwiftUI
import RevenueCat

struct PaywallView: View {
    @StateObject private var subscription = SubscriptionViewModel.shared
    @Environment(\.dismiss) private var dismiss

    /// The plan the user has tapped. Defaults to annual (best value).
    @State private var selectedPlan: Plan = .annual

    enum Plan { case monthly, annual }

    // MARK: - Preview gradients for the hero banner

    private let previewGradients: [LinearGradient] = [
        gradient(for: "peachCoralOrange"),
        gradient(for: "lavenderPurpleIndigo"),
        gradient(for: "oliveBrown"),
        gradient(for: "pastelSunrise"),
        gradient(for: "pastelOcean"),
        gradient(for: "solidPurple"),
        gradient(for: "solidBlue"),
        gradient(for: "pastelCottonCandy"),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {

                    // -------- Hero --------
                    heroSection

                    // -------- Feature List --------
                    featuresSection
                        .padding(.top, 32)

                    // -------- Plan Selector --------
                    planSelector
                        .padding(.top, 28)
                        .padding(.horizontal, 20)

                    // -------- CTA Button --------
                    ctaButton
                        .padding(.top, 20)
                        .padding(.horizontal, 20)

                    // -------- Restore / Legal --------
                    legalFooter
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.background, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .task { await subscription.loadOfferings() }
            .alert("エラー", isPresented: Binding(
                get: { subscription.errorMessage != nil },
                set: { if !$0 { subscription.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { subscription.errorMessage = nil }
            } message: {
                Text(subscription.errorMessage ?? "")
            }
        }
    }

    // MARK: - Sections

    private var heroSection: some View {
        VStack(spacing: 16) {
            // Color-swatch mosaic
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 4),
                spacing: 6
            ) {
                ForEach(previewGradients.indices, id: \.self) { i in
                    previewGradients[i]
                        .frame(height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)

            // Badge
            Label("プレミアム", systemImage: "crown.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.95, green: 0.76, blue: 0.25), Color(red: 0.90, green: 0.55, blue: 0.10)],
                        startPoint: .leading, endPoint: .trailing
                    ),
                    in: Capsule()
                )

            Text("すべてのカラーテーマを\nアンロックしよう")
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Text("グラデーション・単色・パステルの\n全テーマが使い放題")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
    }

    private var featuresSection: some View {
        VStack(spacing: 0) {
            ForEach(features) { feature in
                HStack(spacing: 14) {
                    Image(systemName: feature.icon)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(feature.color)
                        .frame(width: 32)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(feature.title)
                            .font(.subheadline.weight(.semibold))
                        Text(feature.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)

                if feature.id != features.last?.id {
                    Divider().padding(.leading, 70)
                }
            }
        }
        .background(AppColors.secondaryBackground, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .padding(.horizontal, 20)
    }

    private var planSelector: some View {
        VStack(spacing: 10) {
            planCard(
                plan: .annual,
                title: "年間プラン",
                badge: "お得",
                priceLabel: annualPriceLabel,
                perMonthLabel: annualPerMonthLabel
            )
            planCard(
                plan: .monthly,
                title: "月間プラン",
                badge: nil,
                priceLabel: monthlyPriceLabel,
                perMonthLabel: nil
            )
        }
    }

    private func planCard(
        plan: Plan,
        title: String,
        badge: String?,
        priceLabel: String,
        perMonthLabel: String?
    ) -> some View {
        let isSelected = selectedPlan == plan
        return Button {
            withAnimation(.spring(duration: 0.2)) { selectedPlan = plan }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.subheadline.weight(.semibold))
                        if let badge {
                            Text(badge)
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(Color.orange, in: Capsule())
                        }
                    }
                    if let perMonthLabel {
                        Text(perMonthLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Text(priceLabel)
                    .font(.subheadline.weight(.semibold))

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary.opacity(0.4))
                    .font(.title3)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppColors.secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(
                                isSelected ? Color.accentColor : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var ctaButton: some View {
        Button {
            Task {
                let pkg: RevenueCat.Package? = selectedPlan == .annual ? subscription.annualPackage : subscription.monthlyPackage
                guard let pkg else { return }
                try? await subscription.purchase(pkg)
                if subscription.isPremium { dismiss() }
            }
        } label: {
            Group {
                if subscription.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("プレミアムを始める")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .foregroundStyle(.white)
            .background(
                LinearGradient(
                    colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                    startPoint: .leading, endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
        }
        .disabled(subscription.isLoading || currentPackage == nil)
    }

    private var legalFooter: some View {
        VStack(spacing: 10) {
            Button {
                Task { await subscription.restore() }
            } label: {
                Text("購入を復元する")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .disabled(subscription.isLoading)

            Text("購読は自動更新されます。\nApp Storeアカウントに課金されます。")
                .font(.caption2)
                .foregroundStyle(Color.secondary.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    // MARK: - Helpers

    private var currentPackage: RevenueCat.Package? {
        selectedPlan == .annual ? subscription.annualPackage : subscription.monthlyPackage
    }

    private var monthlyPriceLabel: String {
        if let pkg = subscription.monthlyPackage {
            return pkg.storeProduct.localizedPriceString + " / 月"
        }
        return "---"
    }

    private var annualPriceLabel: String {
        if let pkg = subscription.annualPackage {
            return pkg.storeProduct.localizedPriceString + " / 年"
        }
        return "---"
    }

    private var annualPerMonthLabel: String? {
        guard let pkg = subscription.annualPackage else { return nil }
        let monthly = pkg.storeProduct.price / 12
        let formatted = pkg.storeProduct.priceFormatter?.string(from: monthly as NSDecimalNumber) ?? ""
        return "約 \(formatted) / 月"
    }
}

// MARK: - Feature Data

private struct Feature: Identifiable {
    let id = UUID()
    let icon: String
    let color: Color
    let title: String
    let description: String
}

private let features: [Feature] = [
    Feature(
        icon: "paintpalette.fill",
        color: .pink,
        title: "全カラーテーマ",
        description: "グラデーション・単色・パステル 25種類以上"
    ),
    Feature(
        icon: "square.2.layers.3d.fill",
        color: .indigo,
        title: "ウィジェットもカラフルに",
        description: "ロック画面ウィジェットにも全テーマ適用"
    ),
    Feature(
        icon: "sparkles",
        color: .orange,
        title: "今後の新テーマも無料",
        description: "サブスク期間中に追加されるテーマも自動解放"
    ),
]
