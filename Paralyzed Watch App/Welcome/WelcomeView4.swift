//
//  WelcomeView4.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 26.08.24.
//

import SwiftUI

struct WelcomeView4: View {
    @Binding var isWelcomeScreenOver: Bool
    @Environment(\.dismiss) var dismiss
    @State var isPressed: Bool = false
    
    var body: some View {
        NavigationView{
            ZStack{
                Color.black.edgesIgnoringSafeArea(.all)
                VStack(spacing: 10) {
                    Text("Wichtig: ")
                        .fontWeight(.bold)
                        .underline()
                    Text("Vor der Nutzung die Watch bitte vollständig aufladen. Klicken Sie auf \"Los\" um in die App zu gelangen.")
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack(spacing: 48) {
                        Button(action: {
                            dismiss()
                        }, label: {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.left")
                                Text("Back")
                            }
                        })
                        .buttonStyle(PlainButtonStyle())
                        
                        
                        Button(action: {
                            isPressed = true
                            isWelcomeScreenOver = true
                        }, label: {
                            HStack(spacing: 6) {
                                Text("Los")
                            }
                        })
                        .foregroundColor(.black)
                        .background(Capsule().fill(Color.green))
                        .fontWeight(.bold)
                        
                    }
                    
                    .padding(.all)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    WelcomeView4(isWelcomeScreenOver: .constant(false))
}
