//
//  ViewController.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/16/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit
import CoreMotion

protocol EntryButtonProtocol {
    /**
     When an entry is made by tapping one of the preset buttons
     
     - parameter amount: Amount set in the preset
     */
    func entryButtonTapped(amount :Float)
    
    /**
     When the custom entry button is tapped
     
     - parameter customButton: Button that was tapped
     */
    func customEntryButtonTapped(customButton :EntryButton)
}

class MainViewController: UIViewController {

        /// Navigation bar to contain settings button
    @IBOutlet weak var _navigationBar: UINavigationBar!
    
        /// First Entry Button
    @IBOutlet weak var _entryButton1: EntryButton!
    
        /// Second entry button
    @IBOutlet weak var _entryButton2: EntryButton!
    
        /// Third entry button
    @IBOutlet weak var _entryButton3: EntryButton!
    
        /// Custom value entry button
    @IBOutlet weak var _customEntryButton: CustomEntryButton!
    
        /// Daily entry amount with dial to represent progress towards goal
    @IBOutlet weak var _dailyEntryDial: DailyEntryDial!
    
        /// Fluid view that can animate to indicate amount of water drank today
    @IBOutlet weak var _fluidView: BAFluidView!
    
        /// Blur view overlayed on top of the fluid view
    @IBOutlet weak var _fluidBlurView: UIVisualEffectView!
    
        /// View that must be added as a subview when the custom button is tapped. Controls the entry of a custom value as well as the paths that animate the custom button to a new shape
    var _customEntryView = CustomEntryView()
    
        /// View for confetti to burst at when the user hit their goal
    var _confettiArea = L360ConfettiArea()
    
    let _motionManager = CMMotionManager()
    
    //MARK: - Setup functions
    
    /**
     Basic setup helper functions
     */
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = StandardColors.backgroundColor
        _customEntryView = CustomEntryView(frame: view.bounds)
        
        setupNavigationBar()
        setupFluidView()
        setupPresetEntryCircles()
        setupSettingsBarButton()
        setupConfettiArea()
        setupBlurView()
        
        _dailyEntryDial._delegate = self
        
