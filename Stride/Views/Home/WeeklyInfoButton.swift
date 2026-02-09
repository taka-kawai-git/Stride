
import SwiftUI

struct WeeklyInfoButton: View {
    @State private var showingInfo = false

    var body: some View {
        Button {
            showingInfo = true
        } label: {
            Image(systemName: "info.circle")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
        }
        .popover(
            isPresented: $showingInfo,
            attachmentAnchor: .rect(.bounds),
            arrowEdge: .top
        ) {
            Text("月曜~現在までの合計歩数を週の目標歩数(1日の目標歩数×7)で割った数値が表示されます")
                .font(.footnote)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .presentationCompactAdaptation(.none)
                .padding(15)
                .frame(maxWidth: 260, alignment: .leading)
        }
    }
}
