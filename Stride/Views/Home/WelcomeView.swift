import SwiftUI

struct WelcomeView: View {
    @State private var isStarted = false
    var onRequestAuthorization: () -> Void

    var body: some View {
        ZStack {
            if isStarted {
                RequestAuthorizationView(onRequestAuthorization: onRequestAuthorization)
                    .transition(.move(edge: .trailing))
            } else {
                GeometryReader { proxy in
                    VStack(spacing: 0) {

                        // -------- App Icon --------

                        VStack(spacing: 12) {
                            Image("AppIconTransparent")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 160, height: 160)
                                .cornerRadius(32)
                                .shadow(radius: 10)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .background(AppColors.onboardingHero)

                        // -------- Welcome Message --------
                        
                        VStack(spacing: 32) {
                            VStack(spacing: 16) {
                                Text("Strideへようこそ！")
                                    .font(.largeTitle.bold())
                                    .foregroundColor(.primary)
                                
                                Text("Strideは一目で歩数データを確認できる美しいアプリです")
                                    .font(.subheadline)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 32)
                                    .lineSpacing(4)
                            }
                            
                            Button("はじめる") {
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    isStarted = true
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .padding(.horizontal, 40)
                            .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(AppColors.background)
                    }
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .ignoresSafeArea(edges: .top)
                }
                .transition(.move(edge: .leading))
            }
        }
    }
}

#Preview {
    WelcomeView(onRequestAuthorization: {})
}
