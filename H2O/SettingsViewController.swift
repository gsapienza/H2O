//
//  SettingsViewController.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/17/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

/**
 Size of preset
 
 - Small:  Small water amount
 - Medium: Medium water amount
 - Large:  Large water amount
 */
enum PresetSize {
    case small
    case medium
    case large
}

protocol SettingsViewControllerProtocol {
    /**
     Called when the goal has been updated in the settings
     
     - parameter newValue: New goal value
     */
    func goalUpdated( newValue :Float)
    
    /**
     Called when one of the presets has been updated in the settings
     
     - parameter presetSize: Preset size to update
     - parameter newValue:     New preset value
     */
    func presetUpdated( presetSize :PresetSize, newValue :Float)
}

class SettingsViewController: UITableViewController {
    var delegate :SettingsViewControllerProtocol?

    /// HealthKit static cell
    @IBOutlet weak var healthKitCell: SettingsTableViewCell!
    
    /// Goal static cell
    @IBOutlet weak var goalCell: SettingsPresetTableViewCell!
    
    //MARK: - Preset Cells
    
    /// Small preset static cell
    @IBOutlet weak var presetCell1: SettingsPresetTableViewCell!
    
    /// Medium preset static cell
    @IBOutlet weak var presetCell2: SettingsPresetTableViewCell!
    
    /// Large preset static cell
    @IBOutlet weak var presetCell3: SettingsPresetTableViewCell!
    
    //MARK: - Theme Elements
    
    /// Cell to toggle dark mode
    @IBOutlet weak var themeCell: SettingsTableViewCell!
    
    /// Cell to toggle whether dark mode should turn on automatically later in the day
    @IBOutlet weak var automaticThemeCell: SettingsTableViewCell!
    
    /// Switch to control the apps current theme
    @IBOutlet weak var themeSwitch: UISwitch!
    
    /// Switch to control the theme based on time of day
    @IBOutlet weak var automaticThemeSwitch: UISwitch!
    
    //MARK: - View Setup
    
