//
//  NotificationList.swift
//  Sabeel
//
//  Created by Khawlah on 08/02/2023.
//

import SwiftUI

struct NotificationList: View {
    @EnvironmentObject var cloudViewModel: CloudViewModel
    //let childRequests : ChildRequestModel
    var body: some View {
        VStack(alignment : .leading , spacing: 12){
            
            Section(header : Text("New").font(.title2).bold().padding(.leading)) {
                
                if false{
                    ForEach(cloudViewModel.childRequests
                        .sorted(by: { $0.associatedRecord.creationDate ?? .now > $1.associatedRecord.creationDate ?? .now }), id: \.id) { childRequest in
                            NotificationCell(ChildRequestVM : childRequest)
                        }
                } else {
                    Text("No notification yet !")
                        .frame(maxWidth: .infinity)
                }
                
            }
            
            
            
            Section(header : Text("Previous").font(.title2).bold() .padding(.leading).padding(.top, 15)) {
                
                if false{
                    ForEach(cloudViewModel.childRequests
                        .sorted(by: { $0.associatedRecord.creationDate ?? .now > $1.associatedRecord.creationDate ?? .now }), id: \.id) { childRequest in
                            NotificationCell(ChildRequestVM : childRequest)
                        }
                } else {
                    Text("No notification yet !")
                        .frame(maxWidth: .infinity)
                }
                
            }
            
            
            Spacer()
        }.padding(.vertical)
    }
}










struct NotificationList_Previews: PreviewProvider {
    static var previews: some View {
        NotificationList().environmentObject(CloudViewModel())
    }
}
