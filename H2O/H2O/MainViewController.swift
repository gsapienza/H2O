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
    /// When an entry is made by tapping one of the preset buttons
    ///
    /// - parameter amount: Amount set in the preset
    func entryButtonTapped(amount :Float)
    
    ///  When the custom entry button is tapped
    ///
    /// - parameter customButton: Button that was tapped
    func customEntryButtonTapped(customButton :EntryButton)
}

class MainViewController: UIViewController {

    //MARK: - Public iVars
    
    /// Navigation bar to contain settings button
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    /// First Entry Button
    @IBOutlet weak var entryButton1: EntryButton!
    
    /// Second entry button
    @IBOutlet weak var entryButton2: EntryButton!
    
    /// Third entry button
    @IBOutlet weak var entryButton3: EntryButton!
    
    /// Custom value entry button
    @IBOutlet weak var customEntryButton: CustomEntryButton!
    
    /// Daily entry amount with dial to represent progress towards goal
    @IBOutlet weak var dailyEntryDial: DailyEntryDial!
    
    /// Image view for background gradient
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    /// Fluid view that can animate to indicate amount of water drank today
    @IBOutlet weak var fluidView: H2OFluidView!
    
    /// Blur view overlayed on top of the fluid view
    @IBOutlet weak var fluidBlurView: UIVisualEffectView!
    
    //MARK: - Private iVars
    
    private let motionManager = CMMotionManager()
    
    //MARK: - Internal iVars
    
    /// View for confetti to burst at when the user hit their goal
    internal var confettiArea :L360ConfettiArea!
    
    /// View that must be added as a subview when the custom button is tapped. Controls the entry of a custom value as well as the paths that animate the custom button to a new shape
    internal var customEntryView :CustomEntryView!
    
    /// User set water goal (readonly)
    internal var goal :Float {
        set{}
        get {
            return UserDefaults.standard.float(forKey: "GoalValue")
        }
    }
    
    /// Last frame set for the fluid view presentation layer. Set by its delegate when animating its position
    var lastFluidViewPresentationLayerFrame :CGRect?
    
    /// Last frame set for the custom view droplet presentation layer. Set by its delegate when animating its position
    var lastCustomViewDropletPresentationLayerFrame :CGRect?
    
    /// Determines whether we want something to happen when the custom view water droplet meets the water liquid view when it drops
    var monitoringCustomViewDropletMovements = false
    
    //MARK: - View Setup

    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = StandardColors.backgroundColor
        
        if AppDelegate.isDarkModeEnabled() {
            backgroundImageView.image = UIImage(named: "DarkModeBackground")
        } else {
            backgroundImageView.image = UIImage(named: "LightModeBackground")
        }
        
        configureNavigationBar()
        configureSettingsBarButton()
        configureFluidView()
        configurePresetEntryCircles()
        configureBlurView()
        configureDailyEntryDial()
        
        confettiArea = generateConfettiView()
        
        //If the date changes while the app is open this timer will update the UI to reflect daily changes
        let newDateTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(MainViewController.updateTimeRelatedItems), userInfo: nil, repeats: true)
        RunLoop.current.add(newDateTimer, forMode: RunLoopMode.commonModes)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        customEntryView = generateCustomEntryView()
        
        layout()
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    private func layout() {
        //---Confetti Area---
        view.addSubview(confettiArea)
        
        confettiArea.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: confettiArea, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: confettiArea, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: confettiArea, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: confettiArea, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))
        
        //---Custom Entry View---
        customEntryView.frame = view.bounds
        
        view.insertSubview(customEntryView, aboveSubview: fluidView)
    }
    
    //MARK: - Internal
    
    /// Toggles all views on screen with a fancy animation. If false the subviews scale in otherwise they scale out
    ///
    /// - parameter hide: Should the views be hiddden
    internal func toggleViewControllerViews( hide :Bool) {
        //Original values
        var scale = CGAffineTransform(scaleX: 1, y: 1)
        var alpha :CGFloat = 1
        
        if hide { //If you want to hide them instead
            scale = CGAffineTransform(scaleX: 0.00001, y: 0.00001)
            alpha = 0
        }
        
        //Animations happen here
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.entryButton1.transform = scale
            self.entryButton1.alpha = alpha
            
            self.entryButton2.transform = scale
            self.entryButton2.alpha = alpha

            self.entryButton3.transform = scale
            self.entryButton3.alpha = alpha

            self.customEntryButton.transform = scale
            self.customEntryButton.alpha = alpha

            self.dailyEntryDial.transform = scale
            self.dailyEntryDial.alpha = alpha
            
        }) { (Bool) in
        }
    }
    
    ///Called via timer to check if the day has changed while the app is opened and UI elements need updating
    internal func updateTimeRelatedItems() {
        dailyEntryDial.updateAmountOfWaterDrankToday(animated: true)
        updateFluidValue()
    }
    
    ///Updates the height of the fluid value by getting the ratio of amount of water drank and goal
    internal func updateFluidValue() {
        var newFillValue :Float = Float((dialEntryCurrentValue() / goal) * 1.0) //New ratio
        
        delay(delay: 0.2) { //Aesthetic delay
            self.fluidView.fillTo(&newFillValue) //New fill value 0-1
            //self.fluidView.startTiltAnimation() //Set up for core motion movement
        }
    }
}

