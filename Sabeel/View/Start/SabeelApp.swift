//
//  SabeelApp.swift
//  Sabeel
//
//  Created by Khawlah on 03/02/2023.
//

import SwiftUI

@main
struct SabeelApp: App {
    
    @StateObject var cloudViewModel = CloudViewModel()
    
    var body: some Scene {
        WindowGroup {
            SplashScreen()
                .environmentObject(cloudViewModel)
        }
    }
}
