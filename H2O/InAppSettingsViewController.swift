//
//  InAppSettingsViewController.swift
//  H2O
//
//  Created by Gregory Sapienza on 3/25/17.
//  Copyright © 2017 Skyscrapers.IO. All rights reserved.
//

import UIKit
import SettingsKit

class InAppSettingsViewController: SettingsViewController {

    // MARK: - Strings
    
    /// Title for navigation item.
    private static let navigationTitle = "settings_navigation_title".localized
    
    /// Title for close button in navigation bar.
    private static let closeBarButtonTitle = "close_navigation_item".localized
    
    override func viewDidLoad() {
        dataSource = self
        super.viewDidLoad()
        
        //---View---//
        
        view.backgroundColor = StandardColors.backgroundColor
        
        //---Navigation Item---//
        
        navigationItem.title = InAppSettingsViewController.navigationTitle
        let closeButton = UIBarButtonItem(title: InAppSettingsViewController.closeBarButtonTitle, style: .plain, target: self, action: #selector(onCloseButton)) //Left close button
        closeButton.setTitleTextAttributes([NSForegroundColorAttributeName: StandardColors.primaryColor, NSFontAttributeName: StandardFonts.regularFont(size: 18)], for: UIControlState()) //Close button view properties
        navigationItem.leftBarButtonItem = closeButton
        
        //---Table View---//
        
        tableView.separatorColor = StandardColors.primaryColor.withAlphaComponent(0.2)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: -1, width: 0, height: 1)) //Covers the bottom lines in the table view including the last cells line
        tableView.backgroundColor = .clear
    }
}

// MARK: - SettingsViewControllerDataSource
extension InAppSettingsViewController: SettingsViewControllerDataSource {
    func settings() -> Settings<Setting> {
        var settings = Settings<Setting>()

        //---Services---//
        
        var firstSection: [Setting] = SupportedServices.allSupportedServices().map { (service: SupportedServices) in
            let serviceSetting = Setting(imageName: "healthKitCellImage", title: "Enable \(service.rawValue)", primaryAction: { (setting: Setting) in
                service.model().authorize(completion: { (success: Bool, error: Error?, message: String?) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                })
            }, settingControls: [])
            
            serviceSetting.style = { (cell: SettingsTableViewCell) in
                if service.model().isAuthorized() {
                    cell.titleLabel.text = "Manage HealthKit in the Health App"
                    cell.titleLabel.textColor = UIColor.gray
                } else {
                    cell.titleLabel.textColor = UIColor.white
                }
                
                cell.backgroundColor = StandardColors.standardSecondaryColor
            }
            
            return serviceSetting
        }
        
        settings.appendSection(firstSection)
        
        //---Goal---//
        
        if let goalValue = AppUserDefaults.getDailyGoalValue() {
            let goalControl = SettingControl(type: PresetValueChangerView.self, value: goalValue) { (control: ControlProtocol) in
                if let value = control.getValue() as? Float {
                    AppUserDefaults.setDailyGoalValue(goal: value)
                }
            }
            
            let goalSetting = BasicSetting(imageName: "goalCellImage", title: "Daily Goal", settingControl: goalControl)
            
            goalSetting.style = { (cell: SettingsTableViewCell) in
                cell.titleLabel.textColor = UIColor.white
                cell.backgroundColor = StandardColors.standardSecondaryColor
            }
            
            settings.appendSection([goalSetting])
        }
        
        //---Presets---//
        
        /// What to call when a preset has been updated. Sets the user defaults, a message to the watch and changed the 3D touch shortcuts.
        ///
        /// - parameter presetWaterValues: Preset values to replace the ones in User Defaults
        func updatePresets(presetWaterValues :[Float]) {
            AppUserDefaults.setPresetWaterValues(presets: presetWaterValues)
            AppDelegate.createShortcuts() //Updates 3D touch shortcuts based on new presets
        }
        
        if var presetWaterValues = AppUserDefaults.getPresetWaterValues() { //Existing preset water values
            let smallPresetControl = SettingControl(type: PresetValueChangerView.self, value: presetWaterValues[0]) { (control: ControlProtocol) in
                if let value = control.getValue() as? Float {
                    presetWaterValues[0] = value
                    updatePresets(presetWaterValues: presetWaterValues)
                }
            }
            
            let smallPresetSetting = BasicSetting(imageName: "darkSmallPresetImage", title: "Small Preset", settingControl: smallPresetControl)
            
            smallPresetSetting.style = { (cell: SettingsTableViewCell) in
                cell.titleLabel.textColor = UIColor.white
                cell.backgroundColor = StandardColors.standardSecondaryColor
            }
            
            let mediumPresetControl = SettingControl(type: PresetValueChangerView.self, value: presetWaterValues[1]) { (control: ControlProtocol) in
                if let value = control.getValue() as? Float {
                    presetWaterValues[1] = value
                    updatePresets(presetWaterValues: presetWaterValues)
                }
            }
            
            let mediumPresetSetting = BasicSetting(imageName: "darkMediumPresetImage", title: "Medium Preset", settingControl: mediumPresetControl)
            
            mediumPresetSetting.style = { (cell: SettingsTableViewCell) in
                cell.titleLabel.textColor = UIColor.white
                cell.backgroundColor = StandardColors.standardSecondaryColor
            }
            
            let largePresetControl = SettingControl(type: PresetValueChangerView.self, value: presetWaterValues[2]) { (control: ControlProtocol) in
                if let value = control.getValue() as? Float {
                    presetWaterValues[2] = value
                    updatePresets(presetWaterValues: presetWaterValues)
                }
            }
            
            let largePresetSetting = BasicSetting(imageName: "darkLargePresetImage", title: "Large Preset", settingControl: largePresetControl)
            
            largePresetSetting.style = { (cell: SettingsTableViewCell) in
                cell.titleLabel.textColor = UIColor.white
                cell.backgroundColor = StandardColors.standardSecondaryColor
            }
            
            settings.appendSection([smallPresetSetting, mediumPresetSetting, largePresetSetting])
        }
        
        return settings
    }
    
    //MARK: - Actions
    
    /// Action for close bar button. Dismisses setting view/
    func onCloseButton() {
        dismiss(animated: true) { }
    }
}

//MARK: - SettingControlProtocol
extension PresetValueChangerView: ControlProtocol {
    func setValue(value: Any) {
        guard let value = value as? Float else {
            print("Value must be a float type")
            return
        }

        currentValue = value
    }
    
    func getValue() -> Any {
        return currentValue
    }

    func addTarget(target: Any?, action: Selector) {
        addTarget(target, action: action, for: .editingDidEnd)
    }
}
