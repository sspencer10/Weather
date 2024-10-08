//
//  Weather_WidgetsLiveActivity.swift
//  Weather Widgets
//
//  Created by Steven Spencer on 8/18/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct Weather_WidgetsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct Weather_WidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: Weather_WidgetsAttributes.self) { context in
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

extension Weather_WidgetsAttributes {
    fileprivate static var preview: Weather_WidgetsAttributes {
        Weather_WidgetsAttributes(name: "World")
    }
}

extension Weather_WidgetsAttributes.ContentState {
    fileprivate static var smiley: Weather_WidgetsAttributes.ContentState {
        Weather_WidgetsAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: Weather_WidgetsAttributes.ContentState {
         Weather_WidgetsAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: Weather_WidgetsAttributes.preview) {
   Weather_WidgetsLiveActivity()
} contentStates: {
    Weather_WidgetsAttributes.ContentState.smiley
    Weather_WidgetsAttributes.ContentState.starEyes
}
