//
//  AppUserDefaults.swift
//  H2O
//
//  Created by Gregory Sapienza on 9/18/16.
//  Copyright © 2016 City Pixels. All rights reserved.
//

import Foundation

let extensionGroupName = "group.H2O.ExtensionSharing"
let groupDefaults = UserDefaults(suiteName: extensionGroupName)!

class AppUserDefaults {
    
    /// Write to User Defaults if the app has been opened at least once.
    ///
    /// - parameter openedOnce: True if the app has been opened one time, false if it has not.
    class func setAppWasOpenedOnce(openedOnce: Bool) {
        groupDefaults.set(openedOnce, forKey: AppOpenedForFirstTimeDefault)
    }
    
    /// Get the value of if the app was opened once from User Defaults.
    ///
    /// - returns: True if the app has been opened one time, false if it has not.
    class func getWasOpenedOnce() -> Bool {
        
        if UserDefaults.standard.dictionaryRepresentation()[AppOpenedForFirstTimeDefault] != nil {
            let value = UserDefaults.standard.bool(forKey: AppOpenedForFirstTimeDefault)
            setAppWasOpenedOnce(openedOnce: value)
            UserDefaults.standard.removeObject(forKey: AppOpenedForFirstTimeDefault)
        }
        
        return groupDefaults.bool(forKey: AppOpenedForFirstTimeDefault)
    }
    
    /// Write to User Defaults if initial boarding was dismissed.
    ///
    /// - parameter dismissed: True if boarding was dismissed, false if it has not.
    class func setBoardingWasDismissed(dismissed: Bool) {
        groupDefaults.set(dismissed, forKey: BoardingWasDismissedDefault)
    }
    
    /// Get the value of if initial boarding was dismissed from User Defaults.
    ///
    /// - returns: True if the was dismissed, false if it has not.
    class func getBoardingWasDismissed() -> Bool {
        
        if UserDefaults.standard.dictionaryRepresentation()[BoardingWasDismissedDefault] != nil {
            let value = UserDefaults.standard.bool(forKey: BoardingWasDismissedDefault)
            setBoardingWasDismissed(dismissed: value)
            UserDefaults.standard.removeObject(forKey: BoardingWasDismissedDefault)
        }
        
        return groupDefaults.bool(forKey: BoardingWasDismissedDefault)
    }
    
    /// Write to user defaults if the information view controller was opened at least once.
    ///
    /// - parameter openedOnce: True if the information view controller was opened by a user once, false if they have not.
    class func setInformationViewControllerWasOpenedOnce(openedOnce: Bool) {
        groupDefaults.set(openedOnce, forKey: InformationViewControllerOpenedBeforeDefault)
    }
    
    /// Get the value of if the information view controller was opened at least once from User Defaults.
    ///
    /// - returns: True if the infomation view controller was opened once, false if it has not been.
    class func getInformationViewControllerWasOpenedOnce() -> Bool {
        
        if UserDefaults.standard.dictionaryRepresentation()[InformationViewControllerOpenedBeforeDefault] != nil {
            let value = UserDefaults.standard.bool(forKey: InformationViewControllerOpenedBeforeDefault)
            setInformationViewControllerWasOpenedOnce(openedOnce: value)
            UserDefaults.standard.removeObject(forKey: InformationViewControllerOpenedBeforeDefault)
        }

        return groupDefaults.bool(forKey:InformationViewControllerOpenedBeforeDefault)
    }
    
    /// Write the water preset values to User Defaults.
    ///
    /// - parameter presets: An array of presets in the order of which to display.
    class func setPresetWaterValues(presets: [Float]) {
        groupDefaults.set(presets, forKey: PresetWaterValuesDefault)
    }
    
    /// Get the water preset values from User Defaults.
    ///
    /// - returns: Array of presets in order of which to display. Nil if not yet set.
    class func getPresetWaterValues() -> [Float]? {
        
        if UserDefaults.standard.dictionaryRepresentation()[PresetWaterValuesDefault] != nil {
            let value = UserDefaults.standard.array(forKey: PresetWaterValuesDefault)
            
            if let value = value as? [Float] {
                setPresetWaterValues(presets: value)
            }
            
            UserDefaults.standard.removeObject(forKey: PresetWaterValuesDefault)
        }
        
        if let presetWaterValues = groupDefaults.array(forKey: PresetWaterValuesDefault) as? [Float] {
            return presetWaterValues
        } else {
            return nil
        }        
    }
    
    /// Write the daily goal value to User Defaults.
    ///
    /// - parameter goal: Value of daily goal.
    class func setDailyGoalValue(goal: Float) {
        groupDefaults.set(goal, forKey: DailyGoalValueDefault)
    }
    
    /// Get the daily goal value from User Defaults.
    ///
    /// - returns: The daily goal value.
    class func getDailyGoalValue() -> Float? {
        
        if UserDefaults.standard.dictionaryRepresentation()[DailyGoalValueDefault] != nil {
            let value = UserDefaults.standard.float(forKey: DailyGoalValueDefault)
            setDailyGoalValue(goal: value)
            UserDefaults.standard.removeObject(forKey: DailyGoalValueDefault)
        }
        
        let goalValue = groupDefaults.float(forKey: DailyGoalValueDefault)

        guard goalValue != 0 else {
            return nil
        }
        
        return goalValue
    }
}
