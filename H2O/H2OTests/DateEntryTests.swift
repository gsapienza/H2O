//
//  DateEntryTests.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/20/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import XCTest
@testable import H2O

class DateEntryTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    /**
     Wipes database of all days from the user
     */
    override func tearDown() {
        super.tearDown()
        
        for day in (AppDelegate.getAppDelegate().user?.days)! {
            let managedDay = day as! Day
            
            AppDelegate.getAppDelegate().managedObjectContext.deleteObject(managedDay)
        }
        
        do {
            try AppDelegate.getAppDelegate().managedObjectContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    /**
     Create a date from a string
     
     - parameter dateString: ""
     */
    func addTestDate(date :NSDate) {
        AppDelegate.getAppDelegate().user!.addNewDay(date)
    }
    
    func getDateFromString(dateString :String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yy"
        
        let date = dateFormatter.dateFromString(dateString)!
        
        return date
    }
    
    func getTheDateFromNumberOfDaysAway(numberOfDaysAway :Int) -> NSDate {
        let dayComponent = NSDateComponents()
        
        dayComponent.day = numberOfDaysAway
        
        let calendar = NSCalendar.currentCalendar()
        
        let newDate = calendar.dateByAddingComponents(dayComponent, toDate: NSDate().dateForCurrentTimeZone(), options: .MatchNextTime) //Computes the next date
        
        return newDate!
    }
    
    /**
     Test if the test dates fall in different months and the same year from current
     */
    func testDateEntryDifferentMonth() {
        //addTestDate("20-March-16")
        //addTestDate("30-April-16")
        
        addTestDate(getTheDateFromNumberOfDaysAway(-60))
        addTestDate(getTheDateFromNumberOfDaysAway(-32))

        AppDelegate.getAppDelegate().user!.createDaysToDate()

        XCTAssertEqual(AppDelegate.getAppDelegate().user!.days?.count, 34)
    }
    
    /**
     Test if the test dates fall in different days of the same month and year from current (well unless your testing this early in the month in which case adjust the numbers a bit) ;)
     */
    func testDateEntryDifferentDay() {
        //addTestDate("1-May-16")
        //addTestDate("15-May-16")
        
        addTestDate(getTheDateFromNumberOfDaysAway(-3))
        addTestDate(getTheDateFromNumberOfDaysAway(-5))
        
        AppDelegate.getAppDelegate().user!.createDaysToDate()
        
        let days = AppDelegate.getAppDelegate().user!.days
        
        for day in days! {            
            print(day.date!)
        }
        
        XCTAssertEqual(AppDelegate.getAppDelegate().user!.days?.count, 5)
    }
    
    /**
     Test if the test dates fall in different years from current
     */
    func testDateEntryDifferentYear() {
        //addTestDate("1-May-15")
        //addTestDate("15-May-14")
        
        addTestDate(getTheDateFromNumberOfDaysAway(-386))
        addTestDate(getTheDateFromNumberOfDaysAway(-705))
        
        AppDelegate.getAppDelegate().user!.createDaysToDate()
        
        XCTAssertEqual(AppDelegate.getAppDelegate().user!.days?.count, 388)
    }
    
    /**
     Test if test date falls on the same day as today
     */
    func testSameDateEntry() {
        addTestDate(NSDate().dateForCurrentTimeZone())
        AppDelegate.getAppDelegate().user!.createDaysToDate()
        
        XCTAssertEqual(AppDelegate.getAppDelegate().user!.days?.count, 1)
    }
}
