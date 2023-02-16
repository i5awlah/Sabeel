//
//  PicList.swift
//  Sabeel
//
//  Created by Khawlah on 06/02/2023.
//

import SwiftUI

struct PicList: View {
    let spacing: CGFloat = 20
    @AppStorage("number0fColumns") var number0fColumns = 2
    @Binding var isEditing : Bool
    
    @EnvironmentObject var cloudViewModel : CloudViewModel
    
    var coulmns: [GridItem] {
        Array(repeating: GridItem(.flexible(),spacing: spacing), count: number0fColumns)
        
    }

        var body: some View {
        ScrollView {
            LazyVGrid(columns: coulmns, spacing: spacing) {
                if cloudViewModel.isChild == false {
                    AddCell()
                }
                ForEach(cloudViewModel.homeContents, id: \.id) { item in
                    Button{
                        if cloudViewModel.isChild {
                            // sound
                            cloudViewModel.addChildRequest(homeContent: item)
                        }
                    } label: {
                        PicCell(isEditing: $isEditing, homeContent: item)
//                            .shimmering(
//                                active: parent
//                            )
                    }
                 
                }
            }.padding (.horizontal)
        }
       
        }

  


    }


struct PicList_Previews: PreviewProvider {
    static var previews: some View {
        PicList(isEditing: Binding<Bool>.constant(false))
            .environmentObject(CloudViewModel())
    }
}
