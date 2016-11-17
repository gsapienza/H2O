//
//  BoardingViewController.swift
//  H2O
//
//  Created by Gregory Sapienza on 11/17/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

class BoardingViewController: UIViewController {
    
    /// Background image.
    var backgroundImageView :UIImageView!
    
    /// View controller displaying first boarding screen.
    var welcomeViewController :WelcomeViewController!
    
    //MARK: - Public

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImageView = generateBackgroundImageView()
        welcomeViewController = generateWelcomeViewController()
        
        layout()
    }
    
    //MARK: - Private
    
    private func layout() {
        //---Welcome View Controller---
        
        view.addSubview(backgroundImageView)
        
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: backgroundImageView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: backgroundImageView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: backgroundImageView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: backgroundImageView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))
        
        //---Welcome View Controller---
        
        addChildViewController(welcomeViewController)
        view.addSubview(welcomeViewController.view)
        
        welcomeViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: welcomeViewController.view, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: welcomeViewController.view, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: welcomeViewController.view, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: welcomeViewController.view, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))
    }
}

// MARK: - Private Generators
private extension BoardingViewController {
    
    /// Generates image view for the view controllers background image.
    ///
    /// - Returns: Background image for view controller.
    func generateBackgroundImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(assetIdentifier: .darkModeBackground)
        
        return imageView
    }
    
    /// Generates welcome view controller.
    ///
    /// - Returns: Welcome view controller.
    func generateWelcomeViewController() -> WelcomeViewController {
        let viewController = WelcomeViewController()
        viewController.view.backgroundColor = UIColor.clear
        return viewController
    }
}
