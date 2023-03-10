//
//  CloudNotAvailableView.swift
//  Sabeel
//
//  Created by Khawlah on 08/02/2023.
//

import SwiftUI

struct CloudNotAvailableView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var cloudViewModel : CloudViewModel
    
    let image = "connectiCloud"
    let title = "Can’t connect to iCloud!"
    let description = "Please make sure that you're signed in with your apple ID and enabled iCloud Drive in device settings"
    
    var body: some View {
        SingleOnboardingView(
            image: image,
            title: title,
            description: description
        )
        .toolbar(.hidden, for: .tabBar)
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                cloudViewModel.checkiCloudAvailable()
            }
        }
    }
}

struct CloudNotAvailableView_Previews: PreviewProvider {
    static var previews: some View {
        CloudNotAvailableView()
            .environmentObject(CloudViewModel())
    }
}
