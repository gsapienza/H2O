//
//  ConnectViewController.swift
//  H2O
//
//  Created by Gregory Sapienza on 11/17/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

class ConnectViewController: UIViewController, BoardingProtocol {
    var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        var navigationItem = self.navigationItem
        configureNavigationItem(navigationItem: &navigationItem, title: "", rightBarButtonItemTitle: "Done")
        
        titleLabel = generateTitleLabel()
        titleLabel.text = "Connect"
        
        layout()
    }
    
    private func layout() {
        //---Title Label---
        view.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 80))
        view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
    }
    
    func animateIn(completion: @escaping (Bool) -> Void) {
        delay(delay: 0.5, closure: {
            completion(true)
        })
    }
    
    func animateOut(completion: @escaping (Bool) -> Void) {
        
    }
    
    func onRightBarButton() {
        
    }
}
