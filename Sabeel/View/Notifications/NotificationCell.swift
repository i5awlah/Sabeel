//
//  NotificationCell.swift
//  Sabeel
//
//  Created by Khawlah on 08/02/2023.
//

import SwiftUI

struct NotificationCell: View {
    let ChildRequestVM: ChildRequestModel
    var body: some View {
        GeometryReader { geo in
            HStack(spacing:15){
                
                AsyncImage(url: ChildRequestVM.pecs.imageURL) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                    
                } placeholder: {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                
                VStack(alignment: .leading, spacing: 5){
                    Text(ChildRequestVM.pecs.category)
                        .foregroundColor(.darkBlue)
                        .font(.title2)
                    Text("Your child want **\(ChildRequestVM.pecs.name)** ")
                        .foregroundColor(.darkGray)
                }
                
                Spacer()
                
                
                if let date = ChildRequestVM.associatedRecord.creationDate {
                    Text("\(date.polite)")
                        .foregroundColor(.darkGray)
                }
                    
                
                
            }.padding(20)
            .frame (width: geo.size.width, height: geo.size.height)
            .background(.white)
            .cornerRadius(10)
            
        }.frame(height: 90)
         .padding(5)
    }
}

//struct NotificationCell_Previews: PreviewProvider {
//    static var previews: some View {
//        NotificationCell()
//    }
//}
