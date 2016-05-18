//
//  ViewController.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/16/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

protocol EntryButtonProtocol {
    func entryButtonTapped(amount :Float)
}

class MainViewController: UIViewController {

        /// Navigation bar to contain settings button
    @IBOutlet weak var _navigationBar: UINavigationBar!
    @IBOutlet weak var _entryButton1: EntryButton!
    @IBOutlet weak var _entryButton2: EntryButton!
    @IBOutlet weak var _entryButton3: EntryButton!
    @IBOutlet weak var _customEntryButton: CustomEntryButton!
    
    @IBOutlet weak var _dailyEntryDial: DailyEntryDial!
    /**
     Sets status bar style for all view controllers
     
     - returns: White status bar style
     */
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    //MARK: - Setup functions
    
    /**
     Basic setup helper functions
     */
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = StandardColors.backgroundColor
        
        setupNavigationBar()
        setupPresetEntryCircles()
    }

    /**
     Sets up navigation bar state by making it fully transparent
     */
    private func setupNavigationBar() {
        _navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        _navigationBar.shadowImage = UIImage()
        _navigationBar.translucent = true
        _navigationBar.backgroundColor = UIColor.clearColor()
    }

    /**
     Sets up 3 preset circles
     */
    private func setupPresetEntryCircles() {
        let presetWaterValues = NSUserDefaults.standardUserDefaults().arrayForKey("PresetWaterValues") as! [Float]
        
        _entryButton1._amount = presetWaterValues[0]
        _entryButton2._amount = presetWaterValues[1]
        _entryButton3._amount = presetWaterValues[2]
    }
    
    //MARK: - Actions
    
    /**
     Adds water to today by using presets, custom amount or other means
     
     - parameter amount: Amount of water in fl oz
     */
    private func addWaterToToday(amount :Float) {
        
    }
    
    @IBAction func onSettingsBarButton(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationViewController = (storyboard.instantiateViewControllerWithIdentifier("SettingsViewController") as! UINavigationController)
        
        let settingsViewController = navigationViewController.viewControllers.first as! SettingsViewController
        settingsViewController._delegate = self
        
        self.presentViewController(navigationViewController, animated: true, completion: nil)
    }
}

// MARK: - EntryButtonDelegate
extension MainViewController :EntryButtonProtocol {
    
    /**
     When an entry button is tapped and a new amount of water is added to today
     
     - parameter amount: Amount to add in fl oz
     */
    func entryButtonTapped(amount: Float) {
        addWaterToToday(amount)
    }
}

// MARK: - SettingsViewControllerProtocol
extension MainViewController :SettingsViewControllerProtocol {
    /**
     Called when the goal value has been updated
     
     - parameter newValue: New goal set
     */
    func goalUpdated(newValue: Float) {
        _dailyEntryDial._goal = newValue
    }
    
    /**
     When one of the presets values has been updated
     
     - parameter presetSize: Size of preset to update
     - parameter newValue:     New Value for preset
     */
    func presetUpdated(presetSize: PresetSize, newValue: Float) {
        switch presetSize {
        case .Small:
            _entryButton1._amount = newValue
        case .Medium:
            _entryButton2._amount = newValue
        case .Large:
            _entryButton3._amount = newValue
        }
    }
}

