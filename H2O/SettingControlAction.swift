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
        
        guard let control = control as? SettingActionProtocol else {
            return
        }
        
        control.addTarget(target: self, action: #selector(Setting.controlAction))
    }
    
    @objc func controlAction(_ sender: AnyObject) {
        action()
    }
}

protocol SettingActionProtocol {
    var controlEvents: UIControlEvents { get }
    
    func addTarget(target: Any?, action: Selector)
}

extension UIControl: SettingActionProtocol {
    var controlEvents: UIControlEvents {
        get {
            return []
        }
    }
    
    func addTarget(target: Any?, action: Selector) {
        addTarget(target, action: action, for: controlEvents)
    }
}

extension UISwitch {
    override var controlEvents: UIControlEvents {
        get {
            return .valueChanged
        }
    }
}

extension PresetValueChangerView {
    override var controlEvents: UIControlEvents {
        get {
            return .editingDidEnd
        }
    }
}
