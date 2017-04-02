//
//  ServiceIntergrationProtocol.swift
//  H2O
//
//  Created by Gregory Sapienza on 12/12/16.
//  Copyright © 2016 City Pixels. All rights reserved.
//

import Foundation

protocol ServiceIntergrationProtocol {
    /**
     Authorize by throwing up prompt to ask a user for permissions.
     
     - parameter completion: When authorization is complete.
     */
    func authorize(completion: @escaping ((_ success: Bool, _ error: Error?, _ token: String?) -> Void))
    
    /**
     Save a water amount to service.
     
     - parameter amount: Amount of water to save in fl oz.
     - parameter date:   Date that water was saved.
     */
    func addEntry(amount: Float, date: Date)
    
    /**
     Deletes water entry.
     
     - parameter date: Date of entry to use as key to search for entry.
     */
    func deleteEntry(date: Date)
    
    /// Gets status of authorization for service.
    ///
    /// - Returns: True if the user has allowed the app to write water to service.
    func isAuthorized() -> Bool
}
