//
//  Setting.swift
//  H2O
//
//  Created by Gregory Sapienza on 2/12/17.
//  Copyright © 2017 Skyscrapers.IO. All rights reserved.
//

import Foundation

protocol SettingProtocol {
    func setControlAction()
}

class Setting: SettingProtocol {
    
    var id: String?
    
    /// Image name for image representing setting.
    var imageName: String
    
    /// Title of setting.
    var title: String
    
    var primaryAction: () -> ()
    
    /// Control of setting.
    var controlAction: () -> () {
        didSet {
            setControlAction()
        }
    }
    
    var control: SettingActionProtocol?
    
    init(id: String? = nil, imageName: String, title: String, control: SettingActionProtocol? = nil, primaryAction: @escaping () -> () = {}, controlAction: @escaping () -> () = {}) {
        self.id = id
        self.imageName = imageName
        self.title = title
        self.primaryAction = primaryAction
        self.control = control
        self.controlAction = controlAction
    }
    
    func setValue(value: Any) {
        guard let control = control else {
            return
        }
        
        control.setValue(value: value)
    }
}
