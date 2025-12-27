import SwiftUI

struct RequestAuthorizationView: View {
    var onRequestAuthorization: () -> Void

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {

                VStack(spacing: 12) {
                    Text("🏃🏻")
                        .font(.system(size: 130))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .background(Color.blue)

                VStack(spacing: 32) {
                    VStack(spacing: 16) {
                        Text("歩数データの連携")
                            .font(.title.bold())
                            .foregroundColor(.primary)
                        
                        Text("Strideは歩数データを活用して、毎日の活動を記録します。次の画面でヘルスケアとの連携を許可してください。")
                            .font(.subheadline)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 32)
                            .lineSpacing(4)
                    }                    
                    Button("続行", action: onRequestAuthorization)
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .padding(.horizontal, 40)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.systemBackground))
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .ignoresSafeArea(edges: .top)
        }
    }
}

#Preview {
    RequestAuthorizationView(onRequestAuthorization: {})
}
