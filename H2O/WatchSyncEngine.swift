//
//  WatchSyncEngine.swift
//  H2O
//
//  Created by Gregory Sapienza on 9/20/16.
//  Copyright © 2016 Midnite. All rights reserved.
//

import Foundation

fileprivate enum EntryKeys :String {
    case id
    case amount
    case date
    case creationDate
    case modificationDate
    case wasDeleted
}

protocol WatchSyncEngineProtocol {
    func syncCompleted()
}

class WatchSyncEngine: NSObject {
    
    //MARK: - Private iVars
    
    private var user :User? {
        #if os(iOS)
        guard let _user = getAppDelegate().user else {
            return nil
        }
        #endif
        
        #if os(watchOS)
        guard let _user = getWKExtensionDelegate().user else {
            return nil
        }
        #endif
        
        return _user
    }
    
    var delegate :WatchSyncEngineProtocol?
    
    private var syncing = false
    
    //MARK: - Public

    func prepareSync(dataToSync: @escaping (([String : Any]?) -> Void)) {
        DispatchQueue.main.async {
            guard let user = self.user else {
                print("No user found.")
                return
            }
            
            if !self.syncing {
                let itemsInserted = self.getEntriesForInsertion(lastWatchSyncDate :user.lastWatchSyncDate)
                let itemsModified = self.getModifiedEntries(lastWatchSyncDate: user.lastWatchSyncDate)
                let data = [WatchDataSyncBeganDate : Date(), WatchDataLastWatchSyncDate : user.lastWatchSyncDate, WatchDateInsertedItems : itemsInserted, WatchDateModifiedItems : itemsModified] as [String : Any]
                self.syncing = true
                dataToSync(data)
            } else {
                dataToSync(nil)
            }
        }
    }
    
    func syncFailed() {
        syncing = false
    }
    
    func performSync(lastWatchSyncDate :Date, itemsInserted :[[String : Any]], itemsModified :[[String : Any]], itemsToSyncFromThisDevice: @escaping (([String : [[String : Any]]]) -> Void)) {
        DispatchQueue.main.async {
            let entriesForInsertion = self.getEntriesForInsertion(lastWatchSyncDate :lastWatchSyncDate) as [[String : Any]]
            let entriesModified = self.getModifiedEntries(lastWatchSyncDate: lastWatchSyncDate) as [[String : Any]]
            self.addItemsFromSync(entriesToInsert: itemsInserted)
            self.modifyItemsFromSync(entriesToModify: itemsModified)
            itemsToSyncFromThisDevice([EntriesToInsertFromWatchMessage : entriesForInsertion, EntriesToModifyFromWatchMessage : entriesModified])
        }
    }
    
    func addItemsFromSync(entriesToInsert :[[String : Any]]) {
        DispatchQueue.main.async {
            for entry in entriesToInsert {
                guard
                    let id = entry[EntryKeys.id.rawValue] as? String,
                    let amount = entry[EntryKeys.amount.rawValue] as? Float,
                    let date = entry[EntryKeys.date.rawValue] as? Date,
                    let creationDate = entry[EntryKeys.creationDate.rawValue] as? Date,
                    let modificationDate = entry[EntryKeys.modificationDate.rawValue] as? Date,
                    let wasDeleted = entry[EntryKeys.wasDeleted.rawValue] as? NSNumber
                    else {
                        print("Entry properties are invalid.")
                        return
                }
                
                let entry = Entry.createNewEntry(id: id, amount: amount, date: date, creationDate :creationDate, modificationDate :modificationDate, wasDeleted :wasDeleted)

                self.user?.addEntry(entry: entry)
            }
        }
    }
    
    func modifyItemsFromSync(entriesToModify :[[String : Any]]) {
        DispatchQueue.main.async {
            guard let user = self.user else {
                print("No user found.")
                return
            }
            
            for entry in entriesToModify {
                guard
                    let id = entry[EntryKeys.id.rawValue] as? String,
                    let amount = entry[EntryKeys.amount.rawValue] as? NSNumber,
                    let date = entry[EntryKeys.date.rawValue] as? Date,
                    let modificationDate = entry[EntryKeys.modificationDate.rawValue] as? Date,
                    let wasDeleted = entry[EntryKeys.wasDeleted.rawValue] as? NSNumber
                    else {
                        print("Entry properties are invalid.")
                        return
                }
                
                if let entryObject = user.getEntryFor(id: id) {
                    entryObject.amount = amount
                    entryObject.date = date
                    entryObject.modificationDate = modificationDate
                    entryObject.wasDeleted = wasDeleted
                }
            }
        }
    }
    
    func cleanup(newLastWatchSyncDate :Date) {
        DispatchQueue.main.async {
            guard let user = self.user else {
                print("No user found.")
                return
            }
            self.syncing = false
            user.lastWatchSyncDate = newLastWatchSyncDate
            
            do {
                try User.managedContext().save()
                NotificationCenter.default.addObserver(self, selector: #selector(self.contextSaved), name: Notification.Name.NSManagedObjectContextDidSave, object: nil)
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
    }
    
    func contextSaved() {
        if !syncing {
            print("LAST WATCH SYNC")
            print(user?.lastWatchSyncDate)
            delegate?.syncCompleted()
            
            NotificationCenter.default.post(name: SyncCompletedNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: Notification.Name.NSManagedObjectContextDidSave, object: nil)
        }
    }
    
    //MARK: - Private
    
    private func getEntriesForInsertion(lastWatchSyncDate :Date) -> [[String : Any]] {
        guard let user = self.user else {
            print("No user found.")
            return []
        }
        
        guard
            let entries = user.entries
            else {
                print("User properties are invalid.")
                return []
        }
        
        var entriesForInsertion :[[String : Any]] = []
        
        for entry in entries {
            guard let entry = entry as? Entry else {
                return []
            }
            
            if entry.creationDate.compare(lastWatchSyncDate) == .orderedDescending {
                let entryDict :[String : Any] = [EntryKeys.id.rawValue : entry.id, EntryKeys.amount.rawValue : entry.amount, EntryKeys.date.rawValue : entry.date, EntryKeys.creationDate.rawValue : entry.creationDate, EntryKeys.modificationDate.rawValue : entry.modificationDate, EntryKeys.wasDeleted.rawValue : entry.wasDeleted]
                
                
                    entriesForInsertion.append(entryDict)
            }
        }
        
        return entriesForInsertion
    }
    
    
    private func getModifiedEntries(lastWatchSyncDate :Date) -> [[String : Any]] {
        guard let user = self.user else {
            print("No user found.")
            return []
        }
        
        guard
            let entries = user.entries
            else {
                print("User properties are invalid.")
                return []
        }
        
        var entriesModified :[[String : Any]] = []
        
        for entry in entries {
            guard let entryObject = entry as? Entry else {
                return []
            }
            
            if entryObject.modificationDate.compare(lastWatchSyncDate) == .orderedDescending && entryObject.creationDate.compare(lastWatchSyncDate) == .orderedAscending {
                let entryDict :[String : Any] = [EntryKeys.id.rawValue : entryObject.id, EntryKeys.amount.rawValue : entryObject.amount, EntryKeys.date.rawValue : entryObject.date, EntryKeys.creationDate.rawValue : entryObject.creationDate, EntryKeys.modificationDate.rawValue : entryObject.modificationDate, EntryKeys.wasDeleted.rawValue : entryObject.wasDeleted]
                entriesModified.append(entryDict)
            }
        }
        
        return entriesModified
    }
}
