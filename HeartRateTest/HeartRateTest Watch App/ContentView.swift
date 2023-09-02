//
//  ContentView.swift
//  HeartRateTest Watch App
//
//  Created by Hidde van der Ploeg on 28/08/2023.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @StateObject private var sensor = HeartRateFetcher()
    
    @AppStorage("highestValue") private var highestValue = 0.0
    @AppStorage("lowestValue") private var lowestValue = 0.0
    
    @State private var selection = 0
    @Namespace private var heartRate
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selection) {
                
                Button(action: {
                    selection = 1
                }, label: {
                    HeartView(heartRate: sensor.heartRate, inToolBar: false)
                })
                .buttonStyle(.plain)
                .matchedGeometryEffect(id: "heart", in: heartRate, isSource: selection == 0)
                .tag(0)
                
            
                VStack(spacing: 8) {
                    Spacer()
                    ValueView(title: "Highest", value: highestValue)
                    ValueView(title: "Lowest", value: lowestValue)
                    Spacer()
                }
                .scenePadding()
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            selection = 0
                        }, label: {
                            HeartView(heartRate: sensor.heartRate, inToolBar: true)
                        })
                        .buttonStyle(.plain)
                        .matchedGeometryEffect(id: "heart", in: heartRate, isSource: selection == 1)
                    }
                }
                .containerBackground(Color.red.gradient, for: .tabView) // watchOS 10
                .tag(1)
            }
            .tabViewStyle(.verticalPage(transitionStyle: .automatic)) // watchOS 10
            .animation(.default, value: sensor.heartRate)
            .animation(.default, value: selection)
            .sensoryFeedback(.increase, trigger: sensor.heartRate)  // watchOS 10
        }
        .task {
            await sensor.startSensor()
        }
        .onChange(of: sensor.heartRate) { oldValue, newValue in
            if newValue > oldValue {
                checkHighestValue(with: newValue)
            } else {
                checkLowestValue(with: newValue)
            }
        }
    }
    
    func checkHighestValue(with heartRate: Double) {
        guard !highestValue.isZero else {
            highestValue = heartRate
            return
        }
        
        if heartRate > highestValue {
            highestValue = heartRate
        }
    }
    
    func checkLowestValue(with heartRate: Double) {
        guard !lowestValue.isZero else {
            lowestValue = heartRate
            return
        }
        
        if heartRate < lowestValue {
            lowestValue = heartRate
        }
    }
}

struct ValueView : View {
    let title : LocalizedStringKey
    let value : Double
    
    var body: some View {
        HStack {
            Text(title)
                .bold()
                .foregroundStyle(.secondary)
            Spacer()
            Text("\(value, specifier: "%.0f")")
                .foregroundStyle(.primary)
                .font(.headline.monospacedDigit())
        }
        .fontDesign(.rounded)
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.quinary)
        }
    }
}

struct HeartView : View {
    let heartRate : Double
    let inToolBar : Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.red.opacity(0.2))
            Group {
                Image(systemName: "heart.fill")
                    .imageScale(.large)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.red)
                    .symbolEffect(.bounce, value: heartRate)
                    .opacity(0.25)
                    .transition(.opacity)
                    .animation(.default, value: inToolBar)
                    .font(.system(size: inToolBar ? 21 : 80, weight: .bold, design: .rounded).monospacedDigit())
                Text("\(heartRate, specifier: "%.0f")")
                    .transition(.identity)
                    .contentTransition(.numericText(value: heartRate))
                    .font(.system(size: inToolBar ? 17 : 68, weight: .bold, design: .rounded).monospacedDigit())
            }
            .id("value")
        }
    }
}



final class HeartRateFetcher : ObservableObject {
    
    @Published var heartRate : Double = 0.0
    
    private let healthStore = HKHealthStore()
    private let heartRateQuantity = HKUnit(from: "count/min")
    
    @MainActor
    func startSensor() async {
        await autorizeHealthKit()
        startQuery(for: .heartRate)
    }
    
    func autorizeHealthKit() async {
          
        // Define the identifiers that create quantity type objects. (In our case: It's just HearRate)
        let healthKitTypes: Set = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!]
        
         // Requests permission to save and read the specified data types.
        try? await healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes)
    }
    
    
    private func startQuery(for quantityTypeIdentifier: HKQuantityTypeIdentifier) {
            
            // The device we're using to collect the HeartRate
            let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
            
            // A query that returns changes to the HealthKit store, including a snapshot of new changes and continuous monitoring as a long-running query.
            let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = { query, samples, deletedObjects, queryAnchor, error in
                // A sample that represents a quantity, including the value and the units.
                guard let samples = samples as? [HKQuantitySample] else { return }
                self.process(samples, type: quantityTypeIdentifier)
            }
            
            // It gives the ability to receive a snapshot of data, and then on subsequent calls, a snapshot of what has changed.
            let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
            query.updateHandler = updateHandler

            // query execution
            healthStore.execute(query)
        }
    
    
    private func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {

        for sample in samples {
            if type == .heartRate {
                self.heartRate = sample.quantity.doubleValue(for: heartRateQuantity)
            }
        }
    }
}
