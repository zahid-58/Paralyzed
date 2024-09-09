//
//  WelcomeView2.swift
//  Paralyzed Watch App
//
//  Created by Muhammed Zahid Fırat on 26.08.24.
//

import SwiftUI

struct WelcomeView2: View {
    @Binding var isWelcomeScreenOver: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView{
            ZStack{
                Color.black.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                VStack(spacing: 20) {
                    Text("Auf der Startseite befindet sich ein Button \"Tap to activate\", um die Überwachung zu starten.")
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
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
                        
                        NavigationLink(destination: WelcomeView3(isWelcomeScreenOver: $isWelcomeScreenOver)) {
                            HStack(spacing: 6) {
                                Text("Next")
                                Image(systemName: "arrow.right")
                            }
                        }
                        .buttonStyle(PlainButtonStyle())   
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    WelcomeView2(isWelcomeScreenOver: .constant(false))
}
