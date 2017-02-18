//
//  SettingControlProtocol.swift
//  H2O
//
//  Created by Gregory Sapienza on 2/14/17.
//  Copyright © 2017 Skyscrapers.IO. All rights reserved.
//

import Foundation

protocol SettingControlProtocol {
    var bounds: CGRect { get set }
    func addAction(target: Any, selector: Selector)
}

extension UISwitch: SettingControlProtocol {
    func addAction(target: Any, selector: Selector) {
        addTarget(target, action: selector, for: .valueChanged)
    }
}
