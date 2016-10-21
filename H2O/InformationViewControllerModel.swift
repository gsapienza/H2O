//
//  InformationViewControllerModel.swift
//  H2O
//
//  Created by Gregory Sapienza on 10/21/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import Foundation

struct DayEntry {
    private var date :Date?
    private var entries :[Entry]?
    
    init(date :Date?, entries :[Entry]?) {
        self.date = date
        self.entries = entries
    }
    
    mutating func append(entry :Entry) {
        if var entries = self.entries {
            entries.append(entry)
        } else {
            entries = []
            entries!.append(entry)
        }
    }
    
    func getDate() -> Date? {
        guard let date = self.date else {
            print("Date is nil")
            return nil
        }
        
        return date
    }
    
    func getEntries() -> [Entry]? {
        guard let entries = self.entries else {
            print("Entries is nil")
            return nil
        }
        
        return entries
    }
    
    func entry(at :Int) -> Entry? {
        guard let entries = self.entries else {
            return nil
        }
        
        return entries[at]
    }
    
    func entryCount() -> Int {
        guard let entries = self.entries else {
            return 0
        }
        
        return entries.count
    }
    
    mutating func removeEntry(at :Int) {
        guard var entries = self.entries else {
            return
        }
        
        let entry = entries[at]
        entries.remove(at: at)
        entry.deleteEntry()
        
        self.entries = entries //Set entries to new reference/
    }
}

class InformationViewControllerModel {
    
}
