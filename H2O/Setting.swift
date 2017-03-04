//
//  Setting.swift
//  H2O
//
//  Created by Gregory Sapienza on 2/12/17.
//  Copyright © 2017 Skyscrapers.IO. All rights reserved.
//

import Foundation

class Setting: SettingsProtocol {
    
    /// Setting can have an Id. This allows for easy comparison to find a particular setting in a collection.
    var id: String?
    
    /// Image name for image representing setting.
    var imageName: String?
    
    /// Title of setting.
    var title: String?
    
    /// A primary action, a common use for this is to call this closure when a cell is tapped in a table view.
    var primaryAction: (Setting) -> ()
    
    /// Control of setting.
    var controlAction: ((Setting) -> ()) {
        didSet {
            setControlAction() //Configure target action when this is set.
        }
    }
    
    /// Control to use for setting.
    var control: SettingControlProtocol?
    
    init(id: String? = nil, imageName: String, title: String, control: SettingControlProtocol? = nil, primaryAction: @escaping (Setting) -> () = { _ in }, controlAction: @escaping (Setting) -> () = { _ in }) {
        self.id = id
        self.imageName = imageName
        self.title = title
        self.primaryAction = primaryAction
        self.control = control
        self.controlAction = controlAction
        
        setControlAction() //Configure target action when this is set.
    }
    
    /// Configures target action for the settings control. This allows us to use closures for the action instead of the typical target action pattern. Sets the target to self.
    private func setControlAction() {
        control?.addTarget(target: self, action: #selector(Setting.controlTargetAction))
    }
    
    /// The controls action. This is where the control action closure is called.
    ///
    /// - Parameter sender: Sender of action.
    @objc private func controlTargetAction(_ sender: AnyObject) {
        controlAction(self)
    }
}

class BasicSetting: Setting {
    
}
