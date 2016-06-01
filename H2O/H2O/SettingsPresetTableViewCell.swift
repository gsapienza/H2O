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
        /// Preset changer view. Provides a text field so that users can change the presets for water amounts or goals
    let _presetValueChangerView = PresetValueChangerView()
    
        /// Delegate to update when the preset value changed for this cell
    var _delegate :SettingsPresetTableViewCellProtocol?
    
    //MARK: - View Setup
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupPresetValueChangerView()
    }
    
    /**
     Sets up properties for the preset changer
     */
    private func setupPresetValueChangerView() {
        addSubview(_presetValueChangerView)
        
        _presetValueChangerView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: _presetValueChangerView, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: -15))
        addConstraint(NSLayoutConstraint(item: _presetValueChangerView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _presetValueChangerView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _presetValueChangerView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: bounds.width / 4))
        
        _presetValueChangerView._delegate = self
    }
}

// MARK: - PresetValueChangerViewProtocol
extension SettingsPresetTableViewCell :PresetValueChangerViewProtocol {
    /**
     Called by the preset value changer. Will call the delegate for this cell to updates the settings view controller on changes to the preset value
     
     - parameter newValue: New preset value for this cell
     */
    func valueDidChange(newValue: Float) {
        _delegate?.presetValueDidChange(self, newValue: newValue)
    }
}
