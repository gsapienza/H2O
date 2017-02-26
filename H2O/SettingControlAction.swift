//
//  SettingControlAction.swift
//  H2O
//
//  Created by Gregory Sapienza on 2/18/17.
//  Copyright © 2017 Skyscrapers.IO. All rights reserved.
//

import UIKit


extension Setting {
    
    func setControlAction() {
        control?.addTarget(target: self, action: #selector(Setting.controlTargetAction))
    }
    
    @objc func controlTargetAction(_ sender: AnyObject) {
        controlAction()
    }
}

protocol SettingActionProtocol {
    
    func addTarget(target: Any?, action: Selector)
    
    func setValue(value: Any)
}

extension UISwitch: SettingActionProtocol {
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

extension PresetValueChangerView: SettingActionProtocol {
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
