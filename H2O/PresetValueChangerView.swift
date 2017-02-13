//
//  PresetValueChangerView.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/17/16.
//  Copyright © 2016 Skyscrapers.IO. All rights reserved.
//

import UIKit

protocol PresetValueChangerViewProtocol {
    /**
     Called when value in textfield is changed by ending editing
     
     - parameter newValue: New preset value
     */
    func valueDidChange( newValue :Float)
}

class PresetValueChangerView: UIView {
        /// Unit label at tail end of view
    let unitLabel = UILabel()
    
        /// Text view with preset value
    let presetValueTextField = UITextField()
    
        /// Delegate to update when a new value is declared
    var delegate :PresetValueChangerViewProtocol?
    
        /// Previous value to save so that if the user makes an edit at leaves the text field blank, it will be replaced by this
    var previousValue = String()
    
    var fontSize :CGFloat = 17
    
    var toolbarEnabled = true
    
    var alignment :NSTextAlignment = .center
    
    /**
     Permanent transparent background
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setup()
        
        backgroundColor = UIColor.clear
        
        unitLabel.textColor = StandardColors.primaryColor
        presetValueTextField.textColor = StandardColors.primaryColor
        
        //Keyboard toolbar
        
        if toolbarEnabled {
            let screenWidth = getAppDelegate().window?.frame.width
            
            let keyPadToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth!, height: 50))
            keyPadToolbar.barStyle = .blackTranslucent

            let flexibleBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            let doneBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(PresetValueChangerView.onDoneEditing))
            doneBarButtonItem.setTitleTextAttributes([NSForegroundColorAttributeName: StandardColors.waterColor, NSFontAttributeName: StandardFonts.regularFont(size: 18)], for: UIControlState())
            
            keyPadToolbar.items = [flexibleBarButtonItem, doneBarButtonItem]
            keyPadToolbar.sizeToFit()
            
            presetValueTextField.inputAccessoryView = keyPadToolbar
        }
    }
    
    //MARK: - View Setup
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        presetValueTextField.font = StandardFonts.boldFont(size: fontSize)
        presetValueTextField.textAlignment = .right
        presetValueTextField.keyboardType = .numberPad
        presetValueTextField.keyboardAppearance = StandardColors.standardKeyboardAppearance
        presetValueTextField.tintColor = StandardColors.waterColor
        presetValueTextField.delegate = self
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        presetValueTextField.font = StandardFonts.boldFont(size: fontSize)
        presetValueTextField.textAlignment = .right
        presetValueTextField.keyboardType = .numberPad
        presetValueTextField.keyboardAppearance = StandardColors.standardKeyboardAppearance
        presetValueTextField.tintColor = StandardColors.waterColor
        presetValueTextField.delegate = self
    }
    
    init(fontSize :CGFloat) {
        super.init(frame: CGRect.zero)
        self.fontSize = fontSize
        
        presetValueTextField.font = StandardFonts.boldFont(size: fontSize)
        presetValueTextField.textAlignment = .right
        presetValueTextField.keyboardType = .numberPad
        presetValueTextField.keyboardAppearance = StandardColors.standardKeyboardAppearance
        presetValueTextField.tintColor = StandardColors.waterColor
        presetValueTextField.delegate = self
        
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
        addSubview(unitLabel)
        
        unitLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let unit :NSString = standardUnit.rawValue as NSString
        let font = StandardFonts.regularFont(size: fontSize)
        let textSize = unit.size(attributes: [NSFontAttributeName : font]) //Gets size of text based on font and string
        
        addConstraint(NSLayoutConstraint(item: unitLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: unitLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: unitLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        
        var widthConstraint :NSLayoutConstraint!
        
        if alignment == .center {
            widthConstraint = NSLayoutConstraint(item: unitLabel, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.5, constant: 1) //Add a +1 because it is too small without it ¯\(ツ)/¯
        } else if alignment == .right {
            widthConstraint = NSLayoutConstraint(item: unitLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: textSize.width + 1) //Add a +1 because it is too small without it ¯\(ツ)/¯
        }

        addConstraint(widthConstraint)
        
        unitLabel.font = font
        unitLabel.text = unit as String
    }
    
    /**
     Sets up preset text field as well as toolbar that lays on top of keyboard that finishes editing
     */
    private func setupPresetValueTextField() {
        addSubview(presetValueTextField)
        
        presetValueTextField.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: presetValueTextField, attribute: .leading, relatedBy: .equal, toItem: self , attribute: .leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: presetValueTextField, attribute: .trailing, relatedBy: .equal, toItem: unitLabel , attribute: .leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: presetValueTextField, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: presetValueTextField, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0))
        
    }
    
    /**
     Done editing preset. Finish editing to call text field delegate and save
     */
    func onDoneEditing() {
        presetValueTextField.resignFirstResponder()
    }
}

// MARK: - UITextFieldDelegate
extension PresetValueChangerView :UITextFieldDelegate {
    /**
     When the text field begins editing this saves its value so that if the user leaves it empty, the text field text will be replaced by its old value
     */
    func textFieldDidBeginEditing(_ textField: UITextField) {
        previousValue = textField.text!
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
            textField.text = previousValue //Replace it with its previous value
        }
        
        if let delegate = self.delegate {
            if let presetValueText = presetValueTextField.text {
                if let presetValue = Float(presetValueText) {
                    delegate.valueDidChange(newValue: presetValue)
                }
            }
        }
    }
}
