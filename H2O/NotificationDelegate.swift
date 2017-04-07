//
//  NotificationDelegate.swift
//  H2O
//
//  Created by Gregory Sapienza on 3/11/17.
//  Copyright © 2017 City Pixels. All rights reserved.
//

import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        guard let navigationController = getAppDelegate().window?.rootViewController as? UINavigationController else {
            return
        }
        
        guard let mainViewController = navigationController.viewControllers.first as? MainViewController else {
            return
        }
        
        if response.actionIdentifier == "custom" {
            
        } else {
            let entry = Entry.createNewEntry(Float(response.actionIdentifier)!, date: Date())
            getAppDelegate().user?.addEntry(entry: entry)
        }
        
        completionHandler()
    }
}
