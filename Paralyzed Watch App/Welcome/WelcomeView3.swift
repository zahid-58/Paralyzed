//
//  WelcomeView3.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 26.08.24.
//

import SwiftUI

struct WelcomeView3: View {
    @Binding var isWelcomeScreenOver: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack{
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(spacing: 5) {
                ScrollView {  // ScrollView nur um den Text herum
                    Text("Streichen Sie nach rechts, um Herzfrequenzlimit sowie Vibration und Alarm in den Einstellungen anzupassen. Steichen Sie nach links, um auf die Übersichtseite zu gelangen.")
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
                }
                Spacer()
                
                HStack(spacing: 50) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.left")
                            Text("Back")
                        }
                    })
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(destination: WelcomeView4(isWelcomeScreenOver: $isWelcomeScreenOver)) {
                        HStack(spacing: 6) {
                            Text("Next")
                            Image(systemName: "arrow.right")
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}

#Preview {
    WelcomeView3(isWelcomeScreenOver: .constant(false))
}
