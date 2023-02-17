//
//  PecsView.swift
//  Sabeel
//
//  Created by Khawlah on 06/02/2023.
//

import SwiftUI

struct PecsView: View {
    @EnvironmentObject var cloudViewModel : CloudViewModel
    @State var isEditing = false
    
    @State private var pecs: [PecsModel] = []
    
    var body: some View {
        NavigationStack{
            VStack{
                if (cloudViewModel.childParentModel != nil) {
                    PicList(isEditing: $isEditing)
                } else {
                    PicList(pecs: pecs)
                        .onAppear{
                            print("fetch pecs without home content")
                            cloudViewModel.fetchSharedPecs { pecs in
                                self.pecs = pecs
                            }
                        }
                }
            }
            .navigationTitle("PECS")
            .foregroundColor(cloudViewModel.isChild ? .darkGreen : .darkBlue )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if cloudViewModel.isChild{
                        NavigationLink {
                            SettingsView()
                        } label: {
                            Image(systemName: "gear")
                                .foregroundColor(.darkGreen)
                        }
                    }
                    else{
                        if (cloudViewModel.childParentModel != nil) {
                            Button{ isEditing.toggle() }label: {
                                Text( isEditing ? "Done" : "Edit")}
                            .foregroundColor(.darkBlue)
                        }
                    }
                }
            }
            
        }
    }
}

struct PecsView_Previews: PreviewProvider {
    static var previews: some View {
            PecsView().environmentObject(CloudViewModel())
        }
 
}
