//
//  Service+CoreDataClass.swift
//  H2O
//
//  Created by Gregory Sapienza on 12/12/16.
//  Copyright © 2016 City Pixels. All rights reserved.
//

import Foundation
import CoreData

public class Service: NSManagedObject {
    class func create(name: String, token: String?, isAuthorized: Bool) -> Service? {
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
    
    class func serviceForName(managedObjectContext: NSManagedObjectContext, serviceName: String) -> Service? {
        let request: NSFetchRequest = Service.fetchRequest()
        request.entity = NSEntityDescription.entity(forEntityName: "Service", in: User.managedContext())
        
        let pred = NSPredicate(format: "(name = %@)", serviceName)
        request.predicate = pred
        
        do {
            let results = try managedObjectContext.fetch(request as! NSFetchRequest<NSFetchRequestResult>)
            
            if results.count == 0 {
                return nil
            } else {
                guard let service = results.first as? Service else {
                    fatalError("Service is not correct type.")
                }
                
                return service
            }
            
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
}