    /**
     Basic setup helper functions
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = StandardColors.backgroundColor
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: -1, width: 0, height: 1)) //Covers the bottom lines in the table view including the last cells line
        tableView.separatorColor = StandardColors.primaryColor.withAlphaComponent(0.2)
        
        setupNavigationBar()
        setupCells()
        setupToggles()
    }
    
    /**
     Sets up view properties for the navigation bar
     */
    private func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = StandardColors.standardSecondaryColor
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = settings_navigation_title_localized_string
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: StandardColors.primaryColor, NSFontAttributeName: StandardFonts.boldFont(size: 20)] //Navigation bar view properties
        
        let closeButton = UIBarButtonItem(title: close_navigation_item_localized_string, style: .plain, target: self, action: #selector(SettingsViewController.onCloseButton)) //Left close button
        
        closeButton.setTitleTextAttributes([NSForegroundColorAttributeName: StandardColors.primaryColor, NSFontAttributeName: StandardFonts.regularFont(size: 18)], for: UIControlState()) //Close button view properties
        
        navigationItem.leftBarButtonItem = closeButton
    }
    
    /**
     Setup properties for the static cells in settings
     */
    private func setupCells() {
        //Health cell config
        healthKitCell.cellImageView.image = UIImage(assetIdentifier: .healthKitCellImage)
        updateHealthKitCell()
        
        //Goal cell config
        goalCell.cellImageView.image = UIImage(assetIdentifier: .goalCellImage)
        goalCell.cellTextLabel.text = daily_goal_setting_localized_string
        
        if let goal = AppUserDefaults.getDailyGoalValue() {
            goalCell.presetValueChangerView.presetValueTextField.text = String(Int(goal))
            goalCell.delegate = self
        }
        
        var presetImages :[UIImage]! //Preset images based on light and dark modes.
        
        if AppUserDefaults.getDarkModeEnabled() {
            presetImages = [UIImage(assetIdentifier: .darkSmallPresetImage), UIImage(assetIdentifier: .darkMediumPresetImage), UIImage(assetIdentifier: .darkLargePresetImage)]
        } else {
            presetImages = [UIImage(assetIdentifier: .lightLargePresetImage), UIImage(assetIdentifier: .lightMediumPresetImage), UIImage(assetIdentifier: .lightLargePresetImage)]

        }
        
        //Preset cells config
        if let presetWaterValues = AppUserDefaults.getPresetWaterValues() {
            //Small preset
            presetCell1.cellImageView.image = presetImages[0]
            presetCell1.cellTextLabel.text = small_preset_setting_localized_string
            presetCell1.presetValueChangerView.presetValueTextField.text = String(Int(presetWaterValues[0]))
            presetCell1.delegate = self
            
            //Medium preset
            presetCell2.cellImageView.image = presetImages[1]
            presetCell2.cellTextLabel.text = medium_preset_setting_localized_string
            presetCell2.presetValueChangerView.presetValueTextField.text = String(Int(presetWaterValues[1]))
            presetCell2.delegate = self
            
            //Large preset
            presetCell3.cellImageView.image = presetImages[2]
            presetCell3.cellTextLabel.text = large_preset_setting_localized_string
            presetCell3.presetValueChangerView.presetValueTextField.text = String(Int(presetWaterValues[2]))
            presetCell3.delegate = self
        }
        
        //Dark Mode cell config
        themeCell.cellImageView.image = UIImage(assetIdentifier: .darkModeCellImage)
        themeCell.cellTextLabel.text = dark_mode_setting_localized_string
        themeSwitch.onTintColor = StandardColors.waterColor
        
        //Automatic theme cell config
        automaticThemeCell.cellImageView.image = UIImage(assetIdentifier: .automaticThemeChangeCellImage)
        automaticThemeCell.cellTextLabel.text = auto_switch_themes_setting_localized_string
        automaticThemeSwitch.onTintColor = StandardColors.waterColor
    }
    
    /**
     Sets up the toggles in settings
     */
    private func setupToggles() {
        if AppUserDefaults.getDarkModeEnabled() { //Configure theme switch depeding on current color
            themeSwitch.setOn(true, animated: false)
        } else {
            themeSwitch.setOn(false, animated: false)
        }
        
        let automaticThemeChangeEnabled = AppUserDefaults.getAutomaticThemeChangeEnabled()
        
        if automaticThemeChangeEnabled { //If automatic theme changer is on then disable the theme switch cell as it would intefere with the automatic changing
            automaticThemeSwitch.setOn(true, animated: false)
            themeCell.cellTextLabel.alpha = 0.5
            themeSwitch.isEnabled = false
        } else {
            automaticThemeSwitch.setOn(false, animated: false)
        }
    }
    
    //MARK: - Table View Overrides

    /**
     Makes the table view section headers above section of cells transparent
     */
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = StandardColors.primaryColor
    }
    
    //MARK: - Actions

    /**
     Action for close bar button. Dismisses setting view
     */
    func onCloseButton() {
        dismiss(animated: true) {
        }
    }
    
    //MARK: - Health Actions
    
    /**
     Action when the HealthKit switch is toggled
     
     - parameter sender: HealthKit Switch
     */
    @IBAction func onHealthKitSwitch( sender: AnyObject) {
        HealthManager.defaultManager.authorizeHealthKit { (success, error) in
            if success {
                print("HealthKit authorization successful")
            } else {
                print("Could not authorize HealthKit")
            }
        }
    }
    
    /**
     Action when the "Enable HealthKit" button that fills the cell is tapped. Shows modal so user can toggle healthkit permissions
     
     - parameter sender: Button in cell
     */
    @IBAction func onHealthKitButton( sender: AnyObject) {
        HealthManager.defaultManager.authorizeHealthKit { (success, error) in //Prompt user to enable healthkit using standard permissions modal
            AppUserDefaults.setHealthKitPermissionsDisplayed(displayed: true) //Health permission were shown once (the limit to the amount of times they can be shown according to apple)

            DispatchQueue.main.async {
                self.updateHealthKitCell() //Update healthkit cell to say to manage healthkit permissions through health app
            }
            
            if success {
                print("HealthKit authorization successful")
            } else {
                print("Could not authorize HealthKit")
            }
        }
    }
    
    /**
     When the health permissions prompt has come up once. Apple makes it so that it cant come up again in your app. So we disable it if it has already come up and tell the user to manage permission in the health app
     */
    private func updateHealthKitCell() {
        let wereHealthKitPermissionsShown = AppUserDefaults.getHealthKitPermissionsDisplayed() //If permissions were shown
        
        if wereHealthKitPermissionsShown {
            healthKitCell.isUserInteractionEnabled = false //Disable cell interaction
            healthKitCell.cellTextLabel.text = manage_healthkit_setting_localized_string //Change text because "Enable Healthkit" is not appropriate anymore
            healthKitCell.cellTextLabel.alpha = 0.5 //Fade out text to make it look not enabled
            healthKitCell.fillCellWithTextLabel() //Fills the text label autolayout to fill entire cell since there are no other elements around
        } else { //If healthkit permissions have not been shown
            healthKitCell.cellTextLabel.text = enable_healthkit_setting_localized_string //Allow user to enable healthkit through permissions
        }
    }
    
    //MARK: - Theme Actions
    
    /**
     Action when the theme switch is toggled
     
     - parameter sender: Theme switch
     */
    @IBAction func onThemeSwitch( sender: UISwitch) {
        AudioToolbox.standardAudioToolbox.playAudio(ClickSound, repeatEnabled: false)

        AppUserDefaults.setDarkModeEnabled(enabled: sender.isOn) //Change theme based on switch state
        
        view.endEditing(true) //Dismisses keyboard... Too bad this doesnt work very well
        NotificationCenter.default.post(name: DarkModeToggledNotification, object: nil)
    }
    
    /**
     Action when the automatic theme switch is toggled
     
     - parameter sender: Automatic theme changer switch
     */
    @IBAction func onAutomaticThemeSwitch( sender: UISwitch) {
        AudioToolbox.standardAudioToolbox.playAudio(ClickSound, repeatEnabled: false)
        AppUserDefaults.setAutomaticThemeChangeEnabled(enabled: sender.isOn)
        
        if sender.isOn { //If on then essentially disable the theme cell because it would intefere with the auto changes
            themeCell.cellTextLabel.alpha = 0.5
            themeSwitch.isEnabled = false
        } else { //If its off then reenable the theme cell
            themeCell.cellTextLabel.alpha = 1
            themeSwitch.isEnabled = true
        }
        
        getAppDelegate().checkToSwitchThemes() //Switch themes if necessary based on time of day
    }
}

