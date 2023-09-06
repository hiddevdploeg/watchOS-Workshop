//
//  ListDemoDetailsView.swift
//  GoHeart Watch App
//
//  Created by Hidde van der Ploeg during the watchOS workshop at iOSDevUK 2023
//  Follow me on [Twitter](https://x.com/hiddevdploeg) or [Mastodon](https://mastodon.design/@hidde) for more watchOS inspiration.
//

import SwiftUI

struct ListDemoDetailsView: View {
    let item: Int
    
    var body: some View {
        VStack {
            Image(systemName: "\(item).circle.fill")
                .symbolRenderingMode(.hierarchical)
                .font(.largeTitle)
        }
        .padding()
        .containerBackground(Color.red.gradient, for: .navigation)
    }
}

#Preview {
    ListDemoDetailsView(item: 12)
}
