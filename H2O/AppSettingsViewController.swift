//
//  AppSettingsViewController.swift
//  H2O
//
//  Created by Gregory Sapienza on 2/11/17.
//  Copyright © 2017 Skyscrapers.IO. All rights reserved.
//

import UIKit

class AppSettingsViewController: UIViewController {
    // MARK: - Strings
    
    /// Title for navigation item.
    private static let navigationTitle = "settings_navigation_title".localized
    
    /// Title for close button in navigation bar.
    private static let closeBarButtonTitle = "close_navigation_item".localized

    // MARK: - Public iVars
    
    /// Table View displaying setting cells.
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(AppSettingsTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
            tableView.backgroundColor = .clear
            tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: -1, width: 0, height: 1)) //Covers the bottom lines in the table view including the last cells line
            tableView.separatorColor = StandardColors.primaryColor.withAlphaComponent(0.2)
            tableView.backgroundColor = .clear
        }
    }
    
    // MARK: - Private iVars
    
    /// Cell reuse identifier.
    fileprivate let reuseIdentifier = "\(AppSettingsTableViewCell.self)"
    
    /// Settings backing table view. Each outer array contains a section of an inner array of settings.
    fileprivate var settings: [[Setting]]?
    
    // MARK: - Public

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //---View---//
        
        view.backgroundColor = StandardColors.backgroundColor
        
        //---Navigation Item---//
        
        navigationItem.title = AppSettingsViewController.navigationTitle
        
        let closeButton = UIBarButtonItem(title: AppSettingsViewController.closeBarButtonTitle, style: .plain, target: self, action: #selector(onCloseButton)) //Left close button
        
        closeButton.setTitleTextAttributes([NSForegroundColorAttributeName: StandardColors.primaryColor, NSFontAttributeName: StandardFonts.regularFont(size: 18)], for: UIControlState()) //Close button view properties
        
        navigationItem.leftBarButtonItem = closeButton
    }
    
    // MARK: - Private
    
    private func customInit() {
        configureSettings()
    }
    
    /// Sets up settings to use in view controller.
    private func configureSettings() {
        
        var firstSectionSettings: [Setting] = []
        
        for service in SupportedServices.allSupportedServices() {
            let service = Setting(id: service.rawValue, imageName: "healthKitCellImage", title: "Enable \(service.rawValue)", primaryAction: { 
                service.model().authorize(completion: { (success: Bool, error: Error?, message: String?) in
                    print(message)
                })
            })
            
            firstSectionSettings.append(service)
        }
        
        var secondSectionSettings: [Setting] = []
        
        guard let goalValue = AppUserDefaults.getDailyGoalValue() else {
            return
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
            return
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
    }
    
    //MARK: - Actions
    
    /// Action for close bar button. Dismisses setting view/
    func onCloseButton() {
        dismiss(animated: true) {
        }
    }
}

// MARK: - UITableViewDataSource
extension AppSettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let settings = settings else {
            print("Settings were not set.")
            
            return 0
        }
        
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let settings = settings else {
            print("Settings were not set.")
            
            return 0
        }
        
        return settings[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let settings = settings else {
            fatalError("Settings were not set.")
        }
        
        let setting = settings[indexPath.section][indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? AppSettingsTableViewCell else {
            fatalError("Cell is incorrect type.")
        }
    
        cell.setting = setting
        cell.titleLabel.textColor = StandardColors.primaryColor

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let settings = settings else {
            fatalError("Settings were not set.")
        }
        
        let setting = settings[indexPath.section][indexPath.row]
        
        setting.primaryAction()
    }
}

// MARK: - UITableViewDelegate
extension AppSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        
        view.backgroundColor = .clear
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
