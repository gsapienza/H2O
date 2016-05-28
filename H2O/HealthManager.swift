//
//  HealthManager.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/28/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit
import HealthKit

class HealthManager: NSObject {
        /// Singleton var for the health manager class
    static let defaultManager = HealthManager()

        /// Place to save and manage objects
    private let _healthKitStore = HKHealthStore()
    
    /**
     Authorize healthkit by throwing up prompt to ask a user for permissions
     
     - parameter completion: When authorization is complete
     */
    func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!) {
        let healthKitTypesToWrite :Set = [HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryWater)!] //Write to water type (read is not available)
        
        if !HKHealthStore.isHealthDataAvailable() { //If health data is not available say on an iPad
            let error = NSError(domain: "com.theoven.H2O", code: 2, userInfo: [NSLocalizedDescriptionKey : "HealthKit is not available in this Device"])
            
            completion(success: false, error: error) //Return false
        }
        
        //Request authorization
        _healthKitStore.requestAuthorizationToShareTypes(healthKitTypesToWrite, readTypes: nil) { (success :Bool, error :NSError?) in
            completion(success :success, error: error)
        }
    }
    
    /**
     Save a water amount to Health App
     
     - parameter amount: Amount of water to save in fl oz
     - parameter date:   Date that water was saved
     */
    func saveWaterAmountToHealthKit(amount :Float, date :NSDate) {
        let waterType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryWater) //Type of health data to add
        let waterQuantity = HKQuantity(unit: HKUnit.fluidOunceUSUnit(), doubleValue: Double(amount)) //Quantity of water with the unit of measurement
        let waterSample = HKQuantitySample(type: waterType!, quantity: waterQuantity, startDate: date, endDate: date) //HKObject with appropriate water data and date so it can now be saved
        
        _healthKitStore.saveObject(waterSample) { (success :Bool, error :NSError?) in //Save the object to the health app
            if success {
                print("Health Data Saved Successfully")
            } else {
                print("Health Data Save Unsuccessful")
            }
        }
    }
    
    /**
     Deletes water entry created by this app only by comparing start dates to those entered into the Health database
     
     - parameter date: Date of entry to use as key to search for entry in Health database
     */
    func deleteWaterEntry(date :NSDate) {
        let waterType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryWater) //Type of health data to add

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false) //Sort descriptor by start date
        
        let calendar = NSCalendar.currentCalendar() //Calendar type
        
        let entryDateComponents = calendar.components([.Day, .Month, .Year, .Hour, .Minute, .Second], fromDate: date) //Components up to the second for the entry date. Milliseconds is too strict on the comparison
        
        //Query the health database
        let healthSampleQuery = HKSampleQuery(sampleType: waterType!, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query :HKSampleQuery, samples :[HKSample]?, error :NSError?) in
            
            for sample in samples! { //For each entry created by app
                let sampleDateComponents = calendar.components([.Day, .Month, .Year, .Hour, .Minute, .Second], fromDate: sample.startDate) //Components of sample entry up to the second

                if calendar.dateFromComponents(entryDateComponents)?.compare(calendar.dateFromComponents(sampleDateComponents)!) == .OrderedSame { //Compare dates without the milliseconds
                    
                    //If found delete the item from Health Kit
                    self._healthKitStore.deleteObject(sample, withCompletion: { (success :Bool, error :NSError?) in
                        if success {
                            print("Health Data Deleted Successfully")
                        } else {
                            print("Health Data Deleted Unsuccessful")
                        }
                    })
                }
            }
        }
        
        _healthKitStore.executeQuery(healthSampleQuery) //Execute the query on health kit database
    }
}