// MARK: - Private Generators
private extension MainViewController {
    /// Generates a confetti view
    ///
    /// - returns: Confetti view
    func generateConfettiView() -> L360ConfettiArea {
        let view = L360ConfettiArea()
        
        view.isUserInteractionEnabled = false
        
        return view
    }
    
    /// Generates a custom entry view for path animations
    ///
    /// - returns: Custom entry view to overlay this view and perform path animations
    func generateCustomEntryView() -> CustomEntryView {
        let view = CustomEntryView()
        
        view.customButtonFrame = customEntryButton.frame
        view.customButtonCornerRadius = customEntryButton.layer.cornerRadius
        view.circleDialFrame = dailyEntryDial.frame
        view.circleDialCornerRadius = dailyEntryDial.bounds.width / 2
        view.dropletAtBottomFrame = CGRect(x: dailyEntryDial.frame.origin.x, y: self.view.frame.height, width: dailyEntryDial.frame.width, height: dailyEntryDial.frame.height)
        view.delegate = self
        
        return view
    }
}

// MARK: - Private View Configurations
private extension MainViewController {
    /// Configures the view controllers navigation bar
    func configureNavigationBar() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        navigationBar.backgroundColor = UIColor.clear
    }
    
    /// Configures the settings button for the navigation bar
    func configureSettingsBarButton() {
        let navigationItem = UINavigationItem()
        
        let settingsBarButtonItem = UIBarButtonItem(image: UIImage(named: "SettingsBarButtonItem"), style: .plain, target: self, action: #selector(self.onSettingsBarButton(_:)))
        settingsBarButtonItem.tintColor = StandardColors.primaryColor
        
        navigationItem.rightBarButtonItem = settingsBarButtonItem
        
        navigationBar.items = [navigationItem]
    }
    
    /// Configures the fluid view in background
    func configureFluidView() {
        fluidView.fillColor = StandardColors.waterColor //Water fill
        fluidView.fillDuration = 1.1 //New duration of height animations
        fluidView.h2OFluidViewDelegate = self
        
        updateFluidValue() //Update the fluid value to get a new height
    }
    
    /// Configures blur view overlaying the in fluid view
    func configureBlurView() {
        if AppDelegate.isDarkModeEnabled() {
            fluidBlurView.effect = UIBlurEffect(style: .dark)
        } else {
            fluidBlurView.effect = UIBlurEffect(style: .light)
        }
    }
    
    /// Configures the preset buttons
    func configurePresetEntryCircles() {
        let presetWaterValues = UserDefaults.standard.array(forKey: "PresetWaterValues") as! [Float]
        
        //First button
        entryButton1.amount = presetWaterValues[0]
        entryButton1.delegate = self
        
        //Second button
        entryButton2.amount = presetWaterValues[1]
        entryButton2.delegate = self
        
        //Third button
        entryButton3.amount = presetWaterValues[2]
        entryButton3.delegate = self
        
        //Custom button
        customEntryButton.delegate = self
    }
    
    /// Configures the daily entry of water dial
    func configureDailyEntryDial() {
        dailyEntryDial.delegate = self
    }
}

