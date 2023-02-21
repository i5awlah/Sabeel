//
//  SettingsCellView.swift
//  Sabeel
//
//  Created by Khawlah on 21/02/2023.
//

import SwiftUI

struct SettingsCellView: View {
    
    let data: SettingTile
    
    var body: some View {
        
        HStack{
            Image(systemName:data.icon).frame(width: 35, height: 30).background(Color("buttonBlue")).foregroundColor(.white).cornerRadius(5)
            Text(data.title).font(Font.customFont(size: 16))
            
        }.padding(EdgeInsets(.init(top: 8, leading: 0, bottom: 8, trailing: 0)))
        
    }
}

struct SettingsCellView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsCellView(
            data: SettingTile(
                title: "",
                icon: ""
            )
        )
    }
}
