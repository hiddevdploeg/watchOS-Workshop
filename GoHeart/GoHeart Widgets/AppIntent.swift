//
//  AppIntent.swift
//  GoHeart Widgets
//  Created by Hidde van der Ploeg during the watchOS workshop at iOSDevUK 2023
//  Follow me on [Twitter](https://x.com/hiddevdploeg) or [Mastodon](https://mastodon.design/@hidde) for more watchOS inspiration.
//



import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")

    // An example configurable parameter.
    @Parameter(title: "Heart Rate", default: 0)
    var heartRate: Double
}
