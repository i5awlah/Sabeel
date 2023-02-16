//
//  NotificationsView.swift
//  Sabeel
//
//  Created by Khawlah on 06/02/2023.
//

import SwiftUI

struct NotificationsView: View {
    
  
    
    var body: some View {
        NavigationStack{
            VStack{
                NotificationList()
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
