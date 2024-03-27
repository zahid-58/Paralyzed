//
//  SummaryView.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 19.02.24.
//

import SwiftUI
import HealthKit

struct SummaryView: View {
    var body: some View {
        ScrollView(.vertical){
            VStack(alignment: .leading){
                
                SummaryMetricView(
                    title: "Paralysis Count",
                    value: 2
                        .formatted(.number.precision(.fractionLength(0))))
                .accentColor(.yellow)
                
                SummaryMetricView(
                title: "Max. Heart Rate",
                value: 170
                    .formatted(.number.precision(.fractionLength(0))) + " bpm").accentColor(.red)
            }
            .scenePadding()
        }
        .navigationTitle("Summary")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SummaryMetricView: View {
    var title: String
    var value: String
    
    var body: some View {
        Text(title)
        Text(value)
            .font(.system(.title2, design: .rounded).lowercaseSmallCaps()
            )
            .foregroundColor(.accentColor)
        Divider()
    }
}

#Preview {
    SummaryView()
}
