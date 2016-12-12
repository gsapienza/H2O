//
//  HealthKitService.swift
//  H2O
//
//  Created by Gregory Sapienza on 12/12/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitService :ServiceIntergrationProtocol {
    /// Place to save and manage objects
    private var healthKitStore :HKHealthStore?
    
    func authorize(completion: @escaping ((_ success :Bool, _ error :Error?, _ token :String?) -> Void)) {
        let healthKitTypesToWrite :Set = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater)!] //Write to water type (read is not available)
        
        if !HKHealthStore.isHealthDataAvailable() { //If health data is not available say on an iPad
            let error = NSError(domain: "com.theoven.H2O", code: 2, userInfo: [NSLocalizedDescriptionKey : "HealthKit is not available on this Device"])
            
            completion(false, error, nil)
            // completion(success: false, error: error) //Return false
        }
        
        healthKitStore = HKHealthStore()
        
        //Request authorization
        healthKitStore?.requestAuthorization(toShare: healthKitTypesToWrite, read: nil) { (success :Bool, error :Error?) in
            if success {
                self.addPreviousHealthKitData() //If authorized see if any previous data was entered in health from previous installs and add it to the apps database
            }
            
            completion(success, error, nil)
        }
    }
    
    func addEntry(amount: Float, date: Date) {
        let waterType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater) //Type of health data to add
        let waterQuantity = HKQuantity(unit: HKUnit.fluidOunceUS(), doubleValue: Double(amount)) //Quantity of water with the unit of measurement
        let waterSample = HKQuantitySample(type: waterType!, quantity: waterQuantity, start: date, end: date) //HKObject with appropriate water data and date so it can now be saved
        
        healthKitStore?.save(waterSample) { (success :Bool, error :Error?) in //Save the object to the health app
            if success {
                print("Health Data Saved Successfully")
            } else {
                print("Health Data Save Unsuccessful")
            }
        }
    }
    
    func deleteEntry(date: Date) {
        if isAuthorized() { //If the app is able to write water to healthkit
            let waterType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater) //Type of health data to add
            
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false) //Sort descriptor by start date
            
            let calendar = Calendar.current //Calendar type
            
            let entryDateComponents = calendar.dateComponents([.day, .month, .year, .hour, .minute, .second], from: date) //Components up to the second for the entry date. Milliseconds is too strict on the comparison
            
            //Query the health database
            let healthSampleQuery = HKSampleQuery(sampleType: waterType!, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query :HKSampleQuery, samples :[HKSample]?, error :Error?) in
                for sample in samples! { //For each entry created by app
                    let sampleDateComponents = calendar.dateComponents([.day, .month, .year, .hour, .minute, .second], from: sample.startDate) //Components of sample entry up to the second
                    
                    if calendar.date(from: entryDateComponents)?.compare(calendar.date(from: sampleDateComponents)!) == .orderedSame { //Compare dates without the milliseconds
                        
                        //If found delete the item from Health Kit
                        self.healthKitStore?.delete(sample, withCompletion: { (success :Bool, error :Error?) in
                            if success {
                                print("Health Data Deleted Successfully")
                            } else {
                                print("Health Data Deleted Unsuccessful")
                            }
                        })
                    }
                }
            }
            
            healthKitStore?.execute(healthSampleQuery) //Execute the query on health kit database
        } else { //Water cannot be written to healthkit
            print("Water not authorized to write in HealthKit")
        }
    }
    
    func isAuthorized() -> Bool {
        healthKitStore = HKHealthStore()

        let waterType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater)! //Type of health data to look at
        let authStatus = healthKitStore?.authorizationStatus(for: waterType) //Status of water permission in health
        
        if authStatus == .sharingAuthorized { //If authorized to share return true
            return true
        } else {
            return false
        }
    }
    
    /**
     Gets previous values in healthkit for say a previous install and restores them to the app
     */
    private func addPreviousHealthKitData() {
        let waterType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater) //Type of health data to add
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true) //Sort descriptor by start date
        
        //Query the health database
        let healthSampleQuery = HKSampleQuery(sampleType: waterType!, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query :HKSampleQuery, samples :[HKSample]?, error :Error?) in
            
            for sample in samples! { //For each entry created by app
                let category = sample as! HKQuantitySample //Get the water entry
                let sampleDate = category.startDate //Start date for water entry
                let sampleAmount = category.quantity.doubleValue(for: HKUnit.fluidOunceUS()) //Amount of water entered
                
                let id = UUID().uuidString
                let entry = Entry.createNewEntry(id: id, amount: Float(sampleAmount), date: sampleDate, creationDate: sampleDate, modificationDate: sampleDate, wasDeleted: false)
                getAppDelegate().user?.addEntry(entry: entry) //Adds water to database
            }
        }
        
        healthKitStore?.execute(healthSampleQuery) //Execute the query on health kit database
    }
}
