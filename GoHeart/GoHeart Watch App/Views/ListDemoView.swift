//
//  ListDemoView.swift
//  GoHeart Watch App
//
//  Created by Hidde van der Ploeg during the watchOS workshop at iOSDevUK 2023
//  Follow me on [Twitter](https://x.com/hiddevdploeg) or [Mastodon](https://mastodon.design/@hidde) for more watchOS inspiration.
//

import SwiftUI

struct ListDemoView: View {
    var body: some View {
        List(1..<13) { item in
            NavigationLink(value: item) {
                HStack {
                    Text("Item")
                    Spacer()
                    Image(systemName: "\(item).circle.fill")
                        .symbolRenderingMode(.hierarchical)
                }
                .padding()
            }
        }
        .navigationTitle("Cool List")
        .containerBackground(Color.red.gradient, for: .navigation)
        .listStyle(.carousel)
    }
}

#Preview {
    ListDemoView()
}
