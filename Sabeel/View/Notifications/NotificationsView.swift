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
                
                if cloudViewModel.childRequests != nil {
                    NotificationList()

                } else
                {
                    NoNotification()
                }
                
            }.navigationTitle("Notification")
          
            
             
                
            
        }
    }
}



struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {

        NotificationsView()
            .environmentObject(CloudViewModel())
    }
}
