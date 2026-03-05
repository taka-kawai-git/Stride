import SwiftUI

@MainActor
class SubscriptionViewModel: ObservableObject {
    static let shared = SubscriptionViewModel()

    /// サブスク購入済みかどうか（RevenueCat実装後に置き換え）
    @Published var isPremium: Bool = false
}