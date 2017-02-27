//
//  AppSettingsModel.swift
//  H2O
//
//  Created by Gregory Sapienza on 2/25/17.
//  Copyright © 2017 Skyscrapers.IO. All rights reserved.
//

import UIKit


class AppSettingsModel {
    
    /// Delegate to callback to view controller.
    var delegate: AppSettingsViewControllerProtocol?
    
    
    /// Gets settings to use as data source for table view.
    ///
    /// - Returns: Settings collection with each section representing a section in the table view.
    func appSettings() -> Settings<Setting>? {
        var settings = Settings<Setting>()
        
        //---Services---//
        
        var firstSection: [Setting] = SupportedServices.allSupportedServices().map { (service: SupportedServices) in
            let serviceSetting = Setting(id: service.rawValue, imageName: "healthKitCellImage", title: "Enable \(service.rawValue)", primaryAction: { setting in
                
                service.model().authorize(completion: { (success: Bool, error: Error?, message: String?) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        DispatchQueue.main.async {
                            setting.title = "Manage HealthKit in the Health App"
                            self.delegate?.reloadData()
                        }
                    }
                })
            })
            
            return serviceSetting
        }
        
        settings.appendSection(firstSection)
        
        //---Goal---//
        
        guard let goalValue = AppUserDefaults.getDailyGoalValue() else {
            return nil
        }
        
        let goalChangerView = PresetValueChangerView()
        goalChangerView.alignment = .right
        let goalSetting = Setting(imageName: "goalCellImage", title: "Goal", control: goalChangerView) {_ in
            AppUserDefaults.setDailyGoalValue(goal: goalChangerView.currentValue)
        }
        
        settings.appendSection([goalSetting])
        
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
        
        //---Presets---//
        
        let smallPresetChangerView = PresetValueChangerView()
        smallPresetChangerView.alignment = .right
        let smallPresetSetting = Setting(imageName: "darkSmallPresetImage", title: "Small Preset", control: smallPresetChangerView) {_ in 
            presetWaterValues[0] = smallPresetChangerView.currentValue
            updatePresets(presetWaterValues: presetWaterValues)
        }
        
        
        let mediumPresetChangerView = PresetValueChangerView()
        mediumPresetChangerView.alignment = .right
        let mediumPresetSetting = Setting(imageName: "darkMediumPresetImage", title: "Medium Preset", control: mediumPresetChangerView) {_ in 
            presetWaterValues[1] = mediumPresetChangerView.currentValue
            updatePresets(presetWaterValues: presetWaterValues)
        }
        
        let largePresetChangerView = PresetValueChangerView()
        largePresetChangerView.alignment = .right
        let largePresetSetting = Setting(imageName: "darkLargePresetImage", title: "Large Preset", control: largePresetChangerView) {_ in 
            presetWaterValues[2] = largePresetChangerView.currentValue
            updatePresets(presetWaterValues: presetWaterValues)
        }
        
        settings.appendSection([smallPresetSetting, mediumPresetSetting, largePresetSetting])
        
        //---Initial Values---//
        
        goalSetting.control?.setValue(value: goalValue)
        smallPresetSetting.control?.setValue(value: presetWaterValues[0])
        mediumPresetSetting.control?.setValue(value: presetWaterValues[1])
        largePresetSetting.control?.setValue(value: presetWaterValues[2])
        
        return settings
    }
}
