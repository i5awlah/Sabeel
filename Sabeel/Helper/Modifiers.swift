//
//  Modifiers.swift
//  Sabeel
//
//  Created by hoton on 04/08/1444 AH.
//

import Foundation
import SwiftUI



struct Toast: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isShowing: Bool
    @AppStorage("ShowToast") var ShowToast : Bool = true
    
    func body(content: Content) -> some View {
        ZStack {
            content
            toastView
        }
    }
    
    private var toastView: some View {
        VStack {
            if ShowToast{
                if isShowing {
                   VStack {
                       
                        Text("Changes may take time to reflect on your child's device")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .font(.customFont(size: 14))
                            .padding(.vertical)
                            .frame(maxWidth: .infinity)
                            .background(.gray.opacity(0.8))
                        Button{
                            ShowToast = false
                        }label: {
                            Text("Don't show again")
                                .foregroundColor(colorScheme == .dark ?  .lightGray: .darkGray)
                                .font(.customFont(size: 14))
                                .underline()
                                .padding(.bottom, 8)
                              
                                
                        }
                    }
                   .frame(maxWidth: .infinity)
                   .background(Color.gray.opacity(0.5))
                    .cornerRadius(8)
                    .onTapGesture {
                        isShowing = false
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                            isShowing = false
                        }
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 18)
        .animation(.easeInOut(duration: 0.3), value: isShowing)
        .transition(.opacity)
        
    }
}
extension View {
    func toast(isShowing: Binding<Bool>) -> some View {
        self.modifier(Toast(isShowing: isShowing))
    }
}



