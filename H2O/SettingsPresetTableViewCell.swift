//
//  SettingsPresetTableViewCell.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/17/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

protocol SettingsPresetTableViewCellProtocol {
    /**
     When the preset value has been changed
     
     - parameter settingsPresetTableViewCell: Cell affected to differentiate one from another
     - parameter newValue:                    New Preset Value
     */
    func presetValueDidChange(settingsPresetTableViewCell :SettingsPresetTableViewCell, newValue :Float)
}

class SettingsPresetTableViewCell: SettingsTableViewCell {
    //MARK: - Public iVars
    
    /// Preset changer view. Provides a text field so that users can change the presets for water amounts or goals
    var presetValueChangerView :PresetValueChangerView!
    
    /// Delegate to update when the preset value changed for this cell
    var delegate :SettingsPresetTableViewCellProtocol?
    
    //MARK: - View Setup
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        presetValueChangerView = generatePresetValueChangerView()
        
        layout()
    }
    
    private func layout() {
        //---Preset Value Changer View---
        addSubview(presetValueChangerView)
        
        presetValueChangerView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: presetValueChangerView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -15))
        addConstraint(NSLayoutConstraint(item: presetValueChangerView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: presetValueChangerView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: presetValueChangerView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: bounds.width / 4))
    }
}

// MARK: - Private Generators
private extension SettingsPresetTableViewCell {
    /// Generate a preset value changer
    ///
    /// - returns: A preset value changer view
    func generatePresetValueChangerView() -> PresetValueChangerView {
        let view = PresetValueChangerView()
        view.alignment = .right
        view.delegate = self

        return view
    }
}

// MARK: - PresetValueChangerViewProtocol
extension SettingsPresetTableViewCell :PresetValueChangerViewProtocol {

    /// Called by the preset value changer. Will call the delegate for this cell to updates the settings view controller on changes to the preset value
    ///
    /// - parameter newValue: New preset value for this cell
    func valueDidChange( newValue: Float) {
        delegate?.presetValueDidChange(settingsPresetTableViewCell: self, newValue: newValue)
    }
}
