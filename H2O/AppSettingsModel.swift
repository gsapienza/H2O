//
//  AppSettingsModel.swift
//  H2O
//
//  Created by Gregory Sapienza on 2/25/17.
//  Copyright © 2017 Skyscrapers.IO. All rights reserved.
//

import UIKit

struct AppSettingsModel {
    static func appSettings() -> [[Setting]]? {
        var settings: [[Setting]] = []
        
        var firstSectionSettings: [Setting] = []
        
        for service in SupportedServices.allSupportedServices() {
            let service = Setting(id: service.rawValue, imageName: "healthKitCellImage", title: "Enable \(service.rawValue)", primaryAction: {
                service.model().authorize(completion: { (success: Bool, error: Error?, message: String?) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                })
            })
            
            firstSectionSettings.append(service)
        }
        
        var secondSectionSettings: [Setting] = []
        
        guard let goalValue = AppUserDefaults.getDailyGoalValue() else {
            return nil
        }
        
        let goalChangerView = PresetValueChangerView()
        goalChangerView.alignment = .right
        let goalSetting = Setting(imageName: "goalCellImage", title: "Goal", control: goalChangerView) {
            AppUserDefaults.setDailyGoalValue(goal: goalChangerView.currentValue)
        }
        
        secondSectionSettings.append(goalSetting)
        
        /// What to call when a preset has been updated. Sets the user defaults, a message to the watch and changed the 3D touch shortcuts.
        ///
        /// - parameter presetWaterValues: Preset values to replace the ones in User Defaults
        func updatePresets(presetWaterValues :[Float]) {
            AppUserDefaults.setPresetWaterValues(presets: presetWaterValues)
            AppDelegate.createShortcuts() //Updates 3D touch shortcuts based on new presets
        }
        
        guard var presetWaterValues = AppUserDefaults.getPresetWaterValues() else { //Existing preset water values
            return nil
        }
        
        let smallPresetChangerView = PresetValueChangerView()
        smallPresetChangerView.alignment = .right
        let smallPresetSetting = Setting(imageName: "darkSmallPresetImage", title: "Small Preset", control: smallPresetChangerView) {
            presetWaterValues[0] = smallPresetChangerView.currentValue
            updatePresets(presetWaterValues: presetWaterValues)
        }
        
        
        let mediumPresetChangerView = PresetValueChangerView()
        mediumPresetChangerView.alignment = .right
        let mediumPresetSetting = Setting(imageName: "darkMediumPresetImage", title: "Medium Preset", control: mediumPresetChangerView) {
            presetWaterValues[1] = mediumPresetChangerView.currentValue
            updatePresets(presetWaterValues: presetWaterValues)
        }
        
        let largePresetChangerView = PresetValueChangerView()
        largePresetChangerView.alignment = .right
        let largePresetSetting = Setting(imageName: "darkLargePresetImage", title: "Large Preset", control: largePresetChangerView) {
            presetWaterValues[2] = largePresetChangerView.currentValue
            updatePresets(presetWaterValues: presetWaterValues)
        }
        
        let thirdSectionSettings = [smallPresetSetting, mediumPresetSetting, largePresetSetting]
        
        settings = [firstSectionSettings, secondSectionSettings, thirdSectionSettings]
        
        goalSetting.setValue(value: goalValue)
        smallPresetSetting.setValue(value: presetWaterValues[0])
        mediumPresetSetting.setValue(value: presetWaterValues[1])
        largePresetSetting.setValue(value: presetWaterValues[2])
        
        return settings
    }
}
