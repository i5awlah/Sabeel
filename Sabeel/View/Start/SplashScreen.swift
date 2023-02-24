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
   let Video1 = AVPlayer(url: Bundle.main.url(forResource: "SplashScreenDark", withExtension: "mp4")!)
    
    
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
                    if colorScheme == .dark {
                        VideoPlayer(player:Video1)
                            .disabled(true)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .edgesIgnoringSafeArea(.all)
                            .background(.black)
                            .onAppear {
                                Video1.play()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                                    Video1.pause()
                                    isEnded = true
                                }
                            }
                    } else {
                        VideoPlayer(player:Video)
                            .disabled(true)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .edgesIgnoringSafeArea(.all)
                            .background(.white)
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
