//
//  Service+CoreDataProperties.swift
//  H2O
//
//  Created by Gregory Sapienza on 12/12/16.
//  Copyright © 2016 Midnite. All rights reserved.
//

import Foundation
import CoreData


extension Service {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Service> {
        return NSFetchRequest<Service>(entityName: "Service");
    }

    @NSManaged public var name: String
    @NSManaged public var token: String?
    @NSManaged public var isAuthorized: NSNumber
    @NSManaged public var user: User?
}