        //If the date changes while the app is open this timer will update the UI to reflect daily changes
        let newDateTimer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: #selector(MainViewController.updateTimeRelatedItems), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(newDateTimer, forMode: NSRunLoopCommonModes)
    }

    /**
     Sets up navigation bar state by making it fully transparent
     */
    private func setupNavigationBar() {
        _navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        _navigationBar.shadowImage = UIImage()
        _navigationBar.translucent = true
        _navigationBar.backgroundColor = UIColor.clearColor()
    }

    /**
     Sets up fluid view to indicate how much water the user has drank. Animates up on first launch
     */
    private func setupFluidView() {
        _fluidView.fillColor = StandardColors.waterColor //Water fill
        _fluidView.fillDuration = 2 //New duration of height animations
        
        if _motionManager.deviceMotionAvailable {
            _motionManager.deviceMotionUpdateInterval = 0.3
            _motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (data :CMDeviceMotion?, error :NSError?) in
                let userInfo = NSDictionary(object: data!, forKey: "data")
                
                NSNotificationCenter.defaultCenter().postNotificationName(kBAFluidViewCMMotionUpdate, object: nil, userInfo: userInfo as [NSObject : AnyObject])
            })
        }
        
        updateFluidValue() //Update the fluid value to get a new height
    }
    
    /**
     Sets up the blur view on top of the fluid view for aesthetic purposes
     */
    private func setupBlurView() {
        if AppDelegate.isDarkModeEnabled() {
            _fluidBlurView.effect = UIBlurEffect(style: .Dark)
        } else {
            _fluidBlurView.effect = UIBlurEffect(style: .Light)
        }
    }
    
    /**
     Sets up 3 preset circles
     */
    private func setupPresetEntryCircles() {
        let presetWaterValues = NSUserDefaults.standardUserDefaults().arrayForKey("PresetWaterValues") as! [Float]
        
        //First button
        _entryButton1._amount = presetWaterValues[0]
        _entryButton1._delegate = self
        
        //Second button
        _entryButton2._amount = presetWaterValues[1]
        _entryButton2._delegate = self

        //Third button
        _entryButton3._amount = presetWaterValues[2]
        _entryButton3._delegate = self
        
        //Custom button
        _customEntryButton._delegate = self
    }
    
    /**
     Navigation bar setup when the settings button is needed
     */
    private func setupSettingsBarButton() {
        let navigationItem = UINavigationItem()
        
        let settingsBarButtonItem = UIBarButtonItem(image: UIImage(named: "SettingsBarButtonItem"), style: .Plain, target: self, action: #selector(MainViewController.onSettingsBarButton(_:)))
        settingsBarButtonItem.tintColor = StandardColors.primaryColor
        
        navigationItem.rightBarButtonItem = settingsBarButtonItem
        
        self._navigationBar.items = [navigationItem]
    }
    
    /**
     Sets up the area for confetti when the user hit their goal 🎊
     */
    private func setupConfettiArea() {
        view.addSubview(_confettiArea)
        
        _confettiArea.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: _confettiArea, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: _confettiArea, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: _confettiArea, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: _confettiArea, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))
        
        _confettiArea.userInteractionEnabled = false
    }
    
    //MARK: - Actions
    
    /**
     Adds water to user by using presets, custom amount or other means
     
     - parameter amount: Amount of water in fl oz
     */
    func addWaterToToday(amount :Float) {
        let beforeAmount = AppDelegate.getAppDelegate().user?.getAmountOfWaterForToday() //Water drank before entering this latest entry
        
        //Celebration if the user hit their goal. Determines if the the user wasnt at their goal before the entry but now is with the new amount about to be added
        if beforeAmount! < getGoal() && beforeAmount! + amount >= getGoal() {
            _confettiArea.burstAt(_dailyEntryDial.center, confettiWidth: 15, numberOfConfetti: 50)
            CENAudioToolbox.standardAudioToolbox.playAudio("Well done", fileExtension: "wav", repeatEnabled: false)
            CENToastNotificationManager.postToastNotification("Congratulations! You drank \(Int(getGoal()))" + Constants.standardUnit.rawValue + " of water today.", color: StandardColors.standardGreenColor, image: nil, completionBlock: {
            })
        } else {
            CENToastNotificationManager.postToastNotification("\(Int(amount))" + Constants.standardUnit.rawValue + " added", color: StandardColors.waterColor, image: UIImage(named: "Check"), completionBlock: {
            })
        }
        
        AppDelegate.getAppDelegate().user!.addNewEntryToUser(amount, date: nil)
        
        _dailyEntryDial.updateAmountOfWaterDrankToday(true) //Updates the daily dial
        updateFluidValue()
        
        HealthManager.defaultManager.saveWaterAmountToHealthKit(amount, date: NSDate())
    }
    
    /**
     Settings bar button was tapped
     
     - parameter sender: Settings bar button
     */
    @IBAction func onSettingsBarButton(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationViewController = (storyboard.instantiateViewControllerWithIdentifier("SettingsViewController") as! UINavigationController)
        
        let settingsViewController = navigationViewController.viewControllers.first as! SettingsViewController
        settingsViewController._delegate = self
        
        self.presentViewController(navigationViewController, animated: true, completion: nil)
    }
    
    /**
     When the cancel bar button is tapped when the custom entry view is present
     */
    func onCancelCustomEntryBarButton() {
        CENAudioToolbox.standardAudioToolbox.playAudio("Alert Error", fileExtension: "wav", repeatEnabled: false)
        
        setupSettingsBarButton() //Restore settings button

        _customEntryView.morphToCustomButtonPath { (Bool) in //Make the entry circle look like the custom button outline again
            self._customEntryView.removeFromSuperview()
        }
        
        toggleViewControllerViews(false) //Show all views on screen
    }
    
    /**
     When the done bar button is tapped when the custom entry view is present
     */
    func onDoneCustomEntryBarButton() {
        if _customEntryView._amountTextField.text != "" { //If the text field is not blank
            CENAudioToolbox.standardAudioToolbox.playAudio("Pop_A", fileExtension: "wav", repeatEnabled: false)
            
            setupSettingsBarButton() //Restore settings button
            
            let amount = NSNumberFormatter().numberFromString(_customEntryView._amountTextField.text!)!.floatValue
            addWaterToToday(amount)
            
            _customEntryView.morphToDropletPath { (Bool) in
                self._customEntryView.removeFromSuperview()
            }
            
            toggleViewControllerViews(false) //Show all views on screen
        } else {
            CENAudioToolbox.standardAudioToolbox.playAudio("Alert Error", fileExtension: "wav", repeatEnabled: false)
            
            _customEntryView.invalidEntry()
            CENToastNotificationManager.postToastNotification("Custom Amount Cannot Be Empty", color: StandardColors.standardRedColor, image: nil, completionBlock: {
            })
        }
    }
    
    /**
     Toggles all views on screen with a fancy animation. If false the subviews scale in otherwise they scale out    
     
     - parameter hide: Should the views be hiddden
     */
    private func toggleViewControllerViews(hide :Bool) {
        //Original values
        var scale = CGAffineTransformMakeScale(1, 1)
        var alpha :CGFloat = 1
        
        if hide { //If you want to hide them instead
            scale = CGAffineTransformMakeScale(0.00001, 0.00001)
            alpha = 0
        }
        
        //Animations happen here
        UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseIn, animations: {
            self._entryButton1.transform = scale
            self._entryButton1.alpha = alpha
            
            self._entryButton2.transform = scale
            self._entryButton2.alpha = alpha

            self._entryButton3.transform = scale
            self._entryButton3.alpha = alpha

            self._customEntryButton.transform = scale
            self._customEntryButton.alpha = alpha

            self._dailyEntryDial.transform = scale
            self._dailyEntryDial.alpha = alpha
            
        }) { (Bool) in
        }
    }
    
    /**
     Called via timer to check if the day has changed while the app is opened and UI elements need updating
     */
    func updateTimeRelatedItems() {
        _dailyEntryDial.updateAmountOfWaterDrankToday(true)
        updateFluidValue()
    }
    
    /**
     Updates the height of the fluid value by getting the ratio of amount of water drank and goal
     */
    private func updateFluidValue() {
        let newFillValue :CGFloat = CGFloat((getAmountOfWaterEnteredToday() / getGoal()) * 0.9) //New ratio
        
        AppDelegate.delay(0.2) { //Aesthetic delay
            self._fluidView.fillTo(newFillValue) //New fill value 0-1
            self._fluidView.startAnimation() //Starts the animation
            self._fluidView.startTiltAnimation() //Set up for core motion movement
        }
    }
}

