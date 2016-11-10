//
//  WatchConnection.swift
//  H2O
//
//  Created by Gregory Sapienza on 9/19/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import WatchConnectivity

enum WatchConnectionError: Error {
    case sessionFailed(String)
}

class WatchConnection: NSObject {
    //MARK: - Public iVars
    static let standardWatchConnection = WatchConnection()
    
    //MARK: - Private iVars
    
    private var session :WCSession?
    
    fileprivate var syncEngine :WatchSyncEngine?
    
    fileprivate var needsSync = false
    
    //MARK: - Public
    
    func activateSession() {
        if session == nil {
            guard WCSession.isSupported() else {
                return
            }
            
            session = WCSession.default()
            
            session?.delegate = self
            session?.activate()
            syncEngine = WatchSyncEngine()
            syncEngine?.delegate = self
        }
    }
    
    func sendPresetsUpdatedMessage(presets :[Float]) {
        sendMessage([PresetsUpdatedWatchMessage : presets], replyHandler: { (replyHandler : [String : Any]) in
            }) { (Error) in
        }
    }
    
    func sendGoalUpdatedMessage(goal :Float) {
        sendMessage([GoalUpdatedWatchMessage : goal], replyHandler: { (replyHandler : [String : Any]) in
        }) { (Error) in
        }
    }
    
    func getDefaults(reply: (([String : Any]) -> Void)?) {
        sendMessage([GetDefaultsWatchMessage : 0], replyHandler: { (replyHandler :[String : Any]) in
            guard
                let presets = replyHandler[PresetValuesFromWatchMessage] as? [Float],
                let goal = replyHandler[GoalValueFromWatchMessage] as? Float
            else {
                return
            }
            
            AppUserDefaults.setPresetWaterValues(presets: presets)
            AppUserDefaults.setDailyGoalValue(goal: goal)
            
            guard let reply = reply else {
                return
            }
            
            reply(replyHandler)
            
            }) { (Error) in
                print("Error getting defaults.")
        }
    }
    
    func beginSync(reply: (([String : Any]) -> Void)?) {
        sendMessage([StartSyncWatchMessage : 0], replyHandler: { (replyHandler : [String : Any]) in
        }) { (Error) in
            print("Error starting sync.")
        }
    }
    
    func requestSync(reply: (([String : Any]) -> Void)?) {
        guard let syncEngine = syncEngine else {
            print("Sync engine not set up.")
            return
        }
        
        syncEngine.prepareSync { (dataToSync :[String : Any]?) in
            guard let dataToSync = dataToSync else {
                self.needsSync = true
                NSLog("Data to sync is nil.")
                return
            }
            
            self.sendMessage([RequestSyncWatchMessage : 0, SyncDataWatchMessage : dataToSync], replyHandler: { (replyHandler :[String : Any]) in
                guard
                    let entriesToInsert = replyHandler[EntriesToInsertFromWatchMessage] as? [[String : Any]],
                    let entriesToModify = replyHandler[EntriesToModifyFromWatchMessage] as? [[String : Any]]
                    else {
                        print("No Entries to insert or modify")
                        return
                }
                
                guard let syncBeganDate = dataToSync[WatchDataSyncBeganDate] as? Date else {
                    print("Sync began date not property not set.")
                    return
                }
                
                syncEngine.addItemsFromSync(entriesToInsert: entriesToInsert)
                syncEngine.modifyItemsFromSync(entriesToModify: entriesToModify)
                
                syncEngine.cleanup(newLastWatchSyncDate: syncBeganDate)
                
                guard let reply = reply else {
                    return
                }
                
                reply(replyHandler)
                }, errorHandler: { (error :Error) in
                    syncEngine.syncFailed()
                    NSLog("Error requesting sync.")
            })
        }
    }

    //MARK: - Private
    
    private func sendMessage(_ message: [String : Any], replyHandler: (([String : Any]) -> Void)?, errorHandler: ((Error) -> Void)? = nil) {
        
        guard let session = self.session else {
            NSLog("Watch session is not active.")
            return
        }
        
        if session.activationState == .activated && session.isReachable == true {
            session.sendMessage(message, replyHandler: { (reply :[String : Any]) in
                if let replyHandler = replyHandler {
                    replyHandler(reply)
                }
                
                NSLog("Message \(message) sent.")

                }, errorHandler: { (error :Error) in
                    NSLog("Message \(message) was not sent. \(error)")
                    errorHandler!(error)
                    return
            })
        } else {
            NSLog("SESSION COULD NOT BE ESTABLISHED TO SEND MESSAGE")
            let error :Error = WatchConnectionError.sessionFailed("1")
            errorHandler!(error)
        }
    }
}

// MARK: - WCSessionDelegate
extension WatchConnection :WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Watch Session is Activated")        
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isReachable {
            #if os(watchOS)
                requestSync(reply: { (replyHandler :[String : Any]) in
                })
                
                getDefaults { (reply :[String : Any]) in
                }
            
            #endif
        }
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    #endif
    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if session.activationState == .activated && session.isReachable == true {
            for item in message {
                switch item.key {
                case PresetsUpdatedWatchMessage:
                    if let presets = item.value as? [Float] {
                        NotificationCenter.default.post(name: PresetsUpdatedNotification, object: nil, userInfo: [PresetValuesNotificationInfo : presets])
                        AppUserDefaults.setPresetWaterValues(presets: presets)
                    }
                    
                    break
                case GoalUpdatedWatchMessage:
                    if let goal = item.value as? Float {
                        NotificationCenter.default.post(name: GoalUpdatedNotification, object: nil, userInfo: [GoalValueNotificationInfo : goal])
                        AppUserDefaults.setDailyGoalValue(goal: goal)
                    }
                    
                    break
                case GetDefaultsWatchMessage:
                    if let presets = AppUserDefaults.getPresetWaterValues() , let goal = AppUserDefaults.getDailyGoalValue() {
                        
                        let reply = [PresetValuesFromWatchMessage : presets, GoalValueFromWatchMessage : goal] as [String : Any]
                        replyHandler(reply)
                    }
                    break
                case RequestSyncWatchMessage:
                    guard let syncData = message[SyncDataWatchMessage] as? [String : Any],
                        let lastWatchSyncDate = syncData[WatchDataLastWatchSyncDate] as? Date,
                        let insertedItemsFromDevice = syncData[WatchDateInsertedItems] as? [[String : Any]],
                        let modifiedItemsFromDevice = syncData[WatchDateModifiedItems] as? [[String : Any]]
                    else {
                        print("Sync date properties not set.")
                        return
                    }
                    
                    guard let syncEngine = syncEngine else {
                        print("Sync engine not set up.")
                        return
                    }
                    
                    syncEngine.performSync(lastWatchSyncDate: lastWatchSyncDate, itemsInserted: insertedItemsFromDevice, itemsModified: modifiedItemsFromDevice, itemsToSyncFromThisDevice: { (itemsToSyncFromThisDevice :[String : [[String : Any]]]) in
                        let reply = itemsToSyncFromThisDevice as [String : Any]
                        
                        replyHandler(reply)
                    })
                    
                    break
                case StartSyncWatchMessage:
                    requestSync(reply: { (replyHandler :[String : Any]) in
                    })
                    break
                default:
                    break
                }
            }
        } else {
            NSLog("SESSION COULD NOT BE ESTABLISHED TO RECIEVE MESSAGE")
        }
    }
}

// MARK: - WatchSyncEngineProtocol
extension WatchConnection :WatchSyncEngineProtocol {
    func syncCompleted() {
        if needsSync {
            requestSync { (_: [String : Any]) in
                self.needsSync = false
            }
        }
    }
}
