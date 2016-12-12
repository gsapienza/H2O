//
//  CompleteBoardingViewController.swift
//  H2O
//
//  Created by Gregory Sapienza on 12/11/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

class CompleteBoardingViewController: UIViewController, BoardingProtocol {
    var titleLabel: UILabel!

    /// View displaying water bottle animation.
    private var waterBottleView :WaterBottleView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var navigationItem = self.navigationItem
        configureNavigationItem(navigationItem: &navigationItem, title: "", rightBarButtonItemTitle: "")
        waterBottleView = generateWaterBottleView()
        
        titleLabel = generateTitleLabel()
        titleLabel.text = "All Done"
        
        layout()
    }
    
    private func layout() {
        //---Title Label---
        view.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 80))
        view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        
        //---Water Bottle View---
        view.addSubview(waterBottleView)
        
        waterBottleView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: waterBottleView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: waterBottleView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: waterBottleView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.3, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: waterBottleView, attribute: .width, relatedBy: .equal, toItem: waterBottleView, attribute: .height, multiplier: 119/326, constant: 0))
    }
    
    func animateIn(completion: @escaping (Bool) -> Void) {
        waterBottleView.bounds = waterBottleView.bounds.offsetBy(dx: 0, dy: -view.bounds.height)

        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.1, options: .allowUserInteraction, animations: {
            self.waterBottleView.bounds = self.waterBottleView.bounds.offsetBy(dx: 0, dy: self.view.bounds.height)
        }, completion: { complete in
            GSAnimations.rotationShake(layer: self.waterBottleView.layer, completion: { complete in
                completion(true)
                UIView.animate(withDuration: 0.5, animations: {
                    self.waterBottleView.transform = CGAffineTransform(scaleX: 7, y: 7)
                    self.waterBottleView.alpha = 0
                }, completion: { complete in
                    let mainViewController :MainViewController = UIStoryboard(storyboard: .Main).instantiateViewController()
                    self.navigationController?.pushViewController(mainViewController, animated: true)
                })
            })
        })
    }
    
    func animateOut(completion: @escaping (Bool) -> Void) {
        UIView.animate(withDuration: 0.5, animations: {
            self.titleLabel.alpha = 0
        }, completion: { _ in
            completion(true)
        })
    }
}

// MARK: - Private Generators
private extension CompleteBoardingViewController {
    
    /// Generates an animated water bottle view.
    ///
    /// - Returns: View representing a water bottle.
    func generateWaterBottleView() -> WaterBottleView {
        let view = WaterBottleView()
        
        return view
    }
}
