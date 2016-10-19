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
        if let _goal = AppUserDefaults.getDailyGoalValue() {
            return _goal
        } else {
            return 0
        }
    }
    
    /// Last frame set for the fluid view presentation layer. Set by its delegate when animating its position
    var lastFluidViewPresentationLayerFrame :CGRect?
    
    /// Last frame set for the custom view droplet presentation layer. Set by its delegate when animating its position
    var lastCustomViewDropletPresentationLayerFrame :CGRect?
    
    /// Determines whether we want something to happen when the custom view water droplet meets the water liquid view when it drops
    var monitoringCustomViewDropletMovements = false
    
    //MARK: - Public

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAccessibility()
        addNotificationObservers()
    
        view.backgroundColor = StandardColors.backgroundColor
        
        if AppUserDefaults.getDarkModeEnabled() {
            backgroundImageView.image = UIImage(assetIdentifier: .darkModeBackground)
        } else {
            backgroundImageView.image = UIImage(assetIdentifier: .lightModeBackground)
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
        
        if traitCollection.forceTouchCapability == .available {
            self.registerForPreviewing(with: self, sourceView: dailyEntryDial)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        customEntryView = generateCustomEntryView()
        layout()
        indicateDialToOpenInformationViewController()
    }
    
    //MARK: - Private
    
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
    
    /// Adds notifications for view controller to observe.
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(configureAccessibility), name: Notification.Name.UIAccessibilityReduceMotionStatusDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(syncCompleted), name: SyncCompletedNotification, object: nil)
    }
    
    /// Makes the interface suitable for users who have certain accessibility features enabled.
    @objc private func configureAccessibility() {
        if UIAccessibilityIsReduceMotionEnabled() {
            fluidView.fluidLayout = GSFluidLayout(frame: view.bounds, fluidWidth: view.bounds.width * 3, fillDuration: 3, amplitudeIncrement: 1, maxAmplitude: 5, minAmplitude: 0, numberOfWaves: 2)
        } else {
            fluidView.fluidLayout = GSFluidLayout(frame: view.bounds, fluidWidth: view.bounds.width * 3, fillDuration: 3, amplitudeIncrement: 1, maxAmplitude: 40, minAmplitude: 5, numberOfWaves: 2)
        }
    }
    
    /// Refreshed view controller when a sync has been completed.
    @objc private func syncCompleted() {
        DispatchQueue.main.async {
            self.dailyEntryDial.updateAmountOfWaterDrankToday(animated: true)
            let currentAmount = getAppDelegate().user?.amountOfWaterForToday()
            self.updateFluidValue(current: currentAmount!)
        }
    }
    
    /// Checks whether the dial should animate to draw attention to itself by determining if the user had opened the information view controller once before.
    fileprivate func indicateDialToOpenInformationViewController() {
        if getAppDelegate().user?.entries?.count != 0 && !AppUserDefaults.getInformationViewControllerWasOpenedOnce() {
            dailyEntryDial.beatAnimation(toggle: true)
        }
    }
    
    /// Toggles all views on screen with a fancy animation. If false the subviews scale in otherwise they scale out
    ///
    /// - parameter hide: Should the views be hiddden
    fileprivate func toggleViewControllerViews(hide :Bool, completion :@escaping (Bool) -> Void) {
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
            
        }) { (complete :Bool) in
            completion(complete)
        }
    }
    
    //MARK: - Internal
    
    ///Called via timer to check if the day has changed while the app is opened and UI elements need updating
    func updateTimeRelatedItems() {
        dailyEntryDial.updateAmountOfWaterDrankToday(animated: true)
        let currentAmount = getAppDelegate().user?.amountOfWaterForToday()
        updateFluidValue(current: currentAmount!)
    }
    
    
    /// Updates the height of the fluid value by getting the ratio of amount of water drank and goal.
    ///
    /// - parameter currentValue: Current amount of water drank.
    func updateFluidValue(current :Float) {
        var newFillValue :Float = Float((current / goal) * 1.0) //New ratio
        
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
        
        let settingsBarButtonItem = UIBarButtonItem(image: UIImage(assetIdentifier: .settingsBarButtonItem), style: .plain, target: self, action: #selector(self.onSettingsBarButton(_:)))
        settingsBarButtonItem.tintColor = StandardColors.primaryColor
        
        navigationItem.rightBarButtonItem = settingsBarButtonItem
        
        navigationBar.items = [navigationItem]
    }
    
    /// Configures the fluid view in background
    func configureFluidView() {
        fluidView.liquidFillColor = StandardColors.waterColor //Water fill
        fluidView.h2OFluidViewDelegate = self
        
        let currentAmount = getAppDelegate().user?.amountOfWaterForToday()
        updateFluidValue(current: currentAmount!) //Update the fluid value to get a new height
    }
    
    /// Configures blur view overlaying the in fluid view
    func configureBlurView() {
        if AppUserDefaults.getDarkModeEnabled() {
            fluidBlurView.effect = UIBlurEffect(style: .dark)
        } else {
            fluidBlurView.effect = UIBlurEffect(style: .light)
        }
    }
    
    /// Configures the preset buttons
    func configurePresetEntryCircles() {
        if let presetWaterValues = AppUserDefaults.getPresetWaterValues() {
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
        
        //Celebration if the user hit their goal. Determines if the the user wasnt at their goal before the entry but now is with the new amount about to be added.
        if beforeAmount! < goal && beforeAmount! + amount >= goal {
            confettiArea.burst(at: dailyEntryDial.center, confettiWidth: 15, numberOfConfetti: 50)
            AudioToolbox.standardAudioToolbox.playAudio(WellDoneSound, repeatEnabled: false)
        }
        
        getAppDelegate().user!.addNewEntryToUser(amount, date: nil)

        dailyEntryDial.updateAmountOfWaterDrankToday(animated: true) //Updates the daily dial
        updateFluidValue(current: beforeAmount! + amount)
        
        HealthManager.defaultManager.saveWaterAmountToHealthKit(amount, date: Date())
        
        WatchConnection.standardWatchConnection.beginSync { ( replyHandler :[String : Any]) in
        }

        indicateDialToOpenInformationViewController()
    }
    
    /// Settings bar button was tapped
    ///
    /// - parameter sender: Settings bar button
    @IBAction func onSettingsBarButton(_ sender: AnyObject) {
        let navigationViewController :UINavigationController = UIStoryboard(storyboard: .Main).instantiateViewController()
        
        let settingsViewController = navigationViewController.viewControllers.first as! SettingsViewController
        settingsViewController.delegate = self
        
        self.present(navigationViewController, animated: true, completion: nil)
    }
    
    ///When the cancel bar button is tapped when the custom entry view is present
    func onCancelCustomEntryBarButton() {
        var newFillValue :Float = Float((dialEntryCurrentValue() / goal) * 1.0) //New ratio
        fluidView.fillTo(&newFillValue) //Refill water up after tapping the custom button makes the fill value 0
        
        AudioToolbox.standardAudioToolbox.playAudio(ErrorSound, repeatEnabled: false)
        
        configureSettingsBarButton() //Restore settings button
        
        
        customEntryView.animateFromDialCirclePathToCustomButtonPath { (Bool) in
            //self.customEntryView.removeFromSuperview()
        }
        
        //Show all views on screen
        toggleViewControllerViews(hide: false) { (complete :Bool) in
            self.indicateDialToOpenInformationViewController()
        }
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
                    //Show all views on screen
                    self.toggleViewControllerViews(hide: false) { (complete :Bool) in
                        self.indicateDialToOpenInformationViewController()
                    }
                })
            })
            
        } else {
            AudioToolbox.standardAudioToolbox.playAudio(ErrorSound, repeatEnabled: false)
            
            customEntryView.invalidEntry()
            ToastNotificationManager.postToastNotification(custom_amount_cannot_be_empty_toast_notification_localized_string, color: StandardColors.standardRedColor, image: nil, completionBlock: {
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
        
        //Hide all other views on screen.
        toggleViewControllerViews(hide: true) { (complete :Bool) in
        }
        
        //Navigation bar setup for controlling custom entry
        
        let cancelBarButton = UIBarButtonItem(title: cancel_navigation_item_localized_string, style: .plain, target: self, action: #selector(MainViewController.onCancelCustomEntryBarButton))
        
        cancelBarButton.setTitleTextAttributes([NSForegroundColorAttributeName: StandardColors.standardRedColor, NSFontAttributeName: StandardFonts.regularFont(size: 18)], for: UIControlState()) //Cancel button view properties
        
        let doneBarButton = UIBarButtonItem(title: done_navigation_item_localized_string, style: .plain, target: self, action: #selector(MainViewController.onDoneCustomEntryBarButton))
        
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
        let currentAmount = getAppDelegate().user?.amountOfWaterForToday()
        updateFluidValue(current: currentAmount!)
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
        AppUserDefaults.setInformationViewControllerWasOpenedOnce(openedOnce: true) //Set the information view controller opened user default value so that the dial will not animate to indicate that the user should tap the dial.
        
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
        
        let informationViewController :InformationViewController = UIStoryboard(storyboard: .Main).instantiateViewController() //Get the view controller
        
        informationViewController.informationViewControllerDelegate = self //Delegate to listen for events like deletion
        informationViewController.setupPopsicle() //Push the view controller up like a modal controller
    }
}

// MARK: - InformationViewControllerProtocol
extension MainViewController :InformationViewControllerProtocol {
    func entryWasDeleted( dateOfEntry :Date) {
        dailyEntryDial.updateAmountOfWaterDrankToday(animated: true)
        let currentAmount = getAppDelegate().user?.amountOfWaterForToday()
        updateFluidValue(current: currentAmount!)
        
        HealthManager.defaultManager.deleteWaterEntry(dateOfEntry)
        
        WatchConnection.standardWatchConnection.beginSync { (replyHandler :[String : Any]) in
        }
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
            AudioToolbox.standardAudioToolbox.playAudio(WaterSound, repeatEnabled: false)
            monitoringCustomViewDropletMovements = false
//            fluidView.maxAmplitude = 100
//            fluidView.minAmplitude = 20
//            fluidView.amplitudeIncrement = 20
//            fluidView.phaseShiftDuration = 0.55
//            fluidView.updateAmplitudeArray()
        }
    }
}

extension MainViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let viewController :InformationViewController = UIStoryboard(storyboard: .Main).instantiateViewController()
        viewController.informationViewControllerDelegate = self //Delegate to listen for events like deletion

        viewController.preferredContentSize = CGSize(width: 0, height: 0)
        
        return viewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}