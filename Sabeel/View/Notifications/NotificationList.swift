//
//  NotificationList.swift
//  Sabeel
//
//  Created by Khawlah on 08/02/2023.
//

import SwiftUI

struct NotificationList: View {
    @EnvironmentObject var cloudViewModel: CloudViewModel
    var body: some View {
     
        List {
        ForEach(cloudViewModel.childRequests
                .sorted(by: { $0.associatedRecord.creationDate ?? .now > $1.associatedRecord.creationDate ?? .now }), id: \.id) { childRequest in
                    NotificationCell(ChildRequestVM : childRequest)      
            }
        }
    }
}

struct NotificationList_Previews: PreviewProvider {
    static var previews: some View {
        NotificationList().environmentObject(CloudViewModel())
    }
}