// MARK: - Target Actions
internal extension MainViewController {
    /// Adds water to user by using presets, custom amount or other means
    ///
    /// - parameter amount: Amount of water in fl oz
    func addWaterToToday( amount :Float) {
        let beforeAmount = getAppDelegate().user?.amountOfWaterForToday() //Water drank before entering this latest entry
        
        //Celebration if the user hit their goal. Determines if the the user wasnt at their goal before the entry but now is with the new amount about to be added
        if beforeAmount! < goal && beforeAmount! + amount >= goal {
            confettiArea.burst(at: dailyEntryDial.center, confettiWidth: 15, numberOfConfetti: 50)
            AudioToolbox.standardAudioToolbox.playAudio("Well done", fileExtension: "wav", repeatEnabled: false)
            ToastNotificationManager.postToastNotification("Congratulations! You drank \(Int(goal))" + standardUnit.rawValue + " of water today.", color: StandardColors.standardGreenColor, image: nil, completionBlock: {
            })
        } else {
            ToastNotificationManager.postToastNotification("\(Int(amount))" + standardUnit.rawValue + " added", color: StandardColors.waterColor, image: UIImage(named: "Check"), completionBlock: {
            })
        }
        
        getAppDelegate().user!.addNewEntryToUser(amount, date: nil)
        
        dailyEntryDial.updateAmountOfWaterDrankToday(animated: true) //Updates the daily dial
        updateFluidValue()
        
        HealthManager.defaultManager.saveWaterAmountToHealthKit(amount, date: Date())
    }
    
    /// Settings bar button was tapped
    ///
    /// - parameter sender: Settings bar button
    @IBAction func onSettingsBarButton(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationViewController = (storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! UINavigationController)
        
        let settingsViewController = navigationViewController.viewControllers.first as! SettingsViewController
        settingsViewController.delegate = self
        
        self.present(navigationViewController, animated: true, completion: nil)
    }
    
    ///When the cancel bar button is tapped when the custom entry view is present
    func onCancelCustomEntryBarButton() {
        var newFillValue :Float = Float((dialEntryCurrentValue() / goal) * 1.0) //New ratio
        fluidView.fillTo(&newFillValue) //Refill water up after tapping the custom button makes the fill value 0
        
        AudioToolbox.standardAudioToolbox.playAudio("Alert Error", fileExtension: "wav", repeatEnabled: false)
        
        configureSettingsBarButton() //Restore settings button
        
        
        customEntryView.animateFromDialCirclePathToCustomButtonPath { (Bool) in
            //self.customEntryView.removeFromSuperview()
        }
        
        toggleViewControllerViews(hide: false) //Show all views on screen
    }
    
    ///When the done bar button is tapped when the custom entry view is present
    func onDoneCustomEntryBarButton() {
        if customEntryView.amountTextField.text != "" { //If the text field is not blank
            monitoringCustomViewDropletMovements = true
            
            configureSettingsBarButton() //Restore settings button
            
            let amount = NumberFormatter().number(from: customEntryView.amountTextField.text!)!.floatValue
            addWaterToToday(amount: amount)
            
            customEntryView.animateToDropletPathAndDrop(completionHandler: { (Bool) in
                delay(delay: 0.5, closure: {
                    self.toggleViewControllerViews(hide: false) //Show all views on screen
                })
            })
            
        } else {
            AudioToolbox.standardAudioToolbox.playAudio("Alert Error", fileExtension: "wav", repeatEnabled: false)
            
            customEntryView.invalidEntry()
            ToastNotificationManager.postToastNotification("Custom Amount Cannot Be Empty", color: StandardColors.standardRedColor, image: nil, completionBlock: {
            })
        }
    }
}

// MARK: - EntryButtonDelegate
extension MainViewController :EntryButtonProtocol {
    /// When an entry button is tapped and a new amount of water is added to today
    ///
    /// - parameter amount: Amount to add in fl oz
    func entryButtonTapped( amount: Float) {
        addWaterToToday(amount: amount)
    }
    
    /// When the custom entry button is tapped. Creates a new entry view
    ///
    /// - parameter customButton: Button that was tapped
    func customEntryButtonTapped( customButton :EntryButton) {
        var fillPercentage :Float = 0
        fluidView.fillTo(&fillPercentage) //Make the fill value 0 to better show the custom entry circle. When cancel or done is tapped, the fill will go back to current value of water that was drank
        
        customEntryView.animateFromCustomButtonPathToCirclePath { (Bool) in
        }
        
        toggleViewControllerViews(hide: true) //Hide all other views on screen
        
        //Navigation bar setup for controlling custom entry
        
        let cancelBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(MainViewController.onCancelCustomEntryBarButton))
        
