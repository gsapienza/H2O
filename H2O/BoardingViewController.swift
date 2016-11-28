//
//  BoardingViewController.swift
//  H2O
//
//  Created by Gregory Sapienza on 11/17/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

class BoardingViewController: UINavigationController {
    
    //MARK: - Private iVars
    
    /// Background image.
    private var backgroundImageView :UIImageView!
    
    //MARK: - Public

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        
        view.backgroundColor = UIColor(patternImage: UIImage(assetIdentifier: .darkModeBackground))
        setViewControllers([generateWelcomeViewController()], animated: false)        
    }
    
    //MARK: - Private
}

// MARK: - Private View Configurations
private extension BoardingViewController {
    /// Configures the view controllers navigation bar.
    func configureNavigationBar() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        navigationBar.backgroundColor = UIColor.clear
    }
}

// MARK: - Private Generators
private extension BoardingViewController {
    
    /// Generates welcome view controller.
    ///
    /// - Returns: Welcome view controller.
    func generateWelcomeViewController() -> WelcomeViewController {
        let viewController = WelcomeViewController()
        viewController.view.backgroundColor = UIColor.clear
        return viewController
    }
}
