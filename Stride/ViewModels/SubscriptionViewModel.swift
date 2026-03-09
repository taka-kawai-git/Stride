import SwiftUI
import RevenueCat

// MARK: - Product ID
// TODO: Replace with actual product ID from App Store Connect / RevenueCat dashboard
private let kPremiumEntitlementID = "Stride Pro"
private let kMonthlyProductID     = "com.gmail.dev.apps.taka.Stride.monthly"
private let kAnnualProductID      = "com.gmail.dev.apps.taka.Stride.yearly"
private let kLifetimeProductID    = "com.gmail.dev.apps.taka.Stride.lifetime"

@MainActor
class SubscriptionViewModel: ObservableObject {
    static let shared = SubscriptionViewModel()

    @Published var isPremium: Bool = false
    @Published var monthlyPackage: Package?
    @Published var annualPackage: Package?
    @Published var lifetimePackage: Package?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private init() {}

    // MARK: - Public API

    func refreshStatus() async {
        do {
            let info = try await Purchases.shared.customerInfo()
            isPremium = info.entitlements[kPremiumEntitlementID]?.isActive == true
        } catch {
            isPremium = false
        }
    }

    func loadOfferings() async {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        do {
            let offerings = try await Purchases.shared.offerings()
            let packages = offerings.current?.availablePackages ?? []
            monthlyPackage = packages.first { $0.storeProduct.productIdentifier == kMonthlyProductID }
            annualPackage   = packages.first { $0.storeProduct.productIdentifier == kAnnualProductID }
            lifetimePackage = packages.first { $0.storeProduct.productIdentifier == kLifetimeProductID }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func purchase(_ package: Package) async {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        do {
            let result = try await Purchases.shared.purchase(package: package)
            if result.userCancelled { return }
            isPremium = result.customerInfo.entitlements[kPremiumEntitlementID]?.isActive == true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restore() async {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        do {
            let info = try await Purchases.shared.restorePurchases()
            isPremium = info.entitlements[kPremiumEntitlementID]?.isActive == true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
