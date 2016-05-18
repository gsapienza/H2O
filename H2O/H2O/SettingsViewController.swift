//
//  SettingsViewController.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/17/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

enum PresetSize {
    case Small
    case Medium
    case Large
}

protocol SettingsViewControllerProtocol {
    /**
     Called when the goal has been updated in the settings
     
     - parameter newValue: New goal value
     */
    func goalUpdated(newValue :Float)
    
    /**
     Called when one of the presets has been updated in the settings
     
     - parameter presetSize: Preset size to update
     - parameter newValue:     New preset value
     */
    func presetUpdated(presetSize :PresetSize, newValue :Float)
}

class SettingsViewController: UITableViewController {
        /// HealthKit static cell
    @IBOutlet weak var _healthKitCell: SettingsTableViewCell!
    
        /// Goal static cell
    @IBOutlet weak var _goalCell: SettingsPresetTableViewCell!
    
        /// Small preset static cell
    @IBOutlet weak var _presetCell1: SettingsPresetTableViewCell!
    
        /// Medium preset static cell
    @IBOutlet weak var _presetCell2: SettingsPresetTableViewCell!
    
        /// Large preset static cell
    @IBOutlet weak var _presetCell3: SettingsPresetTableViewCell!
    
        /// HealthKit toggle Control
    @IBOutlet weak var _healthKitSwitch: UISwitch!
    
    var _delegate :SettingsViewControllerProtocol?
    
    //MARK: - View Setup
    
    /**
     Basic setup helper functions
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = StandardColors.backgroundColor
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        setupNavigationBar()
        setupCells()
    }
    
    /**
     Sets up view properties for the navigation bar
     */
    private func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = StandardColors.standardSecondaryColor
        navigationController?.navigationBar.translucent = false
        navigationItem.title = "Settings"
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: StandardFonts.regularFont(20)] //Navigation bar view properties
        
        let closeButton = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: #selector(SettingsViewController.onCloseButton))
        
        closeButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: StandardFonts.regularFont(18)], forState: .Normal) //Close button view properties
        
        navigationItem.leftBarButtonItem = closeButton
    }
    
    /**
     Setup properties for the static cells in settings
     */
    private func setupCells() {
        //Health cell config
        _healthKitCell._imageView.image = UIImage(named: "HealthKitCellImage")
        _healthKitCell._textLabel.text = "HealthKit"
        _healthKitSwitch.onTintColor = StandardColors.waterColor
        
        //Goal cell config
        _goalCell._imageView.image = UIImage(named: "GoalCellImage")
        _goalCell._textLabel.text = "Goal"
        
        let goal = NSUserDefaults.standardUserDefaults().floatForKey("GoalValue")
        _goalCell._presetValueChangerView._presetValueTextField.text = String(Int(goal))
        _goalCell._delegate = self
        
        //Preset cells config
        let presetWaterValues = NSUserDefaults.standardUserDefaults().arrayForKey("PresetWaterValues") as! [Float]
        _presetCell1._imageView.image = UIImage(named: "SmallPresetImage")
        _presetCell1._textLabel.text = "Small Preset"
        _presetCell1._presetValueChangerView._presetValueTextField.text = String(Int(presetWaterValues[0]))
        _presetCell1._delegate = self

        _presetCell2._imageView.image = UIImage(named: "MediumPresetImage")
        _presetCell2._textLabel.text = "Medium Preset"
        _presetCell2._presetValueChangerView._presetValueTextField.text = String(Int(presetWaterValues[1]))
        _presetCell2._delegate = self

        _presetCell3._imageView.image = UIImage(named: "LargePresetImage")
        _presetCell3._textLabel.text = "Large Preset"
        _presetCell3._presetValueChangerView._presetValueTextField.text = String(Int(presetWaterValues[2]))
        _presetCell3._delegate = self
    }
    
    //MARK: - Table View Overrides

    /**
     Makes the table view section headers transparent
     */
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clearColor()
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.whiteColor()
    }
    
    //MARK: - Actions

    /**
     Action for close bar button. Dismisses setting view
     */
    func onCloseButton() {
        dismissViewControllerAnimated(true) {
        }
    }
}

// MARK: - SettingsPresetTableViewCellProtocol
extension SettingsViewController :SettingsPresetTableViewCellProtocol {
    /**
     A preset value has been changed within a settings cell
     
     - parameter settingsPresetTableViewCell: Which cell made the change
     - parameter newValue:                    New value for the preset
     */
    func presetValueDidChange(settingsPresetTableViewCell: SettingsPresetTableViewCell, newValue :Float) {
        /**
         Sets the array in NSUserDefaults when modifiying one of the values
         
         - parameter array: Array to place in the PresetWaterValues spot in NSUserDefaults
         */
        func setArrayPreset(array :[Float]) {
            NSUserDefaults.standardUserDefaults().setObject(array, forKey: "PresetWaterValues")
        }
        
        var presetWaterValues = NSUserDefaults.standardUserDefaults().arrayForKey("PresetWaterValues") as! [Float] //Existing preset water values

        switch settingsPresetTableViewCell {
        case _goalCell:
            NSUserDefaults.standardUserDefaults().setFloat(newValue, forKey: "GoalValue")
            _delegate?.goalUpdated(newValue) //Update goal in main view
        case _presetCell1:
            presetWaterValues[0] = newValue
            setArrayPreset(presetWaterValues) //Update NSUserDefaults
            _delegate?.presetUpdated(.Small, newValue: newValue) //Update preset in main view
        case _presetCell2:
            presetWaterValues[1] = newValue
            setArrayPreset(presetWaterValues) //Update NSUserDefaults
            _delegate?.presetUpdated(.Medium, newValue: newValue) //Update preset in main view
        case _presetCell3:
            presetWaterValues[2] = newValue
            setArrayPreset(presetWaterValues) //Update NSUserDefaults
            _delegate?.presetUpdated(.Large, newValue: newValue) //Update preset in mainview
            return
        default:
            break
        }
    }
}
