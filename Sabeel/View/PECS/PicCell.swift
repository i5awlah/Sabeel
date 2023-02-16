//
//  PicCell.swift
//  Sabeel
//
//  Created by Khawlah on 06/02/2023.
//

import SwiftUI
import Shimmer
import CloudKit

struct PicCell: View {
   
    @State var isHidden :Bool = false
    @Binding var isLoading : Bool
    @Binding var isEditing : Bool
    let homeContent: HomeContent?
    let pecs: PecsModel
    
    @EnvironmentObject var cloudViewModel : CloudViewModel
    
    init(isEditing: Binding<Bool>, homeContent: HomeContent) {
        _isEditing = isEditing
        self.homeContent = homeContent
        self.pecs = homeContent.pecs
    }
    
    init(pecs: PecsModel) {
        self.pecs = pecs
        self.homeContent = nil
        _isEditing = .constant(false)
    }
    
    var body: some View {
        GeometryReader { geo in
            let TextSize = min(geo.size.width * 0.5, 16)
            let imageWidth: CGFloat = min (160, geo.size.width * 0.6 )
            VStack(spacing: 5){
                HStack{
                    Spacer()
                    if cloudViewModel.isChild == false, (cloudViewModel.childParentModel != nil) {
                        if isEditing
                        {
                            Button{
                                guard let homeContent else { return }
                                cloudViewModel.deleteHomeContent(homeContent: homeContent)
                            }label: {
                                Image(systemName: "x.circle")
                                    .foregroundColor(.red)
                            }
                            
                        } else {
                            Button{
                                //   PECS.hidePECS()
                                isHidden.toggle()
                            }
                        label: {
                            Image(systemName: isHidden ? "eye" : "eye.slash")
                                .foregroundColor(.darkGray)
                        }
                            
                            
                        }
                    }
                }
              
                AsyncImage(url: pecs.imageURL) { image in
                    image.resizable()
                         .scaledToFit()
                         .frame(width: imageWidth)
                    
                } placeholder: {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageWidth)
                }
//                .onAppear(
//                    perform: isLoading.toggle()
//              )
     
                Text(pecs.name)
                    .foregroundColor(cloudViewModel.isChild ?  .darkGreen : .darkBlue)
                    .font(.system(size: TextSize))
            } .padding(15)
                .frame (width: geo.size.width, height: geo.size.height)
                .background(LinearGradient(gradient: Gradient(colors: [cloudViewModel.isChild ? .lightGreen: .lightBlue, .white]), startPoint: .top, endPoint: .bottom))
                .cornerRadius(10)
            
            
            
        }
        .frame (height: 170)
        .overlay(
            isHidden ? Rectangle().foregroundColor(.gray).opacity(0.5)
                .cornerRadius(10) : nil
            )
            
        
    }
}

struct AddCell: View {
    var body: some View {
        GeometryReader { geo in
            let TextSize = min(geo.size.width * 0.5, 16)
            let imageWidth: CGFloat = min (30, geo.size.width * 0.6 )
            NavigationLink{
                AddPecsView()
            }label:{
            VStack{
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageWidth, height: 50)
                Text("Add PECS")
                    .font(.system(size: TextSize))
            } .padding(15)
                .frame (width: geo.size.width, height: geo.size.height)
                .background(.white)
                .cornerRadius(10)
                .foregroundColor(.darkBlue)
        }
        }
        .frame (height: 170)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.darkBlue, style: StrokeStyle(lineWidth: 1, dash: [13, 5]))
        )
        
    }
}


struct PicCell_Previews: PreviewProvider {
    static var previews: some View {
        PicCell( isLoading: Binding<Bool>.constant(false), isEditing:Binding.constant(false), isChild: false, pecs: PecsModel(imageURL: nil, audioURL: nil, name: "qq", category: "eat"))
        AddCell()
    }
}


