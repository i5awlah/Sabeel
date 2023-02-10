//
//  SingleOnbordingView.swift
//  Sabeel
//
//  Created by Khawlah on 09/02/2023.
//

import SwiftUI

struct SingleOnboardingView: View {
    
    @AppStorage("isUserOnboarded") var isUserOnboarded: Bool = false
    
    let image: String
    let title: String
    let description: String
    let isLastOnboarding: Bool
    
    init(onboarding: OnboardingType) {
        self.image = onboarding.image
        self.title = onboarding.title
        self.description = onboarding.description
        self.isLastOnboarding = onboarding == .settings
    }
    
    init(image: String, title: String, description: String) {
        self.image = image
        self.title = title
        self.description = description
        self.isLastOnboarding = false
    }
    
    var body: some View {
        VStack(spacing:20) {
            Image(image)
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 16)
            
            Text(title)
                .bold()
                .font(.system(size: 30))
                .foregroundColor(.darkBlue)
            
            Text(description)
                .font(.system(size: 20))
                .foregroundColor(.darkGray)
                .multilineTextAlignment(.center)
            
            if isLastOnboarding {
                Button {
                    withAnimation(.spring()) {
                        isUserOnboarded = true
                    }
                } label: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.buttonBlue)
                        .frame(height: 48)
                        .overlay(content: {
                            Text("Get Started")
                                .font(.system(size: 20))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        })
                }
                .padding(.horizontal, 24)
            }
            
        }
        .padding(.horizontal, 24)
    }
}

struct SingleOnbordingView_Previews: PreviewProvider {
    static var previews: some View {
        SingleOnboardingView(onboarding: .alwayConnected)
    }
}
