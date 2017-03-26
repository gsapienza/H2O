//
//  AppUserDefaults.swift
//  H2O
//
//  Created by Gregory Sapienza on 9/18/16.
//  Copyright © 2016 City Pixels. All rights reserved.
//

import Foundation

class AppUserDefaults {
    
    /// Write to User Defaults if the app has been opened at least once.
    ///
    /// - parameter openedOnce: True if the app has been opened one time, false if it has not.
    class func setAppWasOpenedOnce(openedOnce :Bool) {
        UserDefaults.standard.set(openedOnce, forKey: AppOpenedForFirstTimeDefault)
    }
    
    /// Get the value of if the app was opened once from User Defaults.
    ///
    /// - returns: True if the app has been opened one time, false if it has not.
    class func getWasOpenedOnce() -> Bool {
        return UserDefaults.standard.bool(forKey: AppOpenedForFirstTimeDefault)
    }
    
    /// Write to User Defaults if initial boarding was dismissed.
    ///
    /// - parameter dismissed: True if boarding was dismissed, false if it has not.
    class func setBoardingWasDismissed(dismissed :Bool) {
        UserDefaults.standard.set(dismissed, forKey: BoardingWasDismissedDefault)
    }
    
    /// Get the value of if initial boarding was dismissed from User Defaults.
    ///
    /// - returns: True if the was dismissed, false if it has not.
    class func getBoardingWasDismissed() -> Bool {
        return UserDefaults.standard.bool(forKey: BoardingWasDismissedDefault)
    }
    
    /// Write to user defaults if the information view controller was opened at least once.
    ///
    /// - parameter openedOnce: True if the information view controller was opened by a user once, false if they have not.
    class func setInformationViewControllerWasOpenedOnce(openedOnce :Bool) {
        UserDefaults.standard.set(openedOnce, forKey: InformationViewControllerOpenedBeforeDefault)
    }
    
    /// Get the value of if the information view controller was opened at least once from User Defaults.
    ///
    /// - returns: True if the infomation view controller was opened once, false if it has not been.
    class func getInformationViewControllerWasOpenedOnce() -> Bool {
        return UserDefaults.standard.bool(forKey: InformationViewControllerOpenedBeforeDefault)
    }
    
    /// Write the water preset values to User Defaults.
    ///
    /// - parameter presets: An array of presets in the order of which to display.
    class func setPresetWaterValues(presets :[Float]) {
        UserDefaults.standard.set(presets, forKey: PresetWaterValuesDefault)
    }
    
    /// Get the water preset values from User Defaults.
    ///
    /// - returns: Array of presets in order of which to display. Nil if not yet set.
    class func getPresetWaterValues() -> [Float]? {
        let presetWaterValues = UserDefaults.standard.array(forKey: PresetWaterValuesDefault) as? [Float]
        
        guard presetWaterValues != nil else {
            return nil
        }
        
        return presetWaterValues
    }
    
    /// Write the daily goal value to User Defaults.
    ///
    /// - parameter goal: Value of daily goal.
    class func setDailyGoalValue(goal :Float) {
        let goalValueString = DailyGoalValueDefault
        
        UserDefaults.standard.set(goal, forKey: goalValueString)
    }
    
    /// Get the daily goal value from User Defaults.
    ///
    /// - returns: The daily goal value.
    class func getDailyGoalValue() -> Float? {
        let goalValueString = DailyGoalValueDefault
        let goalValue = UserDefaults.standard.float(forKey: goalValueString)
        
        guard goalValue != 0 else {
            return nil
        }
        
        return goalValue
    }
}
