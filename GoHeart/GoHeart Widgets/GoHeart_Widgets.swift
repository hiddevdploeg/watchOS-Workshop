//
//  GoHeart_Widgets.swift
//  GoHeart Widgets
//
//  Created by Hidde van der Ploeg during the watchOS workshop at iOSDevUK 2023
//  Follow me on [Twitter](https://x.com/hiddevdploeg) or [Mastodon](https://mastodon.design/@hidde) for more watchOS inspiration.
//


import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

    func recommendations() -> [AppIntentRecommendation<ConfigurationAppIntent>] {
        // Create an array with all the preconfigured widgets to show.
        [AppIntentRecommendation(intent: ConfigurationAppIntent(), description: "Example Widget")]
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct GoHeart_WidgetsEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Image(systemName: "heart.fill")
                .opacity(0.2)
            Text("\(entry.configuration.heartRate, specifier: "%.0f")")
                .transition(.identity)
                .contentTransition(.numericText(value: entry.configuration.heartRate))
                .widgetAccentable()
        }
        .foregroundStyle(.red)
    }
}

@main
struct GoHeart_Widgets: Widget {
    let kind: String = "GoHeart_Widgets"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            GoHeart_WidgetsEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryInline, .accessoryRectangular])
    }
}

// Examples used for Preview
extension ConfigurationAppIntent {
    fileprivate static var lowHR: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.heartRate = 54
        return intent
    }
    
    fileprivate static var highHR: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.heartRate = 130
        return intent
    }
}

#Preview(as: .accessoryRectangular) {
    GoHeart_Widgets()
} timeline: {
    SimpleEntry(date: .now, configuration: .lowHR)
    SimpleEntry(date: .now, configuration: .highHR)
}
