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
    func valueDidChange(newValue :Float)
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
        
        backgroundColor = UIColor.clearColor()
    }
    
    //MARK: - View Setup
    
    /**
     Sets up basic properties for this view
     */
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        setupUnitLabel()
        setupPresetValueTextField()
    }
    
    /**
     Setup properties for unit label at end of view
     */
    private func setupUnitLabel() {
        addSubview(_unitLabel)
        
        _unitLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let unit :NSString = "ml"
        let font = StandardFonts.regularFont(18)
        
        let textSize = unit.sizeWithAttributes([NSFontAttributeName : font]) //Gets size of text based on font and string
            
        addConstraint(NSLayoutConstraint(item: _unitLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _unitLabel, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _unitLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _unitLabel, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: textSize.width + 1)) //Add a +1 because it is too small without it ¯\_(ツ)_/¯

        _unitLabel.textColor = UIColor.whiteColor()
        _unitLabel.font = font
        _unitLabel.text = unit as String
    }
    
    /**
     Sets up preset text field as well as toolbar that lays on top of keyboard that finishes editing
     */
    private func setupPresetValueTextField() {
        addSubview(_presetValueTextField)
        
        _presetValueTextField.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: _presetValueTextField, attribute: .Trailing, relatedBy: .Equal, toItem: _unitLabel , attribute: .Leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _presetValueTextField, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _presetValueTextField, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: bounds.width / 2))
        addConstraint(NSLayoutConstraint(item: _presetValueTextField, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: bounds.height))
        
        _presetValueTextField.textColor = UIColor.whiteColor()
        _presetValueTextField.font = StandardFonts.regularFont(18)
        _presetValueTextField.textAlignment = .Right
        _presetValueTextField.keyboardType = .NumberPad
        _presetValueTextField.keyboardAppearance = .Dark
        _presetValueTextField.delegate = self
        
        //Keyboard toolbar
        
        let screenWidth = AppDelegate.getAppDelegate().window?.frame.width
        
        let keyPadToolbar = UIToolbar(frame: CGRectMake(0, 0, screenWidth!, 50))
        keyPadToolbar.barStyle = .BlackTranslucent
        let flexibleBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let doneBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(PresetValueChangerView.onDoneEditing))
        doneBarButtonItem.setTitleTextAttributes([NSForegroundColorAttributeName: StandardColors.waterColor, NSFontAttributeName: StandardFonts.regularFont(18)], forState: .Normal)
        
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
    func textFieldDidBeginEditing(textField: UITextField) {
        _previousValue = textField.text!
    }
    
    /**
     Determines whether editing should be allowed. Limitations are that only digits may be entered with a max of 3 digits
    
     - returns: Is editing allowed
     */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let char = string.cStringUsingEncoding(NSUTF8StringEncoding)!
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
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text?.characters.count == 0 { //If the preset text field is empty
            textField.text = _previousValue //Replace it with its previous value
        }
        
        _delegate?.valueDidChange(Float(_presetValueTextField.text!)!)
    }
}
