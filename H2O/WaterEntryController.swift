//
//  WaterEntryViewControllerModel.swift
//  H2O
//
//  Created by Gregory Sapienza on 4/8/17.
//  Copyright © 2017 City Pixels. All rights reserved.
//

import Foundation
import CoreData

struct WaterEntryController {
    
    // MARK: - Public iVars
    
    /// Core data stack.
    let coreDataStack: CoreDataStack
    
    /// User to use for water entries.
    let user: User
    
    // MARK: - Public
    
    init(coreDataStack: CoreDataStack, user: User) {
        self.coreDataStack = coreDataStack
        self.user = user
    }
    
    /// Fetches total amount of water consumed for the current date.
    ///
    /// - Returns: Total value of water consumed today.
    func fetchTodaysTotal() -> Double {
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Entry")
        
        let datePredicate = predicateForDayFromDate(date: Date())
        let deletedPredicate = NSPredicate(format: "wasDeleted == false")
        let userPredicate = NSPredicate(format: "user.id == \(user.id!)")
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, deletedPredicate, userPredicate])
        fetchRequest.resultType = .dictionaryResultType
        
        let sumExpressionDescription = NSExpressionDescription()
        sumExpressionDescription.name = "sumEntry"
        
        let expressionForSum = NSExpression(forKeyPath: #keyPath(Entry.amount))
        sumExpressionDescription.expression = NSExpression(forFunction: "sum:", arguments: [expressionForSum])
        sumExpressionDescription.expressionResultType = .doubleAttributeType
        
        fetchRequest.propertiesToFetch = [sumExpressionDescription]
        
        do {
            let results = try coreDataStack.managedObjectContext.fetch(fetchRequest)
            if let sum = results.first?["sumEntry"] as? Double {
                return sum
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return 0
    }
    
    func createNewEntry(_ amount: Float, date: Date) -> Entry {
        let id = UUID().uuidString
        let entry = createNewEntry(id: id, amount: amount, date: date, creationDate: Date(), modificationDate: Date(), wasDeleted: false, in: coreDataStack.managedObjectContext)
        
        return entry
    }
    
    func createNewEntry(id: String, amount: Float, date: Date = Date(), creationDate: Date, modificationDate: Date, wasDeleted: NSNumber, in context: NSManagedObjectContext) -> Entry {
        let entity = NSEntityDescription.entity(forEntityName: "Entry", in: context)
        
        let entry = NSManagedObject(entity: entity!, insertInto: context) as! Entry
        
        entry.id = id
        entry.amount = NSNumber(value: amount)
        entry.date = date
        entry.creationDate = creationDate
        entry.modificationDate = modificationDate
        entry.wasDeleted = wasDeleted
        
        user.addEntry(entry: entry)
        
        return entry
    }
    
    // MARK: - Private
    
    /// Creates a predicate to filter entities to a particular date.
    ///
    /// - Parameter date: Date to fetch entities for.
    /// - Returns: Predicate for entities on a specified date.
    private func predicateForDayFromDate(date: Date) -> NSPredicate {
        let calendar = Calendar.current
        
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        components.hour = 00
        components.minute = 00
        components.second = 00
        let startDate = calendar.date(from: components)
        
        components.hour = 23
        components.minute = 59
        components.second = 59
        let endDate = calendar.date(from: components)
        
        return NSPredicate(format: "date >= %@ AND date =< %@", argumentArray: [startDate!, endDate!])
    }
}
