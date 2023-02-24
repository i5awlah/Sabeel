//
//  SettingsView.swift
//  Sabeel
//
//  Created by Ashwaq on 14/02/2023.
//

import SwiftUI

struct SettingsView: View {
    
    var settingsDataLinkChild = SettingTile(title: NSLocalizedString("Connect your special child", comment: ""), icon: "link.icloud")
    
    var settingsDataLinkParent = SettingTile(title: NSLocalizedString("Connect with your parent", comment: ""), icon: "link.icloud")
    
    var settingsDataSchedule = SettingTile(title:NSLocalizedString("Schedule PECS", comment: ""), icon: "list.bullet.clipboard")
    
    
    @AppStorage("number0fColumns") var gridRows = 2
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var cloudViewModel: CloudViewModel
    
    var body: some View {
    
        NavigationStack {
            ZStack {
                List {
                    
                    // 1- link
                    if cloudViewModel.isChild {
                        NavigationLink(destination: cloudViewModel.childParentModel == nil ? AnyView(ChildQRView()) : AnyView(AlreadyLinkedView())) {
                            SettingsCellView(data: settingsDataLinkParent)
                        }
                    } else {
                        NavigationLink {
                            cloudViewModel.childParentModel == nil ?
                            AnyView(AddChildView()) : AnyView(AlreadyLinkedView())
                        } label: {
                            SettingsCellView(data: settingsDataLinkChild)
                        }
                    }
                    // 4- change user type
                    if cloudViewModel.childParentModel == nil {
                        Button{
                            cloudViewModel.deleteUser()
                        }label: {
                            HStack{
                                Image("switchUser")
                                    .resizable().frame(width: 35, height: 30).background(Color("buttonBlue")).foregroundColor(.white).cornerRadius(5)
                                Text("Change user type").font(Font.customFont(size: 16))
                                
                            }.padding(EdgeInsets(.init(top: 8, leading: 0, bottom: 8, trailing: 0)))
                            
                        }.foregroundColor(colorScheme == .dark ?  .white : .black)
                    }
                    
                    // 2- Schedule
                    if !cloudViewModel.isChild {
                        if (cloudViewModel.childParentModel != nil) {
                            NavigationLink(destination: SchedulePecsView()) {
                                SettingsCellView(data: settingsDataSchedule)
                            }
                        } else {
                            SettingsCellView(data: settingsDataSchedule)
                                .onTapGesture {
                                    cloudViewModel.showNoLinkView.toggle()
                                }
                        }
                    }
                    
                    // 3-
                    HStack{
                        Image(systemName:"photo.on.rectangle").frame(width: 35, height: 30).background(Color("buttonBlue")).foregroundColor(.white).cornerRadius(5)
                        Text("Number of PECS per row:").font(Font.customFont(size: 16))
                        Spacer()
                
                        
                        Picker("", selection: $gridRows) {
                            ForEach(1...5, id: \.self) { number in
                                Text("\(number)")
                            }
                        }.font(Font.customFont(size: 14))
                            .labelsHidden()
                        
                    }.padding(EdgeInsets(.init(top: 8, leading: 0, bottom: 8, trailing: 0)))
                    
               
                }
                .navigationTitle("Settings")
                
            
            }

        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(CloudViewModel())
    }
}

struct SettingTile : Identifiable{
    let id = UUID()
    let title: String
    let icon :String
    
    init(title:String, icon: String) {
        self.title = title
        self.icon = icon
    }
}
