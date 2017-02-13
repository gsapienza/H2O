//
//  Entry+CoreDataProperties.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/16/16.
//  Copyright © 2016 Skyscrapers.IO. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Entry {

    @NSManaged var id: String
    @NSManaged var date: Date
    @NSManaged var amount: NSNumber
    @NSManaged var user: User?
    @NSManaged var creationDate: Date
    @NSManaged var modificationDate: Date
    @NSManaged var wasDeleted: NSNumber
}
