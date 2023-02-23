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
            HStack{
                
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
                
                VStack(alignment: .leading, spacing: 7){
                    Text(ChildRequestVM.pecs.category.localized)
                        .foregroundColor(.darkBlue)
                        .font(.customFont(size: 14)).bold()
                    Text("Your special child wants **\(Helper.shared.getPicName(pecs: ChildRequestVM.pecs))** ")
                        .foregroundColor(.darkGray)
                        .font(.customFont(size: 14))
                }
                
                Spacer()
                
                
                if let date = ChildRequestVM.associatedRecord.creationDate {
                    Text("\(date.polite)")
                        .foregroundColor(.darkGray)
                        .font(.customFont(size: 14))
                }
                    
                
                
            }
            .padding(.leading, 5)
            .padding(.trailing)
            .frame (width: geo.size.width, height: geo.size.height)
            .background(Color.White)
            .cornerRadius(10)
            
        }.frame(height: 60)
            .padding(.horizontal)
   
    }
}

//struct NotificationCell_Previews: PreviewProvider {
//    static var previews: some View {
//        NotificationCell()
//    }
//}
