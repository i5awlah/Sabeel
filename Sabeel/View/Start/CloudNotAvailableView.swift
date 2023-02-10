//
//  CloudNotAvailableView.swift
//  Sabeel
//
//  Created by Khawlah on 08/02/2023.
//

import SwiftUI

struct CloudNotAvailableView: View {
    
    let image = "connectiCloud"
    let title = "Can’t connect to iCloud!"
    let description = "Please make sure that your apple ID is existing in your device settings."
    
    var body: some View {
        SingleOnboardingView(
            image: image,
            title: title,
            description: description
        )
    }
}

struct CloudNotAvailableView_Previews: PreviewProvider {
    static var previews: some View {
        CloudNotAvailableView()
    }
}
