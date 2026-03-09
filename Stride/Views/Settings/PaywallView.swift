import SwiftUI
import RevenueCat

struct PaywallView: View {
    @ObservedObject private var subscription = SubscriptionViewModel.shared
    @Environment(\.dismiss) private var dismiss

    /// The plan the user has tapped. Defaults to annual (best value).
    @State private var selectedPlan: Plan = .annual

    enum Plan { case monthly, annual, lifetime }

    // Gold gradient for PRO badge
    private let goldGradient = LinearGradient(
        colors: [Color(red: 0.95, green: 0.80, blue: 0.30), Color(red: 0.85, green: 0.55, blue: 0.15)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    // CTA button gradient (tealBlueIndigo theme)
    private let ctaGradient = LinearGradient(
        colors: [.teal, .blue, .indigo],
        startPoint: .leading, endPoint: .trailing
    )

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()
                    .frame(maxHeight: 40)

                // -------- Title --------
                titleSection

                // -------- Features Grid --------
                featuresGrid
                    .padding(.top, 36)

                // -------- Plan Selector --------
                planSelector
                    .padding(.top, 24)
                    .padding(.horizontal, 20)

                // -------- CTA Button --------
                ctaButton
                    .padding(.top, 16)
                    .padding(.horizontal, 20)

                // -------- Footer --------
                legalFooter
                    .padding(.top, 14)

                Spacer()
            }
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
            .task {
                await subscription.refreshStatus()
                await subscription.loadOfferings()
            }
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

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(spacing: 14) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("Stride")
                    .font(.custom("Avenir-Black", size: 36))
                Text("PRO")
                    .font(.custom("Avenir-Black", size: 13))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(goldGradient, in: Capsule())
                    .offset(y: -8)
            }

            Text("すべての機能を\nアンロックしよう")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }

    // MARK: - Features List

    private var featuresGrid: some View {
        VStack(spacing: 16) {
            featureRow(
                icon: "calendar",
                gradientColors: [.orange, .yellow],
                title: String(localized: "過去１年間のデータが閲覧可能")
            )
            featureRow(
                icon: "paintpalette.fill",
                gradientColors: [.pink, .purple],
                title: String(localized: "より多くのカラーデザインが利用可能")
            )
            featureRow(
                icon: "square.2.layers.3d.fill",
                gradientColors: [.indigo, .blue],
                title: String(localized: "より多くのウィジェットが利用可能 (予定)")
            )
        }
        .padding(.horizontal, 28)
    }

    private func featureRow(icon: String, gradientColors: [Color], title: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradientColors.map { $0.opacity(0.2) },
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
            }
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Plan Selector (3 cards side by side)

    private var planSelector: some View {
        HStack(spacing: 10) {
            planCard(
                plan: .monthly,
                title: String(localized: "月間"),
                priceLabel: monthlyPriceLabel,
                subLabel: String(localized: "いつでも解約"),
                badge: nil,
                isRecommended: false
            )
            planCard(
                plan: .annual,
                title: String(localized: "年間"),
                priceLabel: annualPriceLabel,
                subLabel: annualPerMonthLabel ?? String(localized: "いつでも解約"),
                badge: String(localized: "おすすめ"),
                isRecommended: true
            )
            planCard(
                plan: .lifetime,
                title: String(localized: "買い切り"),
                priceLabel: lifetimePriceLabel,
                subLabel: String(localized: "一回限りの支払い"),
                badge: nil,
                isRecommended: false
            )
        }
    }

    private func planCard(
        plan: Plan,
        title: String,
        priceLabel: String,
        subLabel: String,
        badge: String?,
        isRecommended: Bool
    ) -> some View {
        let isSelected = selectedPlan == plan
        return Button {
            withAnimation(.spring(duration: 0.25, bounce: 0.2)) { selectedPlan = plan }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))

                Text(priceLabel)
                    .font(.system(size: 16, weight: .bold, design: .rounded))

                Text(subLabel)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, isRecommended ? 22 : 18)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected && isRecommended
                          ? Color.accentColor.opacity(0.08)
                          : AppColors.secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(
                                isSelected ? Color.accentColor : Color.secondary.opacity(0.15),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .overlay(alignment: .top) {
                if let badge {
                    Text(badge)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(goldGradient, in: Capsule())
                        .offset(y: -10)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - CTA

    private var ctaButton: some View {
        Button {
            Task {
                let pkg: RevenueCat.Package? = switch selectedPlan {
                case .annual: subscription.annualPackage
                case .monthly: subscription.monthlyPackage
                case .lifetime: subscription.lifetimePackage
            }
                guard let pkg else { return }
                await subscription.purchase(pkg)
                if subscription.isPremium { dismiss() }
            }
        } label: {
            Group {
                if subscription.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Subscribe")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .foregroundStyle(.white)
            .background(ctaGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.blue.opacity(0.35), radius: 12, y: 6)
        }
        .disabled(subscription.isLoading || currentPackage == nil)
    }

    // MARK: - Footer

    private var legalFooter: some View {
        HStack(spacing: 20) {
            Button {
                Task { await subscription.restore() }
            } label: {
                Text("復元")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .disabled(subscription.isLoading)

            Text("利用規約")
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(.secondary)

            Text("プライバシー")
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Helpers

    private var currentPackage: RevenueCat.Package? {
        switch selectedPlan {
        case .annual: subscription.annualPackage
        case .monthly: subscription.monthlyPackage
        case .lifetime: subscription.lifetimePackage
        }
    }

    private var monthlyPriceLabel: String {
        if let pkg = subscription.monthlyPackage {
            return pkg.storeProduct.localizedPriceString
        }
        return "---"
    }

    private var annualPriceLabel: String {
        if let pkg = subscription.annualPackage {
            return pkg.storeProduct.localizedPriceString
        }
        return "---"
    }

    private var annualPerMonthLabel: String? {
        guard let pkg = subscription.annualPackage else { return nil }
        let monthly = pkg.storeProduct.price / 12
        let formatted = pkg.storeProduct.priceFormatter?.string(from: monthly as NSDecimalNumber) ?? ""
        return String(format: String(localized: "約 %@/月"), formatted)
    }

    private var lifetimePriceLabel: String {
        if let pkg = subscription.lifetimePackage {
            return pkg.storeProduct.localizedPriceString
        }
        return "---"
    }
}
