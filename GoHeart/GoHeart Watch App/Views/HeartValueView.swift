//
//  HeartValueView.swift
//  GoHeart Watch App
//
//  Created by Hidde van der Ploeg during the watchOS workshop at iOSDevUK 2023
//  Follow me on [Twitter](https://x.com/hiddevdploeg) or [Mastodon](https://mastodon.design/@hidde) for more watchOS inspiration.
//

import SwiftUI

struct HeartValueView : View {
    @Environment(\.isLuminanceReduced) private var isReduced
    let heartRate : Double
    let inToolbar : Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.red)
                .opacity(isReduced ? 0 : 0.25)
                .scenePadding(.horizontal)
            Image(systemName: "heart.fill")
                .imageScale(.large)
                .foregroundStyle(.red)
                .font(.system(size: inToolbar ? 24 : 80, weight: .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.2)
                .opacity(isReduced ? 0 : 1)
                .symbolEffect(.bounce, value: heartRate)
            Text("\(heartRate, specifier: "%.0f")")
                .font(.system(size: inToolbar ? 16 : 64, weight: .bold, design: .rounded).monospacedDigit())
                .lineLimit(1)
                .minimumScaleFactor(0.2)
                .animation(.default, value: heartRate)
                .transition(.identity)
                .contentTransition(.numericText(value: heartRate))
                .redacted(reason: isReduced ? .placeholder : [])
        }
    }
}
