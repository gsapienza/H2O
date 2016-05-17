//
//  User.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/16/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import Foundation
import CoreData


class User: NSManagedObject {

    class func loadUser() -> User? {
        let managedContext = AppDelegate.getAppDelegate().managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "User")
        
        do {
            let results =
                try managedContext.executeFetchRequest(fetchRequest)
            let users = results as! [User]
            
            guard users.count != 0 else {
                return createNewUser()
            }
            
            return users.first
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            
            return nil
        }
    }
    
    private class func createNewUser() -> User {
        let managedContext = AppDelegate.getAppDelegate().managedObjectContext
        
        let entity = NSEntityDescription.entityForName("User", inManagedObjectContext:managedContext)
        
        let user = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext) as! User
        
        user.id = NSUUID().UUIDString
        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        return user
    }

    func addNewDay() {
        let managedContext = AppDelegate.getAppDelegate().managedObjectContext

        let day = Day.createNewDay()
        
        let days = mutableSetValueForKey("days")
        days.addObject(day)
        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }}
