//
//  SessionPagingView.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 18.02.24.
//

import SwiftUI

struct SessionPagingView: View {
    @State private var selection: Tab = .startStop
    
    enum Tab {
        case summary ,startStop, settings
    }
    
    
    var body: some View {
        TabView(selection: $selection){
            SummaryView().tag(Tab.summary)
            StartStopView().tag(Tab.startStop)
            SettingsView().tag(Tab.settings)
        }
    }
}

//#Preview {
//    SessionPagingView()
//}
