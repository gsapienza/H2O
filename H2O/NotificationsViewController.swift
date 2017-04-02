//
//  NotificationsViewController.swift
//  H2O
//
//  Created by Gregory Sapienza on 3/4/17.
//  Copyright © 2017 Midnite. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController, BoardingProtocol {
    // MARK: - Strings

    /// String for right bar button item.
    private let rightBarButtonString = "next_navigation_item".localized
    
    private let titleString = "notifications".localized
    
    // MARK: - Public iVars
    
    /// First label.
    var titleLabel: GSMagicTextLabel {
        get {
            return _titleLabel
        }
    }
    
    // MARK: - Private iVars
    
    /// Backing label to title label so we can use lazy loading. Lazy loading a var declared in a protocol leads to a Seg Fault 11. Bug filed here: https://bugs.swift.org/browse/SR-1825
    private lazy var _titleLabel: GSMagicTextLabel = self.generateTitleLabel(text: self.titleString)

    // MARK: - Public

    override func viewDidLoad() {
        super.viewDidLoad()

        //---Navigation Item---//
        
        var navigationItem = self.navigationItem
        configureNavigationItem(navigationItem: &navigationItem, title: "", rightBarButtonItemTitle: rightBarButtonString)
        
        //---Title Label---//
                
        view.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 80))
        view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50))

    }
    
    func onRightBarButton() {
        let completeViewController = CompleteBoardingViewController()
        navigationController?.pushViewController(completeViewController, animated: true)
    }

    func animateIn(completion: @escaping (Bool) -> Void) {
        delay(delay: 0.5, closure: {
            completion(true)
        })
    }
    
    func animateOut(completion: @escaping (Bool) -> Void) {
        
    }
}
