//
//  InformationViewControllerModel.swift
//  H2O
//
//  Created by Gregory Sapienza on 10/21/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import Foundation

struct DayEntry {
    
    /// Month, day and year date of entries.
    private var date :Date?
    
    /// Entries added on date.
    private var entries :[Entry]?
    
    init(date :Date?, entries :[Entry]?) {
        self.date = date
        self.entries = entries
    }
    
    /// Append a new entry value.
    ///
    /// - parameter entry: Entry to append.
    mutating func append(entry :Entry) {
        if var entries = self.entries {
            entries.append(entry)
        } else {
            entries = []
            entries!.append(entry)
        }
    }
    
    /// Get date value when entries were added.
    ///
    /// - returns: Date of entries.
    func getDate() -> Date? {
        guard let date = self.date else {
            print("Date is nil")
            return nil
        }
        
        return date
    }
    
    /// Get all entries.
    ///
    /// - returns: Entries added on date.
    func getEntries() -> [Entry]? {
        guard let entries = self.entries else {
            print("Entries is nil")
            return nil
        }
        
        return entries
    }
    
    /// Get entry at index of entries array.
    ///
    /// - parameter at: Index of entry.
    ///
    /// - returns: Entry at index.
    func entry(at :Int) -> Entry? {
        guard let entries = self.entries else {
            return nil
        }
        
        return entries[at]
    }
    
    /// Helper function to get number of entries in entries array.
    ///
    /// - returns: Number of entries for date.
    func entryCount() -> Int {
        guard let entries = self.entries else {
            return 0
        }
        
        return entries.count
    }
    
    /// Remove entry at index.
    ///
    /// - parameter at: Index to remove from entries array.
    mutating func removeEntry(at :Int) {
        guard var entries = self.entries else {
            return
        }
        
        let entry = entries[at]
        entries.remove(at: at)
        entry.deleteEntry()
        
        self.entries = entries //Set entries to new reference.
    }
}

class InformationViewControllerModel {
    
}
