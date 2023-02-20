//
//  TabBar.swift
//  Sabeel
//
//  Created by hoton on 25/07/1444 AH.
//

import SwiftUI

struct TabBar: View {
    
    @EnvironmentObject var cloudViewModel : CloudViewModel
    
    var body: some View {
        TabView {
            PecsView()
                .tabItem {
                    Label("PECS", systemImage: "person.line.dotted.person")
                }
            NotificationsView()
                .tabItem {
                    Label("Notifications", systemImage: "bell.badge")
                }
                .badge(cloudViewModel.childRequests.filter({ !$0.isRead }).count)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }

    }
}

struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        TabBar()
            .environmentObject(CloudViewModel())
    }
}