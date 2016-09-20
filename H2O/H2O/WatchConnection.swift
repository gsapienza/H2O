//
//  WatchConnection.swift
//  H2O
//
//  Created by Gregory Sapienza on 9/19/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import WatchConnectivity

class WatchConnection: NSObject {
    //MARK: - Public iVars
    static let standardWatchConnection = WatchConnection()
    
    //MARK: - Private iVars
    
    private var session :WCSession?
    
    //MARK: - Public
    
    func activateSession() {
        if session == nil {
            guard WCSession.isSupported() else {
                return
            }
            
            session = WCSession.default()
            session?.delegate = self
            session?.activate()
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
    
    func getDefaults() {
        sendMessage([GetDefaultsWatchMessage : 0], replyHandler: { (replyHandler :[String : Any]) in

            }) { (Error) in
                print("Error getting defaults")
        }
    }
    
    //MARK: - Private
    
    private func sendMessage(_ message: [String : Any], replyHandler: (([String : Any]) -> Void)?, errorHandler: ((Error) -> Void)? = nil) {
        
        guard let session = self.session else {
            print("Watch session is not active")
            return
        }
        
        session.sendMessage(message, replyHandler: replyHandler) { (error :Error) in
            print("Message was not sent")
            return
        }
        
        print("Message \(message) sent")
    }
}

// MARK: - WCSessionDelegate
extension WatchConnection :WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    #endif
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        for item in message {
            switch item.key {
            case PresetsUpdatedWatchMessage:
                let presets = item.value as! [Float]
                NotificationCenter.default.post(name: PresetsUpdatedNotification, object: nil, userInfo: [PresetValuesNotificationInfo : presets])
                AppUserDefaults.setPresetWaterValues(presets: presets)
                break
            case GoalUpdatedWatchMessage:
                let goal = item.value as! Float
                NotificationCenter.default.post(name: GoalUpdatedNotification, object: nil, userInfo: [GoalValueNotificationInfo : goal])
                AppUserDefaults.setDailyGoalValue(goal: goal)
                break
            case GetDefaultsWatchMessage:
                if let presets = AppUserDefaults.getPresetWaterValues() {
                    sendPresetsUpdatedMessage(presets: presets)
                }
                if let goal = AppUserDefaults.getDailyGoalValue() {
                    sendGoalUpdatedMessage(goal: goal)
                }
                break
                
            default:
                break
            }
        }
    }
}
