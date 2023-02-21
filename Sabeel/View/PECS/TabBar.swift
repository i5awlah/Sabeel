//
//  TabBar.swift
//  Sabeel
//
//  Created by hoton on 25/07/1444 AH.
//

import SwiftUI

struct TabBar: View {
    
    @EnvironmentObject var cloudViewModel : CloudViewModel
    @State private var previousSelected = [0]
    @State private var selected = 0
    
    var body: some View {
        VStack {
            TabView(selection: $selected.onUpdate{ myFunction(item: selected) }) {
                PecsView()
                    .tabItem {
                        Label("PECS", systemImage: "person.line.dotted.person")
                    }
                    .tag(0)
                
                NotificationsView()
                    .tabItem {
                        Label("Notifications", systemImage: "bell.badge")
                    }
                    .badge(cloudViewModel.childRequests.filter({ !$0.isRead }).count)
                    .tag(1)
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(2)
            }
        }
        .popover(isPresented: $cloudViewModel.showNoLinkView, content: {
            NoLinkView()
        })

    }
    func myFunction(item: Int) {
        previousSelected.append(item)
        let count = previousSelected.count
        if previousSelected[count-1] == previousSelected[count-2] {
            if item == 0 {
                cloudViewModel.scrollToTopPecs = true
            } else if item == 1 {
                cloudViewModel.scrollToTopNotification = true
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
