//
//  ViewController.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/16/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

protocol EntryButtonDelegate {
    func entryButtonTapped(amount :Float)
}

class MainViewController: UIViewController {

        /// Navigation bar to contain settings button
    @IBOutlet weak var _navigationBar: UINavigationBar!
    
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
        setupCustomEntryCircle()
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
        
    }
    
    /**
     Sets up the custom entry dialog for custom water amounts
     */
    private func setupCustomEntryCircle() {
        
    }
    
    //MARK: - Actions
    
    /**
     Adds water to today by using presets, custom amount or other means
     
     - parameter amount: Amount of water in fl oz
     */
    private func addWaterToToday(amount :Float) {
        
    }
}

// MARK: - EntryButtonDelegate
extension MainViewController :EntryButtonDelegate {
    
    /**
     When an entry button is tapped and a new amount of water is added to today
     
     - parameter amount: Amount to add in fl oz
     */
    func entryButtonTapped(amount: Float) {
        addWaterToToday(amount)
    }
}

