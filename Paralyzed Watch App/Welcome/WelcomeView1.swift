//
//  WelcomeView1.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 26.08.24.
//

import SwiftUI

struct WelcomeView1: View {
    @Binding var isWelcomeScreenOver: Bool
    
    var body: some View {
        NavigationView{
            VStack(spacing: 8) {
                Text("Willkommen bei Paralyzed!")
                    .font(.headline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 15)
                    .padding()
                
                
                VStack {
                    Text("Klicken Sie auf \"START\", um mit der Führung der App zu beginnen.")
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    
                    NavigationLink(destination: WelcomeView2(isWelcomeScreenOver: $isWelcomeScreenOver) .navigationBarBackButtonHidden(true),
                                   label: {
                        HStack(spacing: 8) {
                            Text("START")
                        }
                    })
                    .background(Capsule().fill(Color.green))
                    .foregroundColor(.black)
                    .frame(width: 100)
                    .padding(.all)
                }
            }
        }
        
    }
}

#Preview {
    WelcomeView1(isWelcomeScreenOver: .constant(false))
}
