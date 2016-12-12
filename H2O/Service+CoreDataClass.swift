//
//  Service+CoreDataClass.swift
//  H2O
//
//  Created by Gregory Sapienza on 12/12/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import Foundation
import CoreData

public class Service: NSManagedObject {
    class func create(name :String, token :String?, isAuthorized :Bool) -> Service? {
        guard let entity = NSEntityDescription.entity(forEntityName: "Service", in: User.managedContext()) else {
            print("Entity not set.")
            return nil
        }
        
        guard let service = NSManagedObject(entity: entity, insertInto: User.managedContext()) as? Service else {
            print("Service not set.")
            return nil
        }
        
        service.name = name
        service.token = token
        service.isAuthorized = NSNumber(booleanLiteral: isAuthorized)
        
        return service
    }
}
