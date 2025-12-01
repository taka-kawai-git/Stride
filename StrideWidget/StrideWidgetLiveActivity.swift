//
//  StrideWidgetLiveActivity.swift
//  StrideWidget
//
//  Created by 川井孝之 on 2025/11/13.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct StrideWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct StrideWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: StrideWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension StrideWidgetAttributes {
    fileprivate static var preview: StrideWidgetAttributes {
        StrideWidgetAttributes(name: "World")
    }
}

extension StrideWidgetAttributes.ContentState {
    fileprivate static var smiley: StrideWidgetAttributes.ContentState {
        StrideWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: StrideWidgetAttributes.ContentState {
         StrideWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: StrideWidgetAttributes.preview) {
   StrideWidgetLiveActivity()
} contentStates: {
    StrideWidgetAttributes.ContentState.smiley
    StrideWidgetAttributes.ContentState.starEyes
}
