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
    @State private var pecs: [MainPecs] = []

    @State private var goToAppLock: Bool = false
    @State private var goToSettings: Bool = false

    
    var body: some View {
        NavigationStack{
            VStack{
                if (cloudViewModel.childParentModel != nil) {
                    PicList(isEditing: $isEditing)
                } else {
                    PicList(isEditing: $isEditing, pecs: pecs)
                        .onAppear{
                            print("fetch pecs without home content")
                            cloudViewModel.fetchSharedPecs { pecs in
                                self.pecs = pecs
                            }
                        }
                }
            }
            .navigationTitle("PECS")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if cloudViewModel.isChild{
                        Image(systemName: "gear")
                            .foregroundColor(.darkGreen)
                            .onTapGesture {
                                goToAppLock.toggle()
                            }
                    } else {
                        if (cloudViewModel.childParentModel != nil) {
                            Button{ isEditing.toggle() }label: {
                                Text( isEditing ? "Done" : "Edit")}
                            .foregroundColor(.darkBlue)
                        }
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
    }
}

struct PecsView_Previews: PreviewProvider {
    static var previews: some View {
            PecsView().environmentObject(CloudViewModel())
        }
 
}
