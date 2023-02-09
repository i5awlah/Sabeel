//
//  SplashScreen.swift
//  Sabeel
//
//  Created by Khawlah on 06/02/2023.
//

import SwiftUI

struct SplashScreen: View {
    
    @AppStorage("isUserOnboarded") var isUserOnboarded: Bool = false
    @State var isEnded : Bool = false
    @State var isAvailableiCloud : Bool = false // should be check from iCloud
    
    var body: some View {
        if isEnded {
            if isAvailableiCloud {
                CloudNotAvailableView()
            } else {
                if !isUserOnboarded {
                    OnboardingView()
                } else {
                    PecsView()
                }
            }
        } else {
            // video, if finish set isEnded to true
            Text("End")
                .onTapGesture {
                    isEnded.toggle()
                }
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
