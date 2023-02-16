//
//  NotificationManager.swift
//  Sabeel
//
//  Created by Khawlah on 15/02/2023.
//


import SwiftUI
import CloudKit
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    func requestPermission() {
        // Request permission from user to send notification
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { authorized, error in
            if let error = error {
                print(error.localizedDescription)
            } else if authorized {
                print("All set!")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    // For cloudkit notification
    func subscribeToNotifications(predicate: NSPredicate) {
        
        let subscription = CKQuerySubscription(recordType: ChildRequestModel.recordTypeKey, predicate: predicate, options: .firesOnRecordCreation)
        
        let info = CKSubscription.NotificationInfo()
        
        info.titleLocalizationKey = "%1$@"
        info.titleLocalizationArgs = ["title"]
        
        info.alertLocalizationKey = "%1$@"
        info.alertLocalizationArgs = ["content"]
        
        info.soundName = "default"
        
        subscription.notificationInfo = info
        
        // Save the subscription to Public Database in Cloudkit
        CKContainer.default().publicCloudDatabase.save(subscription, completionHandler: { subscription, error in
            if error == nil {
                // Subscription saved successfully
            } else {
                // Error occurred
            }
        })
    }
    
    func unsubscribeToNotifications() {
        // fetch all subscriptions by the user and delete them
        CKContainer.default().publicCloudDatabase.fetchAllSubscriptions(completionHandler: { subscriptions, error in

            if let subscriptions = subscriptions {
                for subscription in subscriptions {
                    CKContainer.default().publicCloudDatabase.delete(withSubscriptionID: subscription.subscriptionID, completionHandler: { string, error in
                        if(error != nil){
                            // deletion of subscription failed, handle error here
                        }
                    })
                }
            }
            
        })
    }
}
