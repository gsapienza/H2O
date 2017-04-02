//
//  CoreDataStack.swift
//  H2O
//
//  Created by Gregory Sapienza on 4/1/17.
//  Copyright © 2017 City Pixels. All rights reserved.
//

import CoreData

class CoreDataStack {
    
    // MARK: - Core
    
    /// Application directory for SQL file. Returns the URL for the Documents directory if it exists, if it doesn't it returns the directory for the App Group.
    lazy var applicationDocumentsDirectory: URL = {
        if self.migrationNeeded {
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return urls[urls.count-1]

        } else {
            let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.H2O.ExtensionSharing")
            return url!
        }
    }()
    
    /// Default Managed Object Model.
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "H2O", withExtension: "momd")
        return NSManagedObjectModel(contentsOf: modelURL!)!
    }()
    
    /// Coordinator to work between context and store. If the coordinator finds the SQL file in the documents directory, it will migrate it over to the App Group directory.
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let url = self.applicationDocumentsDirectory.appendingPathComponent("H2O.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        if self.migrationNeeded {
            self.migrateCoreDataDatabaseToAppGroup(coordinator: coordinator)
        }
        
        return coordinator
    }()
    
    
    /// Default managed object context.
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Migration to App Group
    
    /// Migrates a coordinator with a store in the Documents directory to the App Group directory.
    ///
    /// - Parameter coordinator: Coordinator to migrate.
    func migrateCoreDataDatabaseToAppGroup(coordinator: NSPersistentStoreCoordinator) {
        
        // New URL for app group.
        guard let newURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.H2O.ExtensionSharing")?.appendingPathComponent("H2O.sqlite") else {
            print("NewURL is nil")
            return
        }
        
        // Old URL in documents directory.
        guard let oldUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("H2O.sqlite") else {
            print("OldURL is nil")
            return
        }
        
        // Store in Documents directory.
        guard let store = coordinator.persistentStore(for: oldUrl) else {
            print("Store is nil")
            return
        }
        
        // Other old URLs for files in Documents directory.
        let otherOldURLs = [
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("H2O.sqlite-shm"),
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("H2O.sqlite-wal")
            ]

        
        // Migrates store to App Group, removes the old SQL file and other old related files in Documents directory.
        do {
            try coordinator.migratePersistentStore(store, to: newURL, options: nil, withType: NSSQLiteStoreType)
            try FileManager.default.removeItem(at: oldUrl)
            
            for otherOldURL in otherOldURLs {
                if let otherOldURL = otherOldURL {
                    try FileManager.default.removeItem(at: otherOldURL)
                }
            }
        } catch {
            print(error)
        }
    }
    
    /// True if a migration of the database from Documents to App Group needed.
    lazy var migrationNeeded: Bool = {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("H2O.sqlite") else {
            return false
        }
        
        return FileManager.default.fileExists(atPath: url.path)
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}
