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
        tableView.separatorColor = StandardColors.primaryColor
        
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
        navigationItem.title = "Settings"
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: StandardColors.primaryColor, NSFontAttributeName: StandardFonts.boldFont(size: 20)] //Navigation bar view properties
        
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(SettingsViewController.onCloseButton)) //Left close button
        
        closeButton.setTitleTextAttributes([NSForegroundColorAttributeName: StandardColors.primaryColor, NSFontAttributeName: StandardFonts.regularFont(size: 18)], for: UIControlState()) //Close button view properties
        
        navigationItem.leftBarButtonItem = closeButton
    }
    
    /**
     Setup properties for the static cells in settings
     */
    private func setupCells() {
        //Health cell config
        healthKitCell.cellImageView.image = UIImage(named: "HealthKitCellImage")
        updateHealthKitCell()
        
        //Goal cell config
        goalCell.cellImageView.image = UIImage(named: "GoalCellImage")
        goalCell.cellTextLabel.text = "Goal"
        
        let goal = UserDefaults.standard.float(forKey: "GoalValue")
        goalCell.presetValueChangerView.presetValueTextField.text = String(Int(goal))
        goalCell.delegate = self
        
        var imagePrefix = "Light" //Prefix to append to preset images depending if the theme is dark or light
        
        if AppDelegate.isDarkModeEnabled() {
            imagePrefix = "Dark"
        }
        
        //Preset cells config
        let presetWaterValues = UserDefaults.standard.array(forKey: "PresetWaterValues") as! [Float]
        
        //Small preset
        presetCell1.cellImageView.image = UIImage(named: imagePrefix + "SmallPresetImage")
        presetCell1.cellTextLabel.text = "Small Preset"
        presetCell1.presetValueChangerView.presetValueTextField.text = String(Int(presetWaterValues[0]))
        presetCell1.delegate = self

        //Medium preset
        presetCell2.cellImageView.image = UIImage(named: imagePrefix + "MediumPresetImage")
        presetCell2.cellTextLabel.text = "Medium Preset"
        presetCell2.presetValueChangerView.presetValueTextField.text = String(Int(presetWaterValues[1]))
        presetCell2.delegate = self

        //Large preset
        presetCell3.cellImageView.image = UIImage(named: imagePrefix + "LargePresetImage")
        presetCell3.cellTextLabel.text = "Large Preset"
        presetCell3.presetValueChangerView.presetValueTextField.text = String(Int(presetWaterValues[2]))
        presetCell3.delegate = self
        
        //Dark Mode cell config
        themeCell.cellImageView.image = UIImage(named: "DarkModeCellImage")
        themeCell.cellTextLabel.text = "Dark Mode"
        themeSwitch.onTintColor = StandardColors.waterColor
        
        //Automatic theme cell config
        automaticThemeCell.cellImageView.image = UIImage(named: "AutomaticThemeChangeCellImage")
        automaticThemeCell.cellTextLabel.text = "Automatically Switch Theme"
        automaticThemeSwitch.onTintColor = StandardColors.waterColor
    }
    
    /**
     Sets up the toggles in settings
     */
    private func setupToggles() {
        if AppDelegate.isDarkModeEnabled() { //Configure theme switch depeding on current color
            themeSwitch.setOn(true, animated: false)
        } else {
            themeSwitch.setOn(false, animated: false)
        }
        
        let automaticThemeChangeEnabled = UserDefaults.standard.bool(forKey: "AutomaticThemeChange")
        
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
            UserDefaults.standard.set(true, forKey: "HealthKitPermissionsWereShown") //Health permission were shown once (the limit to the amount of times they can be shown according to apple)

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
        let wereHealthKitPermissionsShown = UserDefaults.standard.bool(forKey: "HealthKitPermissionsWereShown") //If permissions were shown
        
        if wereHealthKitPermissionsShown {
            healthKitCell.isUserInteractionEnabled = false //Disable cell interaction
            healthKitCell.cellTextLabel.text = "Manage HealthKit in the Health app" //Change text because "Enable Healthkit" is not appropriate anymore
            healthKitCell.cellTextLabel.alpha = 0.5 //Fade out text to make it look not enabled
            healthKitCell.fillCellWithTextLabel() //Fills the text label autolayout to fill entire cell since there are no other elements around
        } else { //If healthkit permissions have not been shown
            healthKitCell.cellTextLabel.text = "Enable HealthKit" //Allow user to enable healthkit through permissions
        }
    }
    
    //MARK: - Theme Actions
    
    /**
     Action when the theme switch is toggled
     
     - parameter sender: Theme switch
     */
    @IBAction func onThemeSwitch( sender: UISwitch) {
        AudioToolbox.standardAudioToolbox.playAudio("Click", fileExtension: "wav", repeatEnabled: false)

        AppDelegate.toggleDarkMode(sender.isOn) //Change theme based on switch state
        
        view.endEditing(true) //Dismisses keyboard... Too bad this doesnt work very well
        NotificationCenter.default.post(name: NotificationConstants.DarkModeToggledNotification, object: nil)
    }
    
    /**
     Action when the automatic theme switch is toggled
     
     - parameter sender: Automatic theme changer switch
     */
    @IBAction func onAutomaticThemeSwitch( sender: UISwitch) {
        AudioToolbox.standardAudioToolbox.playAudio("Click", fileExtension: "wav", repeatEnabled: false)
        UserDefaults.standard.set(sender.isOn, forKey: "AutomaticThemeChange")
        
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
        /**
         Sets the array in NSUserDefaults when modifiying one of the values
         
         - parameter array: Array to place in the PresetWaterValues spot in NSUserDefaults
         */
        func setArrayPreset( array :[Float]) {
            UserDefaults.standard.set(array, forKey: "PresetWaterValues")
        }
        
        var presetWaterValues = UserDefaults.standard.array(forKey: "PresetWaterValues") as! [Float] //Existing preset water values

        switch settingsPresetTableViewCell {
        case goalCell:
            UserDefaults.standard.set(newValue, forKey: "GoalValue")
            delegate?.goalUpdated(newValue: newValue) //Update goal in main view
        case presetCell1:
            presetWaterValues[0] = newValue
            setArrayPreset(array: presetWaterValues) //Update NSUserDefaults
            delegate?.presetUpdated(presetSize: .small, newValue: newValue) //Update preset in main view
        case presetCell2:
            presetWaterValues[1] = newValue
            setArrayPreset(array: presetWaterValues) //Update NSUserDefaults
            delegate?.presetUpdated(presetSize: .medium, newValue: newValue) //Update preset in main view
        case presetCell3:
            presetWaterValues[2] = newValue
            setArrayPreset(array: presetWaterValues) //Update NSUserDefaults
            delegate?.presetUpdated(presetSize: .large, newValue: newValue) //Update preset in mainview
            return
        default:
            break
        }
        
        AppDelegate.createShortcuts() //Updates 3D touch shortcuts based on new presets
    }
}
