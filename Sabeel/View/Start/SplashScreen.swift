//
//  SplashScreen.swift
//  Sabeel
//
//  Created by Khawlah on 06/02/2023.
//

import SwiftUI
import AVKit

struct SplashScreen: View {
    
    @StateObject var cloudViewModel = CloudViewModel()
    @AppStorage("isUserOnboarded") var isUserOnboarded: Bool = false
    @State var isEnded : Bool = false
    @Environment(\.colorScheme) var colorScheme
    let Video = AVPlayer(url: Bundle.main.url(forResource: "SplashScreenLight", withExtension: "mp4")!)
    
    
    var body: some View {
        Group {
            if isEnded {
                if cloudViewModel.iCloudAvailable {
                    if !isUserOnboarded {
                        OnboardingView()
                    } else {
                        if (cloudViewModel.currentUser != nil) {
                            if cloudViewModel.isChild {
                                PecsView()
                            } else {
                                TabBar()
                            }
                        } else {
                            ChooseUserView()
                        }
                    }
                } else {
                    CloudNotAvailableView()
                }
            } else {
                GeometryReader{ geo in
                  
                        VideoPlayer(player:Video)
                            .disabled(true)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .edgesIgnoringSafeArea(.all)
                            .onAppear {
                                Video.play()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                                    Video.pause()
                                    isEnded = true
                                }
                            
                    }
                        VideoPlayer(player:Video)
                            .disabled(true)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .edgesIgnoringSafeArea(.all)
                            .onAppear {
                                Video.play()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                                    Video.pause()
                                    isEnded = true
                                }
                            }
                }
            }
        }
        .environmentObject(cloudViewModel)
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
            .environmentObject(CloudViewModel())
    }
}
