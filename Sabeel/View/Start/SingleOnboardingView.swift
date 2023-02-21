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
    
    init(onboarding: OnboardingType) {
        self.image = onboarding.image
        self.title = onboarding.title
        self.description = onboarding.description
    }
    
    init(image: String, title: String, description: String) {
        self.image = image
        self.title = title
        self.description = description
    }
    
    var body: some View {
        VStack(spacing:20) {
            Image(image)
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 16)
            
            Text(title.localized)
                .bold()
                .font(.customFont(size: 30))
                .foregroundColor(.darkBlue)
            
            Text(description.localized)
                .font(.customFont(size: 20))
                .foregroundColor(.darkGray)
                .multilineTextAlignment(.center)
                .frame(height: 90, alignment: .top)
        }
        .padding(.horizontal, 24)
        .frame(height: UIScreen.main.bounds.height * 0.55, alignment: .bottom)
    }
}

struct SingleOnbordingView_Previews: PreviewProvider {
    static var previews: some View {
        SingleOnboardingView(onboarding: .alwayConnected)
    }
}
