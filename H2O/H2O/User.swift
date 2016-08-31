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
        let managedContext = AppDelegate.getAppDelegate().managedObjectContext
        
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
        let managedContext = AppDelegate.getAppDelegate().managedObjectContext

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
    
    func waterValuesThisWeek() -> [Float] {
        var dateEntries = entriesForDates()
        
        var lastWeekValues :[Float]  = []
        
        let todaysDateComponents = Calendar.current.dateComponents([.day], from: Date())

        for _ in 1 ... todaysDateComponents.day! {
            if let dateEntry = dateEntries.popLast() {
              //  let entryDate = dateEntry["date"] as! Date
                
                var totalDateEntryValue :Float = 0
                for value in dateEntry["entries"] as! [Entry] {
                    totalDateEntryValue += value.amount!.floatValue
                }
                
                lastWeekValues.append(totalDateEntryValue)
            } else {
                lastWeekValues.append(0)
            }
        }
        
        let remainingDays = 7 - todaysDateComponents.day!
        
        for _ in 1 ... remainingDays {
            lastWeekValues.append(0)
        }
        
        return lastWeekValues.reversed()

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
