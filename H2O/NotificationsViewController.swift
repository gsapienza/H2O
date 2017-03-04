//
//  NotificationsViewController.swift
//  H2O
//
//  Created by Gregory Sapienza on 3/4/17.
//  Copyright © 2017 Midnite. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController, BoardingProtocol {
    /// Backing label to title label so we can use lazy loading. Lazy loading a var declared in a protocol leads to a Seg Fault 11. Bug filed here: https://bugs.swift.org/browse/SR-1825
    private lazy var _titleLabel :GSMagicTextLabel = self.generateTitleLabel()
    
    /// First label.
    var titleLabel :GSMagicTextLabel {
        get {
            return _titleLabel
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func onRightBarButton() {
        
    }

    func animateIn(completion: @escaping (Bool) -> Void) {
        
    }
    
    func animateOut(completion: @escaping (Bool) -> Void) {
        
    }
}
