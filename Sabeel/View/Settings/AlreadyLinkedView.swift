//
//  AlreadyLinkedView.swift
//  Sabeel
//
//  Created by Ashwaq Azan on 01/08/1444 AH.
//

import SwiftUI


struct AlreadyLinkedView: View {

    var body: some View {
        VStack(spacing:20) {
            Image("linked")
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 16) .padding(.vertical, 32)
            
            Text("Already Linked")
                .bold()
                .font(.customFont(size: 30))
                .foregroundColor(.darkBlue)
            
            Text("This account already linked with another one")
                .font(.customFont(size: 20))
                .foregroundColor(.darkGray)
                .multilineTextAlignment(.center)
            
     
            
        }
        .padding(.horizontal, 24)
    }
}

struct AlreadyLinkedView_Previews: PreviewProvider {
    static var previews: some View {
        AlreadyLinkedView()
    }
}

