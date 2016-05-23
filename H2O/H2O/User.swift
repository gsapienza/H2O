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
        
        let entries = self.mutableSetValueForKey("entries")
        entries.addObject(entry)
        
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
    func getNextDay(fromDate :NSDate) -> NSDate {
        let dayComponent = NSDateComponents()
        
        dayComponent.day = 1 //Only 1 day ahead
        
        let calendar = NSCalendar.currentCalendar()
        
        let nextDate = calendar.dateByAddingComponents(dayComponent, toDate: fromDate, options: .MatchNextTime) //Computes the next date
        
        return nextDate!
    }*/
}
