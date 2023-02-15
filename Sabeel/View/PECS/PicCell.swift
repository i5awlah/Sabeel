//
//  PicCell.swift
//  Sabeel
//
//  Created by Khawlah on 06/02/2023.
//

import SwiftUI

struct PicCell: View {
    @StateObject var Cloud = CloudViewModel()
    @StateObject var PECS = PECSViewModel()
    
    @State var parent : Bool = true
    @Binding var isEditing : Bool
    var body: some View {
        VStack{
            HStack{
                Spacer()
                if Cloud.isChild == false {
                    if isEditing
                    {
                        Button{
                            PECS.deletePECS()
                        }label: {
                            Image(systemName: "x.circle")
                                .foregroundColor(.red)
                        }}
                        else {
                            Button{
                                PECS.hidePECS()
                            }
                        label: {
                            Image(systemName: "eye.slash")
                                .foregroundColor(.darkBlue)
                        }
                       
                        
                    }
                }
            }
            .padding(15)
            Image("connectiCloud")
                .resizable()
                .padding(.horizontal)
                Spacer()
            Text("Test")
                .foregroundColor(Cloud.isChild ?  .darkGreen : .darkBlue)
                .padding(20)
        }.frame(maxWidth: 170, maxHeight: 170)
            .background(  LinearGradient(gradient: Gradient(colors: [Cloud.isChild ? .lightGreen: .lightBlue, .white]), startPoint: .top, endPoint: .bottom))
        .cornerRadius(10)
          
    }
}

struct PicCell_Previews: PreviewProvider {
    static var previews: some View {
        PicCell(isEditing:Binding.constant(false))
    }
}
