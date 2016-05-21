//
//  Entry.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/16/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import Foundation
import CoreData


class Entry: NSManagedObject {

    class func createNewEntry(amount :Float) -> Entry {
        let managedContext = AppDelegate.getAppDelegate().managedObjectContext
        
        let entity = NSEntityDescription.entityForName("Entry", inManagedObjectContext:managedContext)
        
        let entry = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext) as! Entry
        
        entry.id = NSUUID().UUIDString
        entry.date = NSDate()
        entry.amount = amount
        
        let user = AppDelegate.getAppDelegate().user!
        let entries = user.mutableSetValueForKey("entries")
        entries.addObject(self)
        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        return entry
    }

}
