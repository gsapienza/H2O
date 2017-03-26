//
//  CustomPickerInterfaceController.swift
//  H2O
//
//  Created by Gregory Sapienza on 9/17/16.
//  Copyright © 2016 City Pixels. All rights reserved.
//

import WatchKit

class CustomPickerInterfaceController: WKInterfaceController {
    //MARK: - Public iVars
    
    /// Number picker to select custom amount.
    @IBOutlet var numberPicker: WKInterfacePicker!
    
    //MARK: - Private iVars
    
    /// Holds a link to the previous view controller that initialized this interface controller.
    fileprivate var previousViewController :MainInterfaceController?
    
    /// Default value selected from number picker.
    fileprivate var selectedNumberPickerSelection = 1
    
    //MARK: - Public

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        previousViewController = context as? MainInterfaceController //Sets the previous view controller based on context passed in.
        configureNumberPicker()
    }
}


// MARK: - Outlet Configuration
private extension CustomPickerInterfaceController {
    
    /// Configures the number picker for custom entry.
    func configureNumberPicker() {
        var pickerNumberList :[WKPickerItem] = []

        for i in 1 ... 100 { //Can go up to 100unit to add.
            let pickerItem = WKPickerItem()
            pickerItem.title = String(i) + standardUnit.rawValue
            pickerNumberList.append(pickerItem)
        }
        
        numberPicker.setItems(pickerNumberList)
    }
}

// MARK: - Target Action
fileprivate extension CustomPickerInterfaceController {
    
    /// Adds water to the database, updates UI and dismisses this interface controller.
    @IBAction func onAddButton() {
        dismiss()
        previousViewController?.addWaterToToday(amount: Float(selectedNumberPickerSelection))
        WKInterfaceDevice.current().play(.success)
    }
    
    /// Activates as the Digital Crown is settled after being turned. Sets the selectedNumberPickerSelection to the index of the value that the Digital Crown selected.
    ///
    /// - parameter value: Index of value settled on by Digital Crown.
    @IBAction func onNumberPickerSelection(_ value: Int) {
        selectedNumberPickerSelection = value + 1 //Adds 1 because the selector starts at zero.
    }
}
