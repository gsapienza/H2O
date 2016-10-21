//
//  InformationViewControllerModel.swift
//  H2O
//
//  Created by Gregory Sapienza on 10/21/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import Foundation


class DayEntry {
    private var date :Date?
    private var entries :[Entry]?
    
    init(date :Date?, entries :[Entry]?) {
        self.date = date
        self.entries = entries
    }
    
    func append(entry :Entry) {
        if var entries = self.entries {
            entries.append(entry)
        } else {
            entries = []
            entries!.append(entry)
        }
    }
    
    func entry(atIndex :Int) -> Entry? {
        guard let entries = self.entries else {
            return nil
        }
        
        return entries[atIndex]
    }
}
