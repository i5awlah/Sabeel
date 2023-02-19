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
        
        NavigationStack{
            
            ZStack{
                Color.lightGray.ignoresSafeArea()
                
                
                if cloudViewModel.childRequests.isEmpty {
                    NoNotification()
                } else {
                    ScrollView {
                        NotificationList(
                            childRequests: cloudViewModel.childRequests
                                .sorted(by: { $0.associatedRecord.creationDate ?? .now > $1.associatedRecord.creationDate ?? .now })
                        )
                    }
                }
                
                
            }
            .onAppear{
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
            .navigationTitle("Notifications")
        }
    }
}



struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
            .environmentObject(CloudViewModel())
    }
}
