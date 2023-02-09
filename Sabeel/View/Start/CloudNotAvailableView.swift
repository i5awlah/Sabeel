//
//  CloudNotAvailableView.swift
//  Sabeel
//
//  Created by Khawlah on 08/02/2023.
//

import SwiftUI

struct CloudNotAvailableView: View {
    var body: some View {
        SingleOnboardingView(
            image: "connectiCloud",
            title: "Can’t connect to iCloud!",
            description: "Please make sure that your apple ID is existing in your device settings.",
            isLastOnbording: false)
    }
}

struct CloudNotAvailableView_Previews: PreviewProvider {
    static var previews: some View {
        CloudNotAvailableView()
    }
}
