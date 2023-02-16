//
//  PicCell.swift
//  Sabeel
//
//  Created by Khawlah on 06/02/2023.
//

import SwiftUI
import Shimmer

struct PicCell: View {
    @StateObject var Cloud = CloudViewModel()
   // @StateObject var PECS = PECSViewModel()
    @State var isHidden :Bool = false
    @Binding var isEditing : Bool
    
    var body: some View {
        GeometryReader { geo in
            let TextSize = min(geo.size.width * 0.5, 16)
            let imageWidth: CGFloat = min (50, geo.size.width * 0.6 )
            VStack(spacing: 5){
                HStack{
                    Spacer()
                    if Cloud.isChild == false {
                        if isEditing
                        {
                            Button{
                                //     PECS.deletePECS()
                            }label: {
                                Image(systemName: "x.circle")
                                    .foregroundColor(.red)
                            }}
                        else {
                            Button{
                                //   PECS.hidePECS()
                                isHidden.toggle()
                            }
                        label: {
                            Image(systemName: isHidden ? "eye" : "eye.slash")
                                .foregroundColor(.darkBlue)
                        }
                            
                            
                        }
                    }
                }
                Spacer()
                AsyncImage(url: URL(string: "https://example.com/icon.png")) { image in
                    image.resizable()
                    image.scaledToFit()
                    image.frame(width: imageWidth, height: 50)
                    
                } placeholder: {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageWidth, height: 50)
                }
                Spacer()
                Text("Test")
                    .foregroundColor(Cloud.isChild ?  .darkGreen : .darkBlue)
                    .font(.system(size: TextSize))
            } .padding(15)
                .frame (width: geo.size.width, height: geo.size.height)
                .background(LinearGradient(gradient: Gradient(colors: [Cloud.isChild ? .lightGreen: .lightBlue, .white]), startPoint: .top, endPoint: .bottom))
                .cornerRadius(10)
            
            
            
        }
        .frame (height: 170)
        .overlay(
            isHidden ? Rectangle().foregroundColor(.gray).opacity(0.5)
                .cornerRadius(10) : nil
            )
            
        
    }
}


struct PicCell_Previews: PreviewProvider {
    static var previews: some View {
        PicCell(isEditing:Binding.constant(false))
    }
}


