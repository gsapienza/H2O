//
//  WelcomeViewController.swift
//  H2O
//
//  Created by Gregory Sapienza on 11/17/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController, BoardingProtocol {

    //MARK: - Private iVars
    
    /// First label.
    var titleLabel :UILabel!
    
    /// Second label.
    private var h2OLabel :UILabel!
    
    /// View displaying water bottle animation.
    private var waterBottleView :WaterBottleView!
    
    //MARK: - Public
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var navigationItem = self.navigationItem
        configureNavigationItem(navigationItem: &navigationItem, title: "", rightBarButtonItemTitle: "Next")
        titleLabel = generateTitleLabel()
        h2OLabel = generateH2OLabel()
        waterBottleView = generateWaterBottleView()
        
        titleLabel.text = "Welcome To"
        h2OLabel.text = "H2O"
        
        layout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.delegate = self
    }
    
    //MARK: - Private
    
    private func layout() {
        //---Title Label---
        view.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 80))
        view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        
        //---H2O Label---
        view.addSubview(h2OLabel)
        
        h2OLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: h2OLabel, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1, constant: 10))
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
    
    func animateOut(completion: @escaping (Bool) -> Void) {
        UIView.animate(withDuration: 0.5, animations: {
            self.h2OLabel.alpha = 0
            self.waterBottleView.bounds = self.waterBottleView.bounds.offsetBy(dx: 0, dy: -700)
            self.waterBottleView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }) { (Bool) in
            completion(true)
        }
    }
    
    func animateIn(completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    
    /// Action for next bar button.
    func onRightBarButton() {
        let dailyGoalViewController = DailyGoalViewController()
        navigationController?.pushViewController(dailyGoalViewController, animated: true)
    }
}

// MARK: - UINavigationControllerDelegate
extension WelcomeViewController :UINavigationControllerDelegate {
    /**
     Animates the navigation controller to zoom into cell that was tapped and transition to the next view controller with the transition animation. Cell tapped is determined in the collection view didSelect delegate method
     
     - returns: Transition animation to move to device view controller
     */
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return BoardingAnimatingTransitioning()
    }
}

// MARK: - Private Generators
private extension WelcomeViewController {
    
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
