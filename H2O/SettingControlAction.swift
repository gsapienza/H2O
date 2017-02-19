//
//  SettingControlAction.swift
//  H2O
//
//  Created by Gregory Sapienza on 2/18/17.
//  Copyright © 2017 Skyscrapers.IO. All rights reserved.
//

import UIKit


extension Setting {
    
    func getControl() -> UIControl? {
        let type = controlType
        
        switch type {
        case .toggleSwitch:
            let control = UISwitch()
            control.addTarget(self, action: #selector(Setting.controlAction), for: .valueChanged)
            return control
        case .presetValueChanger:
            let control = PresetValueChangerView()
            control.addTarget(self, action: #selector(Setting.controlAction), for: .editingDidEnd)
            return control
        default:
            break
        }
        
        return nil
    }
    
    @objc func controlAction(_ sender: AnyObject) {
        
        switch controlType {
        case let .toggleSwitch(onAction, offAction):
            switchAction(sender, onAction: onAction, offAction: offAction)
        case let .presetValueChanger(_, doneAction):
            presetValueChangerAction(sender, doneAction: doneAction)
        default:
            break
        }
    }
    
    func switchAction(_ sender: AnyObject, onAction: () -> Void, offAction: () -> Void) {
        guard let toggleSwitch = sender as? UISwitch else {
            return
        }
        
        if toggleSwitch.isOn {
            onAction()
        } else {
            offAction()
        }
    }
    
    func presetValueChangerAction(_ sender: AnyObject, doneAction:(_ value: Float) -> Void) {
        guard let presetValueChanger = sender as? PresetValueChangerView else {
            return
        }
        
        doneAction(presetValueChanger.currentValue)
    }
}
