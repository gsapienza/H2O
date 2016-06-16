//
//  PresetValueChangerView.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/17/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

protocol PresetValueChangerViewProtocol {
    /**
     Called when value in textfield is changed by ending editing
     
     - parameter newValue: New preset value
     */
    func valueDidChange(_ newValue :Float)
}

class PresetValueChangerView: UIView {
        /// Unit label at tail end of view
    private let _unitLabel = UILabel()
    
        /// Text view with preset value
    let _presetValueTextField = UITextField()
    
        /// Delegate to update when a new value is declared
    var _delegate :PresetValueChangerViewProtocol?
    
        /// Previous value to save so that if the user makes an edit at leaves the text field blank, it will be replaced by this
    var _previousValue = String()
    
    /**
     Permanent transparent background
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = UIColor.clear()
        
        setupColors()
    }
    
    //MARK: - View Setup
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    /**
     Sets up basic properties for this view
     */
    private func setup() {
        setupUnitLabel()
        setupPresetValueTextField()
    }
    
    /**
     Setup properties for unit label at end of view
     */
    private func setupUnitLabel() {
        addSubview(_unitLabel)
        
        _unitLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let unit :NSString = Constants.standardUnit.rawValue
        let font = StandardFonts.boldFont(18)
        
        let textSize = unit.size(attributes: [NSFontAttributeName : font]) //Gets size of text based on font and string
            
        addConstraint(NSLayoutConstraint(item: _unitLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _unitLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _unitLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _unitLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: textSize.width + 1)) //Add a +1 because it is too small without it ¯\_(ツ)_/¯

        _unitLabel.font = font
        _unitLabel.text = unit as String
    }
    
    /**
     Sets up preset text field as well as toolbar that lays on top of keyboard that finishes editing
     */
    private func setupPresetValueTextField() {
        addSubview(_presetValueTextField)
        
        _presetValueTextField.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: _presetValueTextField, attribute: .trailing, relatedBy: .equal, toItem: _unitLabel , attribute: .leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _presetValueTextField, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _presetValueTextField, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.5, constant: 0))
        addConstraint(NSLayoutConstraint(item: _presetValueTextField, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0))
        
        _presetValueTextField.font = StandardFonts.boldFont(18)
        _presetValueTextField.textAlignment = .right
        _presetValueTextField.keyboardType = .numberPad
        _presetValueTextField.keyboardAppearance = StandardColors.standardKeyboardAppearance
        _presetValueTextField.tintColor = StandardColors.waterColor
        _presetValueTextField.delegate = self
        
        //Keyboard toolbar
        
        let screenWidth = AppDelegate.getAppDelegate().window?.frame.width
        
        let keyPadToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth!, height: 50))
        if AppDelegate.isDarkModeEnabled() {
            keyPadToolbar.barStyle = .blackTranslucent
        } else {
            keyPadToolbar.barStyle = .default
        }
        let flexibleBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(PresetValueChangerView.onDoneEditing))
        doneBarButtonItem.setTitleTextAttributes([NSForegroundColorAttributeName: StandardColors.waterColor, NSFontAttributeName: StandardFonts.regularFont(18)], for: UIControlState())
        
        keyPadToolbar.items = [flexibleBarButtonItem, doneBarButtonItem]
        keyPadToolbar.sizeToFit()
        
        _presetValueTextField.inputAccessoryView = keyPadToolbar
    }
    
    /**
     Done editing preset. Finish editing to call text field delegate and save
     */
    func onDoneEditing() {
        _presetValueTextField.resignFirstResponder()
    }
}

// MARK: - UITextFieldDelegate
extension PresetValueChangerView :UITextFieldDelegate {
    /**
     When the text field begins editing this saves its value so that if the user leaves it empty, the text field text will be replaced by its old value
     */
    func textFieldDidBeginEditing(_ textField: UITextField) {
        _previousValue = textField.text!
    }
    
    /**
     Determines whether editing should be allowed. Limitations are that only digits may be entered with a max of 3 digits
    
     - returns: Is editing allowed
     */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")

        if Int(string) != nil || isBackSpace == -92 { //Is it a number or a backspace value
            if textField.text!.characters.count + 1 > 3 && isBackSpace != -92  { //Is there less than 3 characters or is this a backspace
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    /**
     When the preset text field is done editing call its delegate to tell it that the value did change
    */
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.characters.count == 0 { //If the preset text field is empty
            textField.text = _previousValue //Replace it with its previous value
        }
        
        _delegate?.valueDidChange(Float(_presetValueTextField.text!)!)
    }
}

// MARK: - NightModeProtocol
extension PresetValueChangerView :NightModeProtocol {
    func setupColors() {
        _unitLabel.textColor = StandardColors.primaryColor
        _presetValueTextField.textColor = StandardColors.primaryColor
    }
}
