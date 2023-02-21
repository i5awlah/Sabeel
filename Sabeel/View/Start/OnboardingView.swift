//
//  OnbordingView.swift
//  Sabeel
//
//  Created by Khawlah on 06/02/2023.
//

import SwiftUI

struct OnboardingView: View {
    
    @AppStorage("isUserOnboarded") var isUserOnboarded: Bool = false
    @State var selectedOnboardingType: OnboardingType = .alwayConnected
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            TabView(selection: $selectedOnboardingType) {
                
                ForEach(OnboardingType.allCases, id: \.title) { onboarding in
                    SingleOnboardingView(onboarding: onboarding)
                    .tag(onboarding)
                    .onChange(of: selectedOnboardingType, perform: { newValue in
                        selectedOnboardingType = newValue
                    })
                }
                .rotation3DEffect(.degrees(Helper.shared.isEnglishLanguage() ? 0 : 180), axis: (x: 0, y: 1, z: 0))
            }
            .flipsForRightToLeftLayoutDirection(Helper.shared.isEnglishLanguage() ? false : true)
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            if selectedOnboardingType != .settings {
                skipButton
            } else {
                getStartedButton
            }
        }
        .onAppear {
            setupAppearance()
        }
    }
}

struct OnbordingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}

extension OnboardingView {
    var skipButton: some View {
        Button {
            withAnimation(.spring()) {
                isUserOnboarded = true
            }
        } label: {
            Text("skip")
                .font(.customFont(size: 20))
                .foregroundColor(.black)
                .padding(10)
        }
        .padding(.top, 1)
        .padding(.trailing)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .frame(maxHeight: .infinity, alignment: .top)
        .foregroundColor(.secondary)
    }
    var getStartedButton: some View {
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
                        .font(.customFont(size: 20))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                })
        }
        .padding(.horizontal, 24)
    }
}

extension OnboardingView {
    func setupAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.darkBlue)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
    }
}

enum OnboardingType: CaseIterable {
    case alwayConnected
    case getNotification
    case customizePECS
    case settings
    
    var image: String {
        switch self {
        case .alwayConnected:
            return "onbording1"
        case .getNotification:
            return "onbording2"
        case .customizePECS:
            return "onbording3"
        case .settings:
            return "onbording4"
        }
    }
    
    var title: String {
        switch self {
        case .alwayConnected:
            return "Always Connected"
        case .getNotification:
            return "Get Notification"
        case .customizePECS:
            return "Customize PECS"
        case .settings:
            return "Schedule PECS"
        }
    }
    
    var description: String {
        switch self {
        case .alwayConnected:
            return "Stay connected with your Special Autistic one in his own PECS way by just a TAP."
        case .getNotification:
            return "Download the app on both devices to get notifications from your special autistic."
        case .customizePECS:
            return "Add any custom PECS for your own Autistic along with text, and sound."
        case .settings:
            return "Schedule when to show and hide certain pictures to help you maintain your Autistic routine."
        }
    }
}
