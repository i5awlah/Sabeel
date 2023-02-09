//
//  OnbordingView.swift
//  Sabeel
//
//  Created by Khawlah on 06/02/2023.
//

import SwiftUI

struct OnboardingView: View {
    
    @AppStorage("isUserOnboarded") var isUserOnboarded: Bool = false
    @State var selectedOnbordingType: OnbordingType = .alwayConnected
    
    var body: some View {
        ZStack {
            
            TabView(selection: $selectedOnbordingType) {
                
                ForEach(OnbordingType.allCases, id: \.title) { onbording in
                    SingleOnboardingView(
                        image: onbording.image,
                        title: onbording.title,
                        description: onbording.description,
                        isLastOnbording: onbording == .settings
                    )
                    .tag(onbording)
                    .onChange(of: selectedOnbordingType, perform: { newValue in
                        selectedOnbordingType = newValue
                    })
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            if selectedOnbordingType != .settings {
                skipButton
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
                .font(.system(size: 20))
                .foregroundColor(.black)
                .padding(10)
        }
        .padding(.top, 1)
        .padding(.trailing)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .frame(maxHeight: .infinity, alignment: .top)
        .foregroundColor(.secondary)
    }
}

extension OnboardingView {
    func setupAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.darkBlue)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
    }
}

enum OnbordingType: CaseIterable {
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
            return "Alway Connected"
        case .getNotification:
            return "Get Notification"
        case .customizePECS:
            return "Customize PECS"
        case .settings:
            return "Settings"
        }
    }
    
    var description: String {
        switch self {
        case .alwayConnected:
            return "Stay connected with your Special Autistic one in his own PECS way by just a TAP ."
        case .getNotification:
            return "Download the app on both devices to get you special autistic notification."
        case .customizePECS:
            return "Add any pictures that your child want with text, and sound ."
        case .settings:
            return "we hid and jammed everything you need under the settings."
        }
    }
}
