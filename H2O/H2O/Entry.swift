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

    class func createNewEntry(amount :Float, date :NSDate?) -> Entry {
        let managedContext = AppDelegate.getAppDelegate().managedObjectContext
        
        let entity = NSEntityDescription.entityForName("Entry", inManagedObjectContext:managedContext)
        
        let entry = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext) as! Entry
        
        entry.id = NSUUID().UUIDString
        if date != nil {
            entry.date = date!
        } else {
            entry.date = NSDate()
        }
        
        entry.amount = amount
        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        return entry
    }
    
    func deleteEntry() {
        let managedContext = AppDelegate.getAppDelegate().managedObjectContext

        managedContext.deleteObject(self)
        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }

}
