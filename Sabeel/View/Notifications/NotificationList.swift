//
//  NotificationList.swift
//  Sabeel
//
//  Created by Khawlah on 08/02/2023.
//

import SwiftUI

struct NotificationList: View {
    
    @EnvironmentObject var cloudViewModel: CloudViewModel
    
    let childRequests: [ChildRequestModel]
    
    var unReadRequest: [ChildRequestModel] {
        childRequests.filter({ !$0.isRead })
    }
    
    var readRequest: [ChildRequestModel] {
        childRequests.filter({ $0.isRead })
    }
    
    var body: some View {
        VStack(alignment : .leading , spacing: 12){
            
            if !unReadRequest.isEmpty {
                Section(header : Text("New").font(.title2).bold().padding(.leading)) {
                    
                    ForEach(unReadRequest, id: \.id) { childRequest in
                        NotificationCell(ChildRequestVM : childRequest)
                            .onAppear{
                                cloudViewModel.parentReadRequest(childRequest: childRequest)
                            }
                    }
                    
                }
            }
            
            
            if !readRequest.isEmpty {
                Section(header : Text("Previous").font(.title2).bold() .padding(.leading).padding(.top, 15)) {
                    ForEach(readRequest, id: \.id) { childRequest in
                        NotificationCell(ChildRequestVM : childRequest)
                    }
                }
            }
            
            
            Spacer()
        }.padding(.vertical)
    }
}










struct NotificationList_Previews: PreviewProvider {
    static var previews: some View {
        NotificationList(childRequests: [])
            .environmentObject(CloudViewModel())
    }
}
