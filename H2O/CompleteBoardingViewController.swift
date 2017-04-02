//
//  CompleteBoardingViewController.swift
//  H2O
//
//  Created by Gregory Sapienza on 12/11/16.
//  Copyright © 2016 City Pixels. All rights reserved.
//

import UIKit

class CompleteBoardingViewController: UIViewController, BoardingProtocol {
    //MARK: - Strings
    
    /// String for title label.
    private static let titleString = "all_done".localized
    
    //MARK: - Public iVars
    
    /// First label.
    var titleLabel: GSMagicTextLabel {
        get {
            return _titleLabel
        }
    }
    
    //MARK: - Private iVars

    /// Backing label to title label so we can use lazy loading. Lazy loading a var declared in a protocol leads to a Seg Fault 11. Bug filed here: https://bugs.swift.org/browse/SR-1825
    private lazy var _titleLabel: GSMagicTextLabel = self.generateTitleLabel(text: titleString)
    
    /// View displaying water bottle animation.
    private var waterBottleView: WaterBottleView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var navigationItem = self.navigationItem
        configureNavigationItem(navigationItem: &navigationItem, title: "", rightBarButtonItemTitle: "")
        waterBottleView = generateWaterBottleView()
        
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
                    let mainViewController: MainViewController = UIStoryboard(storyboard: .Main).instantiateViewController()
                    self.navigationController?.pushViewController(mainViewController, animated: true)
                })
            })
        })
    }
    
    func animateOut(completion: @escaping (Bool) -> Void) {
        UIView.animate(withDuration: 0.5, animations: {
            self.titleLabel.alpha = 0
        }, completion: { _ in
            AppDelegate.createShortcuts() //Creates 3D touch shortcuts
            AppUserDefaults.setBoardingWasDismissed(dismissed: true)
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
