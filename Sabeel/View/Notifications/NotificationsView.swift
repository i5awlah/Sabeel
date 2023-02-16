//
//  NotificationsView.swift
//  Sabeel
//
//  Created by Khawlah on 06/02/2023.
//

import SwiftUI

struct NotificationsView: View {
    
    @EnvironmentObject var cloudViewModel: CloudViewModel
    
    var body: some View {
        List {
            ForEach(cloudViewModel.childRequests
                .sorted(by: { $0.associatedRecord.creationDate ?? .now > $1.associatedRecord.creationDate ?? .now }), id: \.id) { childRequest in
                HStack {
                    if let date = childRequest.associatedRecord.creationDate {
                        Text("\(date.polite)")
                    }
                    
                    Text("\(childRequest.pecs.name)")
                }
            }
        }
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
            .environmentObject(CloudViewModel())
    }
}
