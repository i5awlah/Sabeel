//
//  AlreadyLinkedView.swift
//  Sabeel
//
//  Created by Ashwaq Azan on 01/08/1444 AH.
//

import SwiftUI


struct AlreadyLinkedView: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack(spacing:20) {
            if colorScheme == .dark {
                Image("linkeddark")
                    .resizable()
                    .scaledToFit()
                .padding(.horizontal, 16) .padding(.vertical, 32)
                
            } else {
                Image("linked")
                    .resizable()
                    .scaledToFit()
                .padding(.horizontal, 16) .padding(.vertical, 32) }
            
            Text("Already connected")
                .bold()
                .font(.customFont(size: 30))
                .foregroundColor(.darkBlue)
            
            Text("This account is already connected with another one")
                .font(.customFont(size: 20))
                .foregroundColor(.darkGray)
                .multilineTextAlignment(.center)
            
            /*
             here add button to delete relationship with this action:
            cloudViewModel.deleteChildParent()
             But before do this action show an alert to confirm and make it clear that all custom PECS added by the parent will be deleted
             */
            
     
            
        }.background(Color.White)
        .padding(.horizontal, 24)
    }
}

struct AlreadyLinkedView_Previews: PreviewProvider {
    static var previews: some View {
        AlreadyLinkedView()
    }
}

