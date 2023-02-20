//
//  PicList.swift
//  Sabeel
//
//  Created by hoton on 06/02/2023.
//

import SwiftUI
import AVFoundation

struct PicList: View {
    let spacing: CGFloat = 20
    @AppStorage("number0fColumns") var number0fColumns = 2
    @Binding var isEditing : Bool
    let pecs: [MainPecs]
    
    @EnvironmentObject var cloudViewModel : CloudViewModel
    
    @State var audioPlayer: AVAudioPlayer!
    
    var coulmns: [GridItem] {
        Array(repeating: GridItem(.flexible(),spacing: spacing), count: number0fColumns)
        
    }
    
    init(isEditing: Binding<Bool>) {
        _isEditing = isEditing
        self.pecs = []
    }
    
    init(isEditing: Binding<Bool>, pecs: [MainPecs]) {
        self.pecs = pecs
        _isEditing = isEditing
    }

        var body: some View {
        ScrollView {
            LazyVGrid(columns: coulmns, spacing: spacing) {
                if (cloudViewModel.childParentModel != nil) {
                    if cloudViewModel.isChild == false {
                        AddCell()
                    }
                        if cloudViewModel.isChild {
                            ForEach(cloudViewModel.homeContents.filter({ HomeContent in
                                return HomeContent.isItTime || HomeContent.isShown
                            }), id: \.id) { item in
                                Button{
                                    handleCellClicked(item: item)
                                } label: {
                                    PicCell(isEditing: $isEditing, homeContent: item)
                                        .shimmering(
                                            active: item.pecs.imageURL == nil
                                        )
                                }
                            }
                        }
                        
                    else{
                        ForEach(cloudViewModel.homeContents, id: \.id) { item in
                         //   let index = cloudViewModel.homeContents.firstIndex(of: item)
                            
                            PicCell(isEditing: $isEditing, homeContent: item)
                                .shimmering(
                                    active: item.pecs.imageURL == nil
                                )
                        }
                    }
                    }
                
                else {
                    ForEach(pecs, id: \.id) { pecs in
                        Button{
                          //  if cloudViewModel.isChild {
                            guard let url = Helper.shared.isEnglishLanguage() ? pecs.audioURL : pecs.arabicAudioURL else { return }
                                playPecsSound(url: url)
                           // }
                        } label: {
                            PicCell(isEditing: $isEditing, pecs: pecs)
                
                        }
                        
                    }
                }
            }.padding (.horizontal)
        }
        .refreshable {
            cloudViewModel.fetchHomeContent()
        }
       
        }

  


    }


struct PicList_Previews: PreviewProvider {
    static var previews: some View {
        PicList(isEditing: Binding<Bool>.constant(false))
            .environmentObject(CloudViewModel())
    }
}

extension PicList {
    
    func handleCellClicked(item: HomeContent) {
        // sound
        if item.pecs is MainPecs {
            let pecs: MainPecs = item.pecs as! MainPecs
            // check language
            if let url = Helper.shared.isEnglishLanguage() ? pecs.audioURL : pecs.arabicAudioURL {
                playPecsSound(url: url)
            }
            
        } else {
            if let url = item.pecs.audioURL {
                playPecsSound(url: url)
            }
        }
        cloudViewModel.addChildRequest(homeContent: item)
    }
    
    func playPecsSound(url: URL) {
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: url)
            self.audioPlayer.play()
            
        } catch {
            print(error.localizedDescription)
        }
    }
}


