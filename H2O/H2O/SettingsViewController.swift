//
//  SettingsViewController.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/17/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
        /// HealthKit static cell
    @IBOutlet weak var _healthKitCell: SettingsTableViewCell!
    
        /// Goal static cell
    @IBOutlet weak var _goalCell: SettingsTableViewCell!
    
        /// Small preset static cell
    @IBOutlet weak var _presetCell1: SettingsTableViewCell!
    
        /// Medium preset static cell
    @IBOutlet weak var _presetCell2: SettingsTableViewCell!
    
        /// Large preset static cell
    @IBOutlet weak var _presetCell3: SettingsTableViewCell!
    
        /// HealthKit toggle Control
    @IBOutlet weak var _healthKitSwitch: UISwitch!
    
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

        //Preset cells config
        _presetCell1._imageView.image = UIImage(named: "SmallPresetImage")
        _presetCell1._textLabel.text = "Small Preset"

        _presetCell2._imageView.image = UIImage(named: "MediumPresetImage")
        _presetCell2._textLabel.text = "Medium Preset"

        _presetCell3._imageView.image = UIImage(named: "LargePresetImage")
        _presetCell3._textLabel.text = "Large Preset"
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
