//
//  ExtensionDelegate.swift
//  H2O-Watch Extension
//
//  Created by Gregory Sapienza on 9/14/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import WatchKit
import CoreData

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    private var _user :User?
    
    var user :User? {
        return _user
    }
    
    func applicationDidFinishLaunching() {
        if !AppUserDefaults.getWasOpenedOnce() { //If the app was never opened. Load presets, if the phone has already changed these defaults, those changes will be reflected after the defaults are set.
            setDefaultPresets()
            setDefaultGoal()
            setDefaultTheme()
            
            AppUserDefaults.setAppWasOpenedOnce(openedOnce: true)
        }
        
        WatchConnection.standardWatchConnection.activateSession() //Activates session to communicate with iPhone.
        
        _user = User.loadUser()
    }

    func applicationDidBecomeActive() {
        WatchConnection.standardWatchConnection.getDefaults() //Get defaults when the app has entered the foreground in case anything changed.
        NotificationCenter.default.post(name: WatchAppSwitchedToForegroundNotification, object: nil)
    }

    func applicationWillResignActive() {
        NotificationCenter.default.post(name: WatchAppSwitchedToBackgroundNotification, object: nil)
        self.saveContext()
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompleted()
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompleted()
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompleted()
            default:
                // make sure to complete unhandled task types
                task.setTaskCompleted()
            }
        }
    }
    
    //MARK: - Default Settings
    
    /// Sets default preset values if none exist
    private func setDefaultPresets() {
        AppUserDefaults.setPresetWaterValues(presets: defaultPresets)
    }
    
    /// Sets default goal value if none exists
    private func setDefaultGoal() {
        AppUserDefaults.setDailyGoalValue(goal: defaultDailyGoal)
    }
    
    /// Sets default theme if none exists
    private func setDefaultTheme() {
        AppUserDefaults.setDarkModeEnabled(enabled: true)
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.theoven.H2O" in the application's documents Application Support directory.
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        //let urls = FileManager.default.urlsForDirectory(.documentDirectory, inDomains: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "H2O", withExtension: "momd")
        return NSManagedObjectModel(contentsOf: modelURL!)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}
