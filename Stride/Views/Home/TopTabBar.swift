//
//  TopTabBar.swift
//  Stride
//

import SwiftUI

struct TopTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [LocalizedStringKey]
    
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { index in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                } label: {
                    VStack(spacing: 8) {
                        Text(tabs[index])
                            .font(.subheadline.weight(selectedTab == index ? .semibold : .regular))
                            .foregroundStyle(selectedTab == index ? .primary : .secondary)
                        
                        // アンダーライン
                        if selectedTab == index {
                            Rectangle()
                                .fill(.primary)
                                .frame(width: 32, height: 2)
                                .matchedGeometryEffect(id: "underline", in: animation)
                        } else {
                            Rectangle()
                                .fill(.clear)
                                .frame(height: 2)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }
}
