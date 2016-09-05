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
        let managedContext = getAppDelegate().managedObjectContext
        
        let fetchRequest :NSFetchRequest<User> = NSFetchRequest(entityName: "User")
        
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            let users = results
            
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
        let managedContext = getAppDelegate().managedObjectContext
        
        let entity = NSEntityDescription.entity(forEntityName: "User", in:managedContext)
        
        let user = NSManagedObject(entity: entity!, insertInto: managedContext) as! User
        
        user.id = UUID().uuidString
        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        return user
    }
    
    func addNewEntryToUser(_ amount :Float, date :Date?) {
        let managedContext = getAppDelegate().managedObjectContext

        let entry = Entry.createNewEntry(amount, date :date)
        
        let mutableEntries = self.entries!.mutableCopy() as! NSMutableOrderedSet
        mutableEntries.add(entry)
        
        entries = mutableEntries.copy() as? NSOrderedSet
        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
        
    func amountOfWaterForToday() -> Float {
        var todaysWaterAmount :Float = 0.0
        
        for entry in entries! {
            let entryDate = (entry as! Entry).date
            let todayDate = Date()
            
            let calendar = Calendar.current //Calendar type
            
            let entryDateComponents = calendar.dateComponents([.day, .month, .year], from: entryDate!)
            let todayDateComponents = calendar.dateComponents([.day, .month, .year], from: todayDate)

            if entryDateComponents.month == todayDateComponents.month && entryDateComponents.day == todayDateComponents.day && entryDateComponents.year == todayDateComponents.year {
                todaysWaterAmount += ((entry as! Entry).amount?.floatValue)!
            }
        }
        
        return todaysWaterAmount
    }
    
    func entriesForDates() -> [[String :AnyObject]] {
        var dateCollections :[[String :AnyObject]]  = [] //Array of dict of collections by date
        
        var lastCollection :[String :AnyObject]?
        
        for (i, entry) in entries!.enumerated() {
            let entryObject = entry as! Entry
            
            if lastCollection == nil {
                lastCollection = ["date" : entryObject.date! as AnyObject, "entries" : [Entry]() as AnyObject]
            }
                        
            let entriesArray = lastCollection!["entries"] as! [Entry]
            
            let newEntries = NSArray(object: entryObject).addingObjects(from: entriesArray)
            
           // print(entryObject)
            lastCollection!["entries"] = newEntries as AnyObject
                        
            if entryObject == entries?.lastObject as! Entry { //if there is no next collection because we are at the end of the entries
                dateCollections.insert(lastCollection!, at: 0) //Add the last collection the beginning so it can appear at the top of the list
                lastCollection = nil
            } else {
                let nextEntry = entries![i + 1] as! Entry //Get the next entry from the current index
                
                let calendar = Calendar.current //Calendar type
                
                let nextEntryDateComponents = calendar.dateComponents([.day, .month, .year], from: nextEntry.date!) //Next entry from index date components
                let lastDateComponents = calendar.dateComponents([.day, .month, .year], from: (lastCollection!["date"] as! Date)) //The last entry from index date components
                
                if nextEntryDateComponents.month != lastDateComponents.month || nextEntryDateComponents.day != lastDateComponents.day || nextEntryDateComponents.year != lastDateComponents.year {
                    dateCollections.insert(lastCollection!, at: 0)
                    lastCollection = nil //Setting lastCollection to nil will make the lastCollection reset on the next loop
                }                
            }
        }
        
        return dateCollections
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
            for value in entries["entries"] as! [Entry] {
                totalDateEntryValue += value.amount!.floatValue
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
