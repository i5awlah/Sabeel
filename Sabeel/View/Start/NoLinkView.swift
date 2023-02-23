//
//  NoLinkView.swift
//  Sabeel
//
//  Created by Khawlah on 22/02/2023.
//

import SwiftUI

struct NoLinkView: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack(spacing :20){
            Image("NoLink")
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 16)
            
            Text("Connect with your special child").multilineTextAlignment(.center)
                .bold()
                .font(.customFont(size: 30))
                .foregroundColor(colorScheme == .dark ? .darkBlue : .darkBlue)
            
            Text("To access this feature you have to connect with your special child app")
                .font(.customFont(size: 20))
                .foregroundColor(colorScheme == .dark ? .white : .darkGray)
                .multilineTextAlignment(.center)
        }  .padding(.horizontal, 24)
    }
}
struct NoLinkView_Previews: PreviewProvider {
    static var previews: some View {
        NoLinkView()
    }
}
