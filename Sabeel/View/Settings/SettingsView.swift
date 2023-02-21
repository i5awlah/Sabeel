//
//  SettingsView.swift
//  Sabeel
//
//  Created by Ashwaq on 14/02/2023.
//

import SwiftUI

struct SettingsView: View {
    
    var settingsDataLinkChild = SettingTile(title: NSLocalizedString("Link your Autistic child", comment: ""), icon: "link.icloud")
    
    var settingsDataLinkParent = SettingTile(title: NSLocalizedString("Link with your parent", comment: ""), icon: "link.icloud")
    
    var settingsDataSchedule = SettingTile(title:NSLocalizedString("Schedule PECS", comment: ""), icon: "list.bullet.clipboard")
    
    @AppStorage("number0fColumns") var gridRows = 2
    
    @EnvironmentObject var cloudViewModel: CloudViewModel
    
    var body: some View {
    
        NavigationStack {
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
