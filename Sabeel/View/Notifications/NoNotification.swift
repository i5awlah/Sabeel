//
//  NoNotification.swift
//  Sabeel
//
//  Created by hoton on 26/07/1444 AH.
//

import SwiftUI

struct NoNotification: View {
    var body: some View {
        VStack{
            Image("noNotification")
                .resizable()
                .scaledToFit()
            Text("No Notifications yet!")
                .font(.customFont(size: 20))
        } .padding(.horizontal)
    }
}

struct NoNotification_Previews: PreviewProvider {
    static var previews: some View {
        NoNotification()
    }
}
