//
//  Day.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/16/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import Foundation
import CoreData


class Day: NSManagedObject {

    class func createNewDay(date :NSDate) -> Day {
        let managedContext = AppDelegate.getAppDelegate().managedObjectContext
        
        let entity = NSEntityDescription.entityForName("Day", inManagedObjectContext:managedContext)
        
        let day = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext) as! Day
        
        day.id = NSUUID().UUIDString
        day.date = date
        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        return day
    }
    
    func addNewEntry(amount :Float) {
        let managedContext = AppDelegate.getAppDelegate().managedObjectContext
        
        let entry = Entry.createNewEntry(amount)
        
        let entries = mutableSetValueForKey("entries")
        entries.addObject(entry)
        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
}
