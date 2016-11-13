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
    private var latestEntry :Entry?
    
    class func managedContext() -> NSManagedObjectContext {
        #if os(iOS)
            return getAppDelegate().managedObjectContext
        #endif
        
        #if os(watchOS)
            return getWKExtensionDelegate().managedObjectContext
        #endif
    }
    
    func setDatabaseRevisionsToInitialState() {
        //lastWatchSyncDate = Date.distantPast
        
        for entry in entries! {
            let entryObject = entry as! Entry
            entryObject.creationDate = entryObject.date
            entryObject.modificationDate = entryObject.date
        }
        
        do {
            try User.managedContext().save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
    }
    
    class func loadUser() -> User? {
        let fetchRequest :NSFetchRequest<User> = NSFetchRequest(entityName: "User")
        
        do {
            let results =
                try managedContext().fetch(fetchRequest)
            let users = results
            
            guard users.count != 0 else {
                return createNewUser()
            }
            

            users.first!.setDatabaseRevisionsToInitialState()
            return users.first
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            
            return nil
        }
    }
    
    private class func createNewUser() -> User {
        let entity = NSEntityDescription.entity(forEntityName: "User", in:managedContext())
        
        let user = NSManagedObject(entity: entity!, insertInto: managedContext()) as! User
        
        user.id = UUID().uuidString
        user.lastWatchSyncDate = Date.init(timeIntervalSince1970: 0)
        
        do {
            try managedContext().save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        return user
    }
    
    func addNewEntryToUser(_ amount :Float, date :Date?) {
        let entry = Entry.createNewEntry(amount, date :date)
        addEntry(entry: entry)
    }
    
    func addEntry(entry :Entry) {
        let mutableEntries = self.entries!.mutableCopy() as! NSMutableOrderedSet
        mutableEntries.add(entry)
        entries = mutableEntries.copy() as? NSOrderedSet
        latestEntry = entry
        
        do {
            try User.managedContext().save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func deleteLatestEntry() {
        guard let entry = latestEntry else {
            print("Latest entry has not been set.")
            return
        }
        
        entry.deleteEntry()
        latestEntry = nil
    }
    
    func getLatestEntryDate() -> Date? {
        guard let entry = latestEntry else {
            print("Latest entry has not been set.")
            return nil
        }
        
        return entry.date
    }
        
    func amountOfWaterForToday() -> Float {
        var todaysWaterAmount :Float = 0.0
        
        for entry in entries! {
            guard let entry = entry as? Entry else {
                return 0
            }
            
            if entry.wasDeleted == false {
                let entryDate = entry.date
                let todayDate = Date()
                
                let calendar = Calendar.current //Calendar type
                
                let entryDateComponents = calendar.dateComponents([.day, .month, .year], from: entryDate)
                let todayDateComponents = calendar.dateComponents([.day, .month, .year], from: todayDate)
                
                if entryDateComponents.month == todayDateComponents.month && entryDateComponents.day == todayDateComponents.day && entryDateComponents.year == todayDateComponents.year {
                    todaysWaterAmount += entry.amount.floatValue
                }
            }
        }
        
        return todaysWaterAmount
    }
    
    func entriesForDates() -> [[String :AnyObject]] {
        var dateCollections :[[String :AnyObject]]  = [] //Array of dict of collections by date
        
        var lastCollection :[String :AnyObject]?
        
        for (i, entry) in entries!.enumerated() {
            guard let entry = entry as? Entry else {
                return []
            }
            
            if lastCollection == nil {
                lastCollection = ["date" : entry.date as AnyObject, "entries" : [Entry]() as AnyObject]
            }
            
            let entriesArray = lastCollection!["entries"] as! [Entry]
            
            if entry.wasDeleted == false {
                let newEntries = NSArray(object: entry).addingObjects(from: entriesArray)
                lastCollection!["entries"] = newEntries as AnyObject
            }
            
            if entry == entries?.lastObject as! Entry { //if there is no next collection because we are at the end of the entries
                if lastCollection!["entries"]?.count != 0 {
                    dateCollections.insert(lastCollection!, at: 0) //Add the last collection the beginning so it can appear at the top of the list
                }
                lastCollection = nil
            } else {
                let nextEntry = entries![i + 1] as! Entry //Get the next entry from the current index
                
                let calendar = Calendar.current //Calendar type
                
                let nextEntryDateComponents = calendar.dateComponents([.day, .month, .year], from: nextEntry.date) //Next entry from index date components
                let lastDateComponents = calendar.dateComponents([.day, .month, .year], from: (lastCollection!["date"] as! Date)) //The last entry from index date components
                
                if nextEntryDateComponents.month != lastDateComponents.month || nextEntryDateComponents.day != lastDateComponents.day || nextEntryDateComponents.year != lastDateComponents.year {
                    if lastCollection!["entries"]?.count != 0 {
                        dateCollections.insert(lastCollection!, at: 0)
                    }
                    lastCollection = nil //Setting lastCollection to nil will make the lastCollection reset on the next loop
                }                
            }
        }
        
        return dateCollections
    }
    
    /// Gets an entry from database for its ID.
    ///
    /// - parameter id: Id for entry to find.
    ///
    /// - returns: Entry to represent Id from database.
    func getEntryFor(id :String) -> Entry? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entry")
        let resultPredicate = NSPredicate(format: "id = %@", id)
        fetchRequest.predicate = resultPredicate
        
        do {
            let results = try managedObjectContext?.fetch(fetchRequest)
            return results?.first as? Entry
        } catch _ {
            return nil
        }
    }
    
    /// Get the water values for a seven day week beginning on a Sunday
    ///
    /// - returns: Seven float values in an array representing a weeks worth of values
    func waterValuesThisWeek() -> [Float] {
        let dateEntries = entriesForDates()
        
        var lastWeekValues :[Float] = [0, 0, 0, 0, 0, 0, 0] //Initial week. Everything is 0
        
        return getWaterValueForNextDayInWeek(lastWeekValues: &lastWeekValues, dateEntries: dateEntries, entryIndex: 0) //Get week values starting with the last date of entries
    }
    
    /// Gets the water value for the day in week represented by entry index and recursively goes through each day until it reaches a Sunday of the current week where it will then present the weeks worth of values
    ///
    /// - parameter lastWeekValues: Last week of values (immutable)
    /// - parameter dateEntries:    Entries bundled in an array of dictionaries, each containing a date and an array of entries for that date
    /// - parameter entryIndex:     Index within date entries to check if in the current week
    ///
    /// - returns: Array of values representing this weeks values
    private func getWaterValueForNextDayInWeek(lastWeekValues :inout [Float], dateEntries :[[String :AnyObject]], entryIndex :Int) -> [Float] {
        guard dateEntries.count != entryIndex else { //Is the entryIndex out of bounds
            return lastWeekValues
        }
        
        let entries = dateEntries[entryIndex] //Dictionary of a date and of all its entries
        
        let date = entries["date"] as! Date //Date within the dictionary of entries

        let lastDateComponents = Calendar.current.dateComponents([.weekday, .weekOfYear], from: date) //Components for the entries date
        let todaysDateComponents = Calendar.current.dateComponents([.weekday, .weekOfYear], from: Date()) //Components for this date
        
        if lastDateComponents.weekOfYear == todaysDateComponents.weekOfYear { //If it is the same week in the year
        
            //Add up all entries for date
            var totalDateEntryValue :Float = 0
            for entry in entries["entries"] as! [Entry] {
                if entry.wasDeleted == false {
                    totalDateEntryValue += entry.amount.floatValue
                }
            }
            
            lastWeekValues[lastDateComponents.weekday! - 1] = totalDateEntryValue //Value for that date of the week is the total amount of entries added up. We subtract 1 from weekday. Because Sunday is represented as 1 not 0.
            
            return getWaterValueForNextDayInWeek(lastWeekValues: &lastWeekValues, dateEntries: dateEntries, entryIndex: entryIndex + 1) //Run func again for the next day in dateEntries
        } else {
            return lastWeekValues
        }
    }

    class func nextDay(_ fromDate :Date) -> Date {
        var dayComponent = DateComponents()
        
        dayComponent.day = 1 //Only 1 day ahead
        
        let calendar = Calendar.current
        
        //let nextDate = calendar.date(byAdding: dayComponent, to: fromDate, options: .matchNextTime) //Computes the next date
        let nextDate = calendar.date(byAdding: dayComponent, to: fromDate, wrappingComponents: true)
        
        return nextDate!
    }
}
