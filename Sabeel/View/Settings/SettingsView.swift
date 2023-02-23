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
    @State var DeleteAccount = false
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
                    
                    // 4- Delete account
                    
                    
                }
                .navigationTitle("Settings")
                
                if cloudViewModel.childParentModel == nil {
                    
                    
                    Button {
                        self.DeleteAccount = true
                        
                        
                    } label: {
                        if colorScheme == .dark {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.Dark)
                                .frame(height: 48)
                                .overlay(content: {
                                    Text("Delete Account")
                                        .font(.customFont(size: 20))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.red)
                                })
                                .padding(.bottom,120)
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.white)
                                .frame(height: 48)
                                .overlay(content: {
                                    Text("Delete Account")
                                        .font(.customFont(size: 20))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.red)
                                })
                                .padding(.bottom,120)
                        }
                        
                            
                    }
                    .padding(.horizontal, 24)
                    .alert(isPresented:$DeleteAccount) {
                                Alert(
                                    title: Text("Delete Account"),
                                    message: Text("Are you sure to deletethis account ?"),
                                    primaryButton: .destructive(Text("Yes")) {
                                        cloudViewModel.deleteUser()
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
                    /*
                     here add a cell to delete account with this action:
                     cloudViewModel.deleteUser()
                     But before do this action show an alert to confirm
                     */
                }
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
