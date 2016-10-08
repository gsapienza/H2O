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

    override func awakeFromInsert() {
        super.awakeFromInsert()
        
       // creationDate = Date()
    }
    
    class func createNewEntry(_ amount :Float, date :Date?) -> Entry {
        let id = UUID().uuidString
        let entry = createNewEntry(id: id, amount: amount, date: date, creationDate :Date(), modificationDate :Date(), wasDeleted :false)
        
        return entry
    }
    
    class func createNewEntry(id :String, amount :Float, date :Date?, creationDate :Date, modificationDate :Date, wasDeleted :NSNumber) -> Entry {
        let entity = NSEntityDescription.entity(forEntityName: "Entry", in:User.managedContext())
        
        let entry = NSManagedObject(entity: entity!, insertInto: User.managedContext()) as! Entry
        
        if date != nil {
            entry.date = date!
        } else {
            entry.date = Date()
        }
        
        entry.id = id
        entry.amount = NSNumber(value: amount)
        entry.creationDate = creationDate
        entry.modificationDate = modificationDate
        entry.wasDeleted = wasDeleted
        
        return entry
    }
    
    func deleteEntry() {
        modificationDate = Date()
        wasDeleted = true
        
        do {
            try User.managedContext().save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
}
