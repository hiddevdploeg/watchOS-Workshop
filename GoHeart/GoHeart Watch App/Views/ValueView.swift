//
//  ValueView.swift
//  GoHeart Watch App
//
//  Created by Hidde van der Ploeg during the watchOS workshop at iOSDevUK 2023
//  Follow me on [Twitter](https://x.com/hiddevdploeg) or [Mastodon](https://mastodon.design/@hidde) for more watchOS inspiration.
//

import SwiftUI

struct ValueView : View {
    let value: Double
    let title: LocalizedStringKey
    
    var body: some View {
        HStack{
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text("\(value, specifier: "%.0f")")
                .foregroundStyle(.primary)
        }
        .padding(12)
        .font(.system(.headline, design: .rounded))
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.quaternary)
        }
        .scenePadding(.horizontal)
    }
}



#Preview {
    ValueView(value: 180, title: "Highest")
}
