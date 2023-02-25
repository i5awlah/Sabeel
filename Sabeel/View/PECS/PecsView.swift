//
//  PecsView.swift
//  Sabeel
//
//  Created by hoton on 06/02/2023.
//

import SwiftUI

struct PecsView: View {
    @EnvironmentObject var cloudViewModel : CloudViewModel
    @State var isEditing = false
    @State var isToast :Bool = false
    @State private var goToAppLock: Bool = false
    @State private var goToSettings: Bool = false

    @Environment(\.scenePhase) private var scenePhase

    
    var body: some View {
        NavigationStack{
            VStack{
                if (cloudViewModel.childParentModel != nil) {
                    PicList(isEditing: $isEditing, isToast: $isToast)
                } else {
                    Group {
                        if cloudViewModel.isLoading {
                            ProgressView()
                        } else {
                            PicList(isEditing: $isEditing, isToast: $isToast, pecs: cloudViewModel.pecs)
                        }
                    }
                }
            }
            .onChange(of: scenePhase) { phase in
                if phase == .active {
                    if cloudViewModel.childParentModel == nil {
                        if cloudViewModel.isChild {
                            cloudViewModel.fetchChildParent()
                        }
                    }
                }
            }
            .navigationTitle(cloudViewModel.isChild ? "I want ..." : "PECS")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if cloudViewModel.isLoadingHome {
                        ProgressView()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if cloudViewModel.isChild {
                        Image(systemName: "gear").resizable()
                            .frame(width: UIDevice.isIPad ? 40 : 30 , height: UIDevice.isIPad ? 40 : 30)
                            .foregroundColor(.darkGreen)
                            .onTapGesture {
                                goToAppLock.toggle()
                            }
                    } else {
                        
                        Button {
                            cloudViewModel.childParentModel != nil ? isEditing.toggle() : cloudViewModel.showNoLinkView.toggle()
                        } label: {
                            Text( isEditing ? "Done" : "Edit")
                        }
                        .foregroundColor(.darkBlue)
                        
                    }
                }
            }
            .navigationDestination(isPresented: $goToAppLock) {
                AppLockView(goToSettings: $goToSettings, pincode: .init("2023"))
            }
            .navigationDestination(isPresented: $goToSettings) {
                SettingsView()
            }
            
        }.onAppear(){
            let navBarAppearance = UINavigationBarAppearance()

        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.init(cloudViewModel.isChild ? .darkGreen : .darkBlue) as Any]

                UINavigationBar.appearance().standardAppearance = navBarAppearance
        }
        .toast(isShowing: $isToast)
    }
}

struct PecsView_Previews: PreviewProvider {
    static var previews: some View {
            PecsView().environmentObject(CloudViewModel())
        }
 
}
