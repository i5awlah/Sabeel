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
                    if cloudViewModel.isChild {
                        Button{
                            if audioPlayer.isPlaying == false {
                                self.audioPlayer.startPlayback(audio: item.pecs.audioURL!)
                            }
                            cloudViewModel.addChildRequest(homeContent: item)
                            
                        } label: {
                            PicCell(isLoading: $isLoading, isEditing: $isEditing,isChild: cloudViewModel.isChild ,pecs: item.pecs)
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