// MARK: - SettingsPresetTableViewCellProtocol
extension SettingsViewController :SettingsPresetTableViewCellProtocol {
    
    /**
     A preset value has been changed within a settings cell so update all values in NSUserDefaults
     
     - parameter settingsPresetTableViewCell: Which cell made the change
     - parameter newValue:                    New value for the preset
     */
    func presetValueDidChange(settingsPresetTableViewCell: SettingsPresetTableViewCell, newValue :Float) {
        
        /// What to call when a preset has been updated. Sets the user defaults, a message to the watch and changed the 3D touch shortcuts.
        ///
        /// - parameter presetWaterValues: Preset values to replace the ones in User Defaults
        func updatePresets(presetWaterValues :[Float]) {
            AppUserDefaults.setPresetWaterValues(presets: presetWaterValues)
            WatchConnection.standardWatchConnection.sendPresetsUpdatedMessage(presets: presetWaterValues)
            AppDelegate.createShortcuts() //Updates 3D touch shortcuts based on new presets
        }
        
        if var presetWaterValues = AppUserDefaults.getPresetWaterValues() { //Existing preset water values
            switch settingsPresetTableViewCell {
            case goalCell:
                AppUserDefaults.setDailyGoalValue(goal: newValue)
                delegate?.goalUpdated(newValue: newValue) //Update goal in main view
                WatchConnection.standardWatchConnection.sendGoalUpdatedMessage(goal: newValue)
            case presetCell1:
                presetWaterValues[0] = newValue
                delegate?.presetUpdated(presetSize: .small, newValue: newValue) //Update preset in main view
                updatePresets(presetWaterValues: presetWaterValues)
            case presetCell2:
                presetWaterValues[1] = newValue
                delegate?.presetUpdated(presetSize: .medium, newValue: newValue) //Update preset in main view
                updatePresets(presetWaterValues: presetWaterValues)
            case presetCell3:
                presetWaterValues[2] = newValue
                delegate?.presetUpdated(presetSize: .large, newValue: newValue) //Update preset in mainview
                updatePresets(presetWaterValues: presetWaterValues)
                return
            default:
                break
            }
        }
    }
}
