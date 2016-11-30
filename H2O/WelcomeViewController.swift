//
//  WelcomeViewController.swift
//  H2O
//
//  Created by Gregory Sapienza on 11/17/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    //MARK: - Private iVars
    
    /// First label.
    private var welcomeLabel :GSMagicLabel!
    
    /// Second label.
    private var h2OLabel :UILabel!
    
    /// View displaying water bottle animation.
    private var waterBottleView :WaterBottleView!
    
    //MARK: - Public
    
    override func viewDidLoad() {
        super.viewDidLoad()

        welcomeLabel = generateWelcomeLabel()
        h2OLabel = generateH2OLabel()
        waterBottleView = generateWaterBottleView()
        
        welcomeLabel.text = "Welcyome To"
        
        h2OLabel.text = "H2O"
        
        layout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        welcomeLabel.animate(to: "Set your daily")
    }
    
    //MARK: - Private
    
    private func layout() {
        //---Welcome Label---
        view.addSubview(welcomeLabel)
        
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: welcomeLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 80))
        view.addConstraint(NSLayoutConstraint(item: welcomeLabel, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: welcomeLabel, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        
        //---H2O Label---
        view.addSubview(h2OLabel)
        
        h2OLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: h2OLabel, attribute: .top, relatedBy: .equal, toItem: welcomeLabel, attribute: .bottom, multiplier: 1, constant: 10))
        view.addConstraint(NSLayoutConstraint(item: h2OLabel, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: h2OLabel, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))

        //---Water Bottle View---
        view.addSubview(waterBottleView)
        
        waterBottleView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: waterBottleView, attribute: .top, relatedBy: .equal, toItem: h2OLabel, attribute: .bottom, multiplier: 1, constant: 100))
        view.addConstraint(NSLayoutConstraint(item: waterBottleView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -100))
        view.addConstraint(NSLayoutConstraint(item: waterBottleView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: waterBottleView, attribute: .width, relatedBy: .equal, toItem: waterBottleView, attribute: .height, multiplier: 119/326, constant: 0))
    }
}


// MARK: - Private Generators
private extension WelcomeViewController {
    
    /// Generates a welcome label.
    ///
    /// - Returns: A magic label to use for welcome title.
    func generateWelcomeLabel() -> GSMagicLabel {
        let label = GSMagicLabel()
        
        label.font = StandardFonts.ultraLightFont(size: 54)
        label.textAlignment = .center
        label.textColor = StandardColors.primaryColor
        
        return label
    }
    
    
    /// Generates an H2O label.
    ///
    /// - Returns: A label to use for H2O title.
    func generateH2OLabel() -> UILabel {
        let label = UILabel()
        
        label.font = StandardFonts.regularFont(size: 54)
        label.textAlignment = .center
        label.textColor = StandardColors.primaryColor
        
        return label
    }
    
    /// Generates an animated water bottle view.
    ///
    /// - Returns: View representing a water bottle.
    func generateWaterBottleView() -> WaterBottleView {
        let view = WaterBottleView()
        
        return view
    }
}

