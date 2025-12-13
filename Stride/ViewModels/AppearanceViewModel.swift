import SwiftUI

@MainActor
class AppearanceViewModel: ObservableObject {
    @Published var appearance: SharedAppearance = .default
    @Published var isLoaded: Bool = false

    init() {
        loadAppearance()
    }
    
    func loadAppearance() {
        self.appearance = SharedStore.loadAppearance()
        self.isLoaded = true
    }
    
    func updateAppearance(_ newAppearance: SharedAppearance) {
        self.appearance = newAppearance
        SharedStore.saveAppearance(newAppearance)
    }
}