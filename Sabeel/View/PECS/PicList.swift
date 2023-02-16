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
    @ObservedObject var audioPlayer = AudioPlayer()
    @Binding var isEditing : Bool
    @State var isLoading : Bool = false
    let pecs: [PecsModel]
    
    @EnvironmentObject var cloudViewModel : CloudViewModel
    
    var coulmns: [GridItem] {
        Array(repeating: GridItem(.flexible(),spacing: spacing), count: number0fColumns)
        
    }
    
    init(isEditing: Binding<Bool>) {
        _isEditing = isEditing
        self.pecs = []
    }
    
    init(pecs: [PecsModel]) {
        self.pecs = pecs
        _isEditing = .constant(false)
    }

        var body: some View {
        ScrollView {
            LazyVGrid(columns: coulmns, spacing: spacing) {
                if (cloudViewModel.childParentModel != nil) {
                    if cloudViewModel.isChild == false {
                        AddCell()
                    }
                    ForEach(cloudViewModel.homeContents, id: \.id) { item in
                        if cloudViewModel.isChild {
                            Button{
                                if audioPlayer.isPlaying == false {
                                    self.audioPlayer.startPlayback(audio: item.pecs.audioURL!)
                                }
                                cloudViewModel.addChildRequest(homeContent: item)
                                
                            } label: {
                                PicCell(isEditing: $isEditing, homeContent: item)
                                    .shimmering(
                                        active: isLoading
                                    )
                            }
                        }
                        else{
                            PicCell(isLoading: $isLoading, isEditing: $isEditing,isChild: cloudViewModel.isChild ,pecs: item.pecs)
                                .shimmering(
                                    active: isLoading
                                )
                        }
                        
                    }
                }
                else {
                    ForEach(pecs, id: \.id) { item in
                        Button{
                            if cloudViewModel.isChild {
                                // sound
                            }
                        } label: {
                            PicCell(pecs: item)
                            //                            .shimmering(
                            //                                active: parent
                            //                            )
                        }
                        
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


