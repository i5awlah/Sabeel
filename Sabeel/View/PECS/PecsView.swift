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
    
    var body: some View {
        NavigationStack{
            VStack{
                PicList(isEditing: $isEditing)
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
                        Button{ isEditing.toggle() }label: {
                            Text( isEditing ? "Close" : "Edit")}
                        .foregroundColor(.darkBlue)
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
