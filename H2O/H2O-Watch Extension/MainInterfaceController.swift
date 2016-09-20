//
//  InterfaceController.swift
//  H2O-Watch Extension
//
//  Created by Gregory Sapienza on 9/14/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import WatchKit
import Foundation


class MainInterfaceController: WKInterfaceController {
    //MARK: - Public iVars
    
    /// Where the sprite kit scene will be placed on the watch interface controller.
    @IBOutlet weak var mainScene: WKInterfaceSKScene!
    
    /// Main scene for all interface elements on the main screen
    var h2Oscene :H2OMainScene!
    
    //MARK: - Public
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        h2Oscene = generateScene()
        layout()
        h2Oscene.setup()
        addNotificationObservers()
        updateTimeRelatedItems()
        
        //If the date changes while the app is open this timer will update the UI to reflect daily changes
        let newDateTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(MainInterfaceController.updateTimeRelatedItems), userInfo: nil, repeats: true)
        RunLoop.current.add(newDateTimer, forMode: RunLoopMode.commonModes)
    }
    
    /// Adds water to user in database by using presets, custom amount or other means and then updates the UI to reflect the changes.
    ///
    /// - parameter amount: Amount of water in fl oz.
    func addWaterToToday(amount :Float) {
        let beforeAmount = getWKExtensionDelegate().user?.amountOfWaterForToday() //Water drank before entering this latest entry
        getWKExtensionDelegate().user!.addNewEntryToUser(amount, date: nil) //Add entry to database.
        let newAmount = beforeAmount! + amount
        h2Oscene.totalAmountLabel.text = "\(Int(newAmount))\(standardUnit.rawValue)"
        
        guard let goal = AppUserDefaults.getDailyGoalValue() else {
            return
        }
        
        updateFluidValue(current: newAmount, goal :goal)
    }
    
    //MARK: - Private
    
    /// Layout sizes of 'child views.'
    private func layout() {
        h2Oscene.size = contentFrame.size
        mainScene.presentScene(h2Oscene)
    }
    
    /// Adds notification observers for this interface controller to listen for.
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(switchToBackgroundState), name: WatchAppSwitchedToBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(switchToForegroundState), name: WatchAppSwitchedToForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presetValuesUpdated), name: PresetsUpdatedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goalValueUpdated), name: GoalUpdatedNotification, object: nil)
    }
    
    /// Converts a point to a coordinate system from one beginning from the bottom left to one beginning with the top left.
    ///
    /// - parameter point:           Original point from original coordinate system.
    /// - parameter sizeOfContainer: Size of coordinate system.
    ///
    /// - returns: Returns the original point converted to reflect the top left coordinate system.
    fileprivate func convertPointToReversedYCoordinate(point :CGPoint, sizeOfContainer :CGSize) -> CGPoint {
        let y = sizeOfContainer.height - point.y
        return CGPoint(x: point.x, y: y)
    }
    
    
    /// Updates the height of the fluid value by getting the ratio of amount of water drank and goal.
    ///
    /// - parameter currentValue: Current amount of water drank.
    /// - parameter goal: Goal of water to be drank.
    fileprivate func updateFluidValue(current :Float, goal :Float) {
        var newFillValue :Float = Float((current / goal) * 1.0) //New ratio
        
        delay(delay: 0.2) { //Aesthetic delay
            self.h2Oscene.fluidNode.fillTo(&newFillValue) //New fill value 0-1
        }
    }
    
    ///Called via timer to check if the day has changed while the app is opened and UI elements need updating.
    @objc private func updateTimeRelatedItems() {
        let amount = getWKExtensionDelegate().user?.amountOfWaterForToday()
        h2Oscene.totalAmountLabel.text = "\(Int(amount!))\(standardUnit.rawValue)"
        
        guard let goal = AppUserDefaults.getDailyGoalValue() else {
            return
        }
        
        updateFluidValue(current: amount!, goal :goal)
    }
}

// MARK: - Private Generators
private extension MainInterfaceController {
    
