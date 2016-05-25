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
            
            for entry in (users.first?.entries)! {
                let object = entry as! Entry
                print(object.amount)
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
    
    func addNewEntryToUser(amount :Float) {
        let managedContext = AppDelegate.getAppDelegate().managedObjectContext

        let entry = Entry.createNewEntry(amount)
        
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

    /*func addNewDay(date :NSDate) {
        let managedContext = AppDelegate.getAppDelegate().managedObjectContext

        let day = Day.createNewDay(date)
        
        let days = mutableSetValueForKey("days")
        days.addObject(day)
        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    /**
     Creates new dates in core database until the current date
     */
    func createDaysToDate() {
        if days?.count != 0 { //Are there any days present
            let sortedDates = days!.sort({ $0.date.compare($1.date) == .OrderedAscending }) as! [Day] //Sort current dates with the lastest being last
            
            let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian) //Calendar type

            var lastDay = sortedDates.last?.date //The latest date
            var lastDayComponents = calendar?.components([.Day, .Month, .Year], fromDate: lastDay!) //Components from the latest date
            
            let today = NSDate().dateForCurrentTimeZone() //Todays date
            let todayComponents = calendar?.components([.Day, .Month, .Year], fromDate: today) //Components from todays date
            
            while true { //While the dates havent been caught up to today
                if lastDayComponents?.month < todayComponents?.month || lastDayComponents?.day < todayComponents?.day || lastDayComponents?.year < todayComponents?.year { //If the current month is greater than the last month or the day is greater than the latest day or the year is greater than ther current year
                    
                    let nextDate = getNextDay(lastDay!) //Get the next day from the latest entry
                    
                    lastDay = nextDate //Last date is now the new date
                    lastDayComponents = calendar?.components([.Day, .Month, .Year], fromDate: nextDate) //New last day components
                    
                    if lastDayComponents?.day == 20 {
                        print("")
                    }
                    
                    addNewDay(nextDate) //Add the new date to the data base
                } else {
                    break
                }
            }
        } else { //If there are no days            
            addNewDay(NSDate().dateForCurrentTimeZone()) //New date for today
        }
    }
    
    /**
     Computes the next NSDate from a passed NSDate
     
     - parameter fromDate: NSDate which you want the next date for
     
     - returns: The next date
     */
 */
    class func getNextDay(fromDate :NSDate) -> NSDate {
        let dayComponent = NSDateComponents()
        
        dayComponent.day = 1 //Only 1 day ahead
        
        let calendar = NSCalendar.currentCalendar()
        
        let nextDate = calendar.dateByAddingComponents(dayComponent, toDate: fromDate, options: .MatchNextTime) //Computes the next date
        
        return nextDate!
    }
}
