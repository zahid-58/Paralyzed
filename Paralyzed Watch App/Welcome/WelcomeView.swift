//
//  WelcomeView.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 23.08.24.
//

import SwiftUI

struct WelcomeView: View {
    let right = "👉🏼"
    let left = "👈🏼"
    
    @Binding var isWelcomeScreenOver: Bool
    @State var isPressed: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Willkommen bei Paralyzed!")
                .font(.headline)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 6)
            
            Spacer(minLength: 10)
            
            VStack(spacing: 4) {
                Text("\(left) Swipe nach links für Übersicht")
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom)
                
                Text("Swipe nach rechts für Einstellungen \(right)")
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 6)
            
            Button(action: {
                isPressed = true
                isWelcomeScreenOver = true
            }) {
                Text("Los")
            }
            .background(Capsule().fill(Color.green))
            .foregroundColor(.black)
            .frame(width: 90)
            .padding(.bottom, 10)
        }
    }
}

#Preview {
    WelcomeView(isWelcomeScreenOver: .constant(false))
}
