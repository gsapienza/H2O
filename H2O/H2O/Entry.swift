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

    class func createNewEntry(_ amount :Float, date :Date?) -> Entry {
        let managedContext = AppDelegate.getAppDelegate().managedObjectContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Entry", in:managedContext)
        
        let entry = NSManagedObject(entity: entity!, insertInto: managedContext) as! Entry
        
        entry.id = UUID().uuidString
        if date != nil {
            entry.date = date!
        } else {
            entry.date = Date()
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

        managedContext.delete(self)
        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }

}
