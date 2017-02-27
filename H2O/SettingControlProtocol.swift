//
//  SettingControlAction.swift
//  H2O
//
//  Created by Gregory Sapienza on 2/18/17.
//  Copyright © 2017 Skyscrapers.IO. All rights reserved.
//

import UIKit

/// Protocol for controls in setting to conform to. Allows a setting object to set up target action and to set controls to a specified state.
protocol SettingControlProtocol {
    
    /// Configures target action for a setting control.
    ///
    /// - Parameters:
    ///   - target: Object that will contain the specified selector.
    ///   - action: Selector action when control is triggered.
    func addTarget(target: Any?, action: Selector)
    
    func setValue(value: Any)
}

// MARK: - SettingControlProtocol
extension UISwitch: SettingControlProtocol {
    func setValue(value: Any) {
        guard let value = value as? Bool else {
            print("Value must be a bool type")
            return
        }
        
        setOn(value, animated: true)
    }
    
    func addTarget(target: Any?, action: Selector) {
        addTarget(target, action: action, for: .valueChanged)
    }
}

// MARK: - SettingControlProtocol
extension PresetValueChangerView: SettingControlProtocol {
    func setValue(value: Any) {
        guard let value = value as? Float else {
            print("Value must be a float type")
            return
        }
        
        currentValue = value
    }
    
    func addTarget(target: Any?, action: Selector) {
        addTarget(target, action: action, for: .editingDidEnd)
    }
}
