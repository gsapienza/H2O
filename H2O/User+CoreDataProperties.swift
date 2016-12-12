//
//  User+CoreDataProperties.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/16/16.
//  Copyright © 2016 The Oven. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var id: String?
    @NSManaged var entries: NSOrderedSet?
    @NSManaged var lastWatchSyncDate: Date
    @NSManaged var services: NSOrderedSet?
}
