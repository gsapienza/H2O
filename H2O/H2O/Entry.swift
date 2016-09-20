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
        let entity = NSEntityDescription.entity(forEntityName: "Entry", in:User.managedContext())
        
        let entry = NSManagedObject(entity: entity!, insertInto: User.managedContext()) as! Entry
        
        entry.id = UUID().uuidString
        if date != nil {
            entry.date = date!
        } else {
            entry.date = Date()
        }
        
        entry.amount = NSNumber(value: amount)
        
        do {
            try User.managedContext().save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        return entry
    }
    
    func deleteEntry() {
        User.managedContext().delete(self)
        
        do {
            try User.managedContext().save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }

}
