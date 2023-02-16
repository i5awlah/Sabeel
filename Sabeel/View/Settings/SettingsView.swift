//
//  SettingsView.swift
//  Sabeel
//
//  Created by Ashwaq on 14/02/2023.
//

import SwiftUI

struct SettingsView: View {
    var settingsData = [
        SettingTile(title: "Link your Autistic ", icon: "link.icloud", navigationDestination: ChildQRView()),
        SettingTile(title:"Scheduled PECS", icon: "list.bullet.clipboard", navigationDestination: SchedulePecsView()),
 
      ];
    @State private var number: Int = 2
    var body: some View {
    
        NavigationStack {
            List {
                ForEach(settingsData) {data in
                    
                    NavigationLink(destination: SchedulePecsView()) {
                        HStack{
                            Image(systemName:data.icon).frame(width: 35, height: 30).background(Color("buttonBlue")).foregroundColor(.white).cornerRadius(5)
                            Text(data.title)
       
                        }.padding(EdgeInsets(.init(top: 8, leading: 0, bottom: 8, trailing: 0)))
                    } .buttonStyle(.plain)
                    
          
                   
               
                }
                
                HStack{
                    Image(systemName:"photo.on.rectangle").frame(width: 35, height: 30).background(Color("buttonBlue")).foregroundColor(.white).cornerRadius(5)
                    Text("Number of PECS per row:")
                    Spacer()
              

                            Picker("", selection: $number) {
                                ForEach(1...5, id: \.self) { number in
                                    Text("\(number)")
                                }
                            }
                                .labelsHidden()

                }.padding(EdgeInsets(.init(top: 8, leading: 0, bottom: 8, trailing: 0)))
            }.navigationTitle("Settings")
            
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

struct SettingTile : Identifiable{
    let id = UUID()
    
    let title: String
    let icon :String
    let navigationDestination :any View
    
    init(title:String, icon: String,navigationDestination :any View) {
        self.title = title
        self.icon = icon
        self.navigationDestination = navigationDestination
        
        
        
   
    }
}

