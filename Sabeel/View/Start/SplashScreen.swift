//
//  SplashScreen.swift
//  Sabeel
//
//  Created by Khawlah on 06/02/2023.
//

import SwiftUI

struct SplashScreen: View {
    
    @EnvironmentObject var cloudViewModel: CloudViewModel
    @AppStorage("isUserOnboarded") var isUserOnboarded: Bool = false
    @State var isEnded : Bool = false
    
    var body: some View {
        if isEnded {
            if cloudViewModel.iCloudAvailable {
                if !isUserOnboarded {
                    OnboardingView()
                } else {
                    if (cloudViewModel.currentUser != nil) {
                        PecsView()
                    } else {
                        ChooseUserView()
                    }
                }
            } else {
                CloudNotAvailableView()
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
            .environmentObject(CloudViewModel())
    }
}
