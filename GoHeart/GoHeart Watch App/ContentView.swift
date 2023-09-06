//
//  ContentView.swift
//  GoHeart Watch App
//
//  Created by Hidde van der Ploeg during the watchOS workshop at iOSDevUK 2023
//  Follow me on [Twitter](https://x.com/hiddevdploeg) or [Mastodon](https://mastodon.design/@hidde) for more watchOS inspiration.
//


import SwiftUI

struct ContentView: View {
    
    /// Highest HeartRate measured
    @AppStorage("highestValue") private var highestValue = 0.0
    
    /// Lowest HeartRate measured
    @AppStorage("lowestValue") private var lowestValue = 0.0
    
    @State private var sensor = HeartRateFetcher()
    
    // This is only to test your UI in the simulator, please remove when testing on device
    private let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    @State private var selection: Int = 0
    
    @Namespace var valueSpace
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selection) {
                
                Button(action: {
                    selection = 1
                }, label: {
                    HeartValueView(heartRate: sensor.heartRate, inToolbar: false)
                })
                .buttonStyle(.plain)
                .matchedGeometryEffect(id: "heart", in: valueSpace,isSource: selection == 0)
                .tag(0)
                
                VStack {
                    Spacer()
                    ValueView(value: highestValue, title: "Highest")
                    ValueView(value: lowestValue, title: "Lowest")
                    Spacer()
                }
                .containerBackground(Color.red.gradient, for: .tabView)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            selection = 0
                        }, label: {
                            HeartValueView(heartRate: sensor.heartRate, inToolbar: true)
                                .matchedGeometryEffect(id: "heart", in: valueSpace, isSource: selection != 0)
                        })
                        .buttonStyle(.plain)
                    }
                }
                .tag(1)
                
                ListDemoView()
                .tag(2)
            }
            .navigationDestination(for: Int.self, destination: { item in
                ListDemoDetailsView(item: item)
            })
        }
        .animation(.default, value: selection)
        .sensoryFeedback(.decrease, trigger: lowestValue)
        .sensoryFeedback(.increase, trigger: highestValue)
        .tabViewStyle(.verticalPage)
        .task {
            await sensor.startSensor()
        }
        .onReceive(timer) { _ in
            sensor.heartRate = Double.random(in: 100..<190)
        }
        .onChange(of: sensor.heartRate) { oldValue, newValue in
            if newValue > oldValue {
                checkHighestValue(with: newValue)
            } else {
                checkLowestValue(with: newValue)
            }
        }
    }
    
    private func checkLowestValue(with heartRate: Double) {
        guard !lowestValue.isZero else {
            lowestValue = heartRate
            return
        }
        
        if heartRate < lowestValue {
            lowestValue = heartRate
        }
        
    }
    
    private func checkHighestValue(with heartRate: Double) {
        guard !highestValue.isZero else {
            highestValue = heartRate
            return
        }
        
        if heartRate > highestValue {
            highestValue = heartRate
        }
    }
}