// MARK: - EntryButtonDelegate
extension MainViewController :EntryButtonProtocol {
    /**
     When an entry button is tapped and a new amount of water is added to today
     
     - parameter amount: Amount to add in fl oz
     */
    func entryButtonTapped(amount: Float) {
        addWaterToToday(amount)
    }
    
    /**
     When the custom entry button is tapped. Creates a new entry view
     
     - parameter customButton: Button that was tapped
     */
    func customEntryButtonTapped(customButton :EntryButton) {
        view.addSubview(_customEntryView)
        
        _customEntryView.setupStartingPathInFrame(customButton.frame, cornerRadius :customButton.layer.cornerRadius) //Setup the custom button looking path
        
        _customEntryView.morphToCirclePath(_dailyEntryDial.frame, cornerRadius :_dailyEntryDial.frame.width / 2) //Animate the custom button looking path to the circle where input happens. Circle frame is based on the dailyEntryDialFrame
        
        toggleViewControllerViews(true) //Hide all other views on screen
        
        //Navigation bar setup for controlling custom entry
        
        let cancelBarButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(MainViewController.onCancelCustomEntryBarButton))
        
        cancelBarButton.setTitleTextAttributes([NSForegroundColorAttributeName: StandardColors.standardRedColor, NSFontAttributeName: StandardFonts.regularFont(18)], forState: .Normal) //Cancel button view properties
        
        let doneBarButton = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(MainViewController.onDoneCustomEntryBarButton))
        
        doneBarButton.setTitleTextAttributes([NSForegroundColorAttributeName: StandardColors.waterColor, NSFontAttributeName: StandardFonts.boldFont(18)], forState: .Normal) //Done button view properties
        
        let navigationItem = UINavigationItem()
        navigationItem.leftBarButtonItem = cancelBarButton
        navigationItem.rightBarButtonItem = doneBarButton
        
        _navigationBar.items = [navigationItem]
    }
}

// MARK: - SettingsViewControllerProtocol
extension MainViewController :SettingsViewControllerProtocol {
    /**
     Called when the goal value has been updated
     
     - parameter newValue: New goal set
     */
    func goalUpdated(newValue: Float) {
        _dailyEntryDial.updateAmountOfWaterDrankToday(true)
        updateFluidValue()
    }
    
    /**
     When one of the presets values has been updated
     
     - parameter presetSize: Size of preset to update
     - parameter newValue:     New Value for preset
     */
    func presetUpdated(presetSize: PresetSize, newValue: Float) {
        switch presetSize {
        case .Small:
            _entryButton1._amount = newValue
        case .Medium:
            _entryButton2._amount = newValue
        case .Large:
            _entryButton3._amount = newValue
        }
    }
}

// MARK: - DailyEntryDialProtocol
extension MainViewController :DailyEntryDialProtocol {
    /**
     Retrieves the amount of water drank today from the database
     
     - returns: Amount of water drank today
     */
    func getAmountOfWaterEnteredToday() -> Float {
        return (AppDelegate.getAppDelegate().user?.getAmountOfWaterForToday())!
    }
    
    /**
     Determines the user set goal from NSUserDefaults
     
     - returns: Goal float value set by user
     */
    func getGoal() -> Float {
        return NSUserDefaults.standardUserDefaults().floatForKey("GoalValue")
    }
    
    /**
     Called when the dial button has been tapped and brings up the information view controller as a popsicle so the blur view has a background
     */
    func dialButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let informationViewController = (storyboard.instantiateViewControllerWithIdentifier("InformationViewController") as! InformationViewController) //Get the view controller
        
        informationViewController.setupPopsicle() //Push the view controller up like a modal controller
        informationViewController._informationViewControllerDelegate = self //Delegate to listen for events like deletion
    }
}

// MARK: - InformationViewControllerProtocol
extension MainViewController :InformationViewControllerProtocol {
    /**
     When an entry was deleted from the database. See if it effects the day dial view and delete from Health Kit Database
     
     - parameter dateOfEntry: Date that the entry was created
     */
    func entryWasDeleted(entryDate :NSDate) {
        _dailyEntryDial.updateAmountOfWaterDrankToday(true)
        updateFluidValue()
        
        HealthManager.defaultManager.deleteWaterEntry(entryDate)
    }
}