    /// Generates a scene to use for the main interface, sets entry buttons based on UserDefaults.
    ///
    /// - returns: Configured sprite scene.
    func generateScene() -> H2OMainScene {
        let scene = H2OMainScene()
        scene.backgroundColor = UIColor.black
        if let presets = AppUserDefaults.getPresetWaterValues() {
            scene.entryButton1.amount = presets[0]
            scene.entryButton2.amount = presets[1]
            scene.entryButton3.amount = presets[2]
        } else {
            print("Presets Not Set")
        }
        
        return scene
    }
}

// MARK: - Target Action
fileprivate extension MainInterfaceController {
    
    /// Action to perform when the screen is tapped. Checks the coordinates touched and if once reflects a button, performs button action. Entry buttons adds water while custom button presents a new inferface to add a custom amount with a picker. Each time water is added a sound is played.
    ///
    /// - parameter sender: Gesture for tap on main interface.
    @IBAction func onTapGesture(_ sender: WKTapGestureRecognizer) {
        guard let presets = AppUserDefaults.getPresetWaterValues() else {
            return
        }
        
        if sender.state == .ended { //When the user has tapped (.begin does not work for tap gestures according to documentation).
            let locationOfGesture = convertPointToReversedYCoordinate(point: sender.locationInObject(), sizeOfContainer: h2Oscene.entryButtonContainer.size) //Get the location of the gesture reversed to reflect the sprite scene coordinate system.
            
            if h2Oscene.entryButton1.contains(locationOfGesture) { //Entry Button 1 was tapped.
                h2Oscene.entryButton1.highlighted = true
                WKInterfaceDevice.current().play(.success)
                addWaterToToday(amount: presets[0])
                
            } else if h2Oscene.entryButton2.contains(locationOfGesture) { //Entry Button 2 was tapped.
                h2Oscene.entryButton2.highlighted = true
                WKInterfaceDevice.current().play(.success)
                addWaterToToday(amount: presets[1])
                
            } else if h2Oscene.entryButton3.contains(locationOfGesture) { //Entry Button 3 was tapped.
                h2Oscene.entryButton3.highlighted = true
                WKInterfaceDevice.current().play(.success)
                addWaterToToday(amount: presets[2])
                
            } else if h2Oscene.customEntryButton.contains(locationOfGesture) { //Custom Entry Button was tapped
                h2Oscene.customEntryButton.highlighted = true
                
                presentController(withName: "CustomEntryInterfaceController", context: self)
            }
            
            delay(delay: 0.1, closure: { //Only way to get highlight working is to perform the delay this way. Normal highlighted taps are not available like UIButtons.
                self.h2Oscene.entryButton1.highlighted = false
                self.h2Oscene.entryButton2.highlighted = false
                self.h2Oscene.entryButton3.highlighted = false
                self.h2Oscene.customEntryButton.highlighted = false
            })
        }
    }
}

//MARK: - Notifications
fileprivate extension MainInterfaceController {
    /// Animates the scene to the UI state while in the dock.
    @objc func switchToBackgroundState() {
        h2Oscene.switchSceneStyle(style: .dock)
        dismiss()
    }
    
    /// Animates the scene into a normal looking state when in the foreground.
    @objc func switchToForegroundState() {
        h2Oscene.switchSceneStyle(style: .normal)
    }
    
    /// When preset values have been changed, updates the UI to reflect the change.
    ///
    /// - parameter notification: Notification sent with user info containing preset values.
    @objc func presetValuesUpdated(notification :Notification) {
        let userInfo = notification.userInfo as! [String : [Float]]
        
        if let presets = userInfo[PresetValuesNotificationInfo] {
            h2Oscene.entryButton1.amount = presets[0]
            h2Oscene.entryButton2.amount = presets[1]
            h2Oscene.entryButton3.amount = presets[2]
        }
    }
    
    /// When goal value has been changed, updates the UI to reflect the change
    ///
    /// - parameter notification: Notification sent with user info containing goal value.
    @objc func goalValueUpdated(notification :Notification) {
        let amount = getWKExtensionDelegate().user?.amountOfWaterForToday()
        let userInfo = notification.userInfo as! [String : Float]
        if let goal = userInfo[GoalValueNotificationInfo] {
            updateFluidValue(current: amount!, goal :goal)
        }
    }
}