        cancelBarButton.setTitleTextAttributes([NSForegroundColorAttributeName: StandardColors.standardRedColor, NSFontAttributeName: StandardFonts.regularFont(size: 18)], for: UIControlState()) //Cancel button view properties
        
        let doneBarButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(MainViewController.onDoneCustomEntryBarButton))
        
        doneBarButton.setTitleTextAttributes([NSForegroundColorAttributeName: StandardColors.waterColor, NSFontAttributeName: StandardFonts.boldFont(size: 18)], for: UIControlState()) //Done button view properties
        
        let navigationItem = UINavigationItem()
        navigationItem.leftBarButtonItem = cancelBarButton
        navigationItem.rightBarButtonItem = doneBarButton
        
        navigationBar.items = [navigationItem]
    }
}

// MARK: - SettingsViewControllerProtocol
extension MainViewController :SettingsViewControllerProtocol {
    /// Called when the goal value has been updated
    ///
    /// - parameter newValue: New goal set
    func goalUpdated(newValue: Float) {
        dailyEntryDial.updateAmountOfWaterDrankToday(animated: true)
        updateFluidValue()
    }
    
    /// When one of the presets values has been updated
    ///
    /// - parameter presetSize: Size of preset to update
    /// - parameter newValue:    New value for preset
    func presetUpdated( presetSize: PresetSize, newValue: Float) {
        switch presetSize {
        case .small:
            entryButton1.amount = newValue
        case .medium:
            entryButton2.amount = newValue
        case .large:
            entryButton3.amount = newValue
        }
    }
}

// MARK: - DailyEntryDialProtocol
extension MainViewController :DailyEntryDialProtocol {
    func dialEntryCurrentValue() -> Float {
        return (getAppDelegate().user?.amountOfWaterForToday())!
    }
    
    func dailyEntryDialGoal() -> Float {
        return goal
    }
    
    func dailyEntryDialButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let informationViewController = (storyboard.instantiateViewController(withIdentifier: "InformationViewController") as! InformationViewController) //Get the view controller
        
        informationViewController.informationViewControllerDelegate = self //Delegate to listen for events like deletion
        informationViewController.setupPopsicle() //Push the view controller up like a modal controller
    }
}

// MARK: - InformationViewControllerProtocol
extension MainViewController :InformationViewControllerProtocol {
    func entryWasDeleted( dateOfEntry :Date) {
        dailyEntryDial.updateAmountOfWaterDrankToday(animated: true)
        updateFluidValue()
        
        HealthManager.defaultManager.deleteWaterEntry(dateOfEntry)
    }
    
    func informationViewControllerGoal() -> Float {
        return goal
    }
}

// MARK: - H2OFluidViewProtocol
extension MainViewController :H2OFluidViewProtocol {
    func fluidViewLayerDidUpdate(fluidView: GSAnimatingProgressLayer) {
        lastFluidViewPresentationLayerFrame = self.fluidView.liquidLayer.presentation()?.frame
    }
}

// MARK: - CustomEntryViewProtocol
extension MainViewController :CustomEntryViewProtocol {
    func dropletLayerDidUpdate(layer: GSAnimatingProgressLayer) {
        
        
        lastCustomViewDropletPresentationLayerFrame = customEntryView.dropletShapeLayer.presentation()!.path?.boundingBoxOfPath
        
        guard lastFluidViewPresentationLayerFrame != nil && lastCustomViewDropletPresentationLayerFrame != nil else {
            return
        }
        
        if (lastFluidViewPresentationLayerFrame?.intersects(lastCustomViewDropletPresentationLayerFrame!))! && monitoringCustomViewDropletMovements {
            AudioToolbox.standardAudioToolbox.playAudio("Water", fileExtension: "wav", repeatEnabled: false)
            monitoringCustomViewDropletMovements = false
//            fluidView.maxAmplitude = 100
//            fluidView.minAmplitude = 20
//            fluidView.amplitudeIncrement = 20
//            fluidView.phaseShiftDuration = 0.55
//            fluidView.updateAmplitudeArray()
        }
    }
}
