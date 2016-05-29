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
    
    func addNewEntryToUser(amount :Float, date :NSDate?) {
        let managedContext = AppDelegate.getAppDelegate().managedObjectContext

        let entry = Entry.createNewEntry(amount, date :date)
        
        let mutableEntries = self.entries!.mutableCopy() as! NSMutableOrderedSet
        mutableEntries.addObject(entry)
        
        entries = mutableEntries.copy() as? NSOrderedSet
        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
        
    func getAmountOfWaterForToday() -> Float {
        var todaysWaterAmount :Float = 0.0
        
        for entry in entries! {
            let entryDate = (entry as! Entry).date
            let todayDate = NSDate()
            
            let calendar = NSCalendar.currentCalendar() //Calendar type
            
            let entryDateComponents = calendar.components([.Day, .Month, .Year], fromDate: entryDate!)
            let todayDateComponents = calendar.components([.Day, .Month, .Year], fromDate: todayDate)

            if entryDateComponents.month == todayDateComponents.month && entryDateComponents.day == todayDateComponents.day && entryDateComponents.year == todayDateComponents.year {
                todaysWaterAmount += ((entry as! Entry).amount?.floatValue)!
            }
        }
        
        return todaysWaterAmount
    }
    
    func getEntriesForDates() -> [[String :AnyObject]] {
        var dateCollections :[[String :AnyObject]]  = []
        
        var lastCollection :[String :AnyObject]?
        
        for (i, entry) in entries!.enumerate() {
            let entryObject = entry as! Entry
            
            if lastCollection == nil {
                lastCollection = ["date" : entryObject.date!, "entries" : [Entry]()]
            }
                        
            let entriesArray = lastCollection!["entries"] as! [Entry]
            
            let newEntries = NSArray(object: entryObject).arrayByAddingObjectsFromArray(entriesArray)
            
            lastCollection!["entries"] = newEntries
                        
            if entryObject == entries?.lastObject as! Entry {
                dateCollections.insert(lastCollection!, atIndex: 0)
                lastCollection = nil
            } else {
                let nextEntry = entries![i + 1] as! Entry
                
                let calendar = NSCalendar.currentCalendar() //Calendar type
                
                let nextEntryDateComponents = calendar.components([.Day, .Month, .Year], fromDate: nextEntry.date!)
                let lastDateComponents = calendar.components([.Day, .Month, .Year], fromDate: (lastCollection!["date"] as! NSDate))
                
                if nextEntryDateComponents.month != lastDateComponents.month || nextEntryDateComponents.day != lastDateComponents.day || nextEntryDateComponents.year != lastDateComponents.year {
                    dateCollections.insert(lastCollection!, atIndex: 0)
                    lastCollection = nil
                }
            }
        }
        
        return dateCollections
    }

    class func getNextDay(fromDate :NSDate) -> NSDate {
        let dayComponent = NSDateComponents()
        
        dayComponent.day = 1 //Only 1 day ahead
        
        let calendar = NSCalendar.currentCalendar()
        
        let nextDate = calendar.dateByAddingComponents(dayComponent, toDate: fromDate, options: .MatchNextTime) //Computes the next date
        
        return nextDate!
    }
}
