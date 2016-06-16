//
//  AppDelegate.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/16/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

@UIApplicationMain
public class AppDelegate: UIResponder, UIApplicationDelegate {

    public var window: UIWindow?
    private var _user :User?
    
    var user :User? {
        set {}
        get {
            return _user
        }
    }
    
    /**
     Are test cases currently running based on the APP_IS_RUNNING_TEST environment variable
     
     - returns: true if test cases are running
     */
    class func isRunningTest() -> Bool {
        let environment = ProcessInfo.processInfo().environment
        
        let isRunningTest = environment["APP_IS_RUNNING_TEST"]
        
        if isRunningTest == "YES" {
            return true
        } else {
            return false
        }
    }

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        setPresets()
        setGoal()
        setDefaultTheme()
        
        AppDelegate.createShortcuts() //Creates 3D touch shortcuts
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient) //Wont pause music in the background anymore. Instead plays sounds in the background
        
        _user = User.loadUser() //Loads user data from database
        
        checkToSwitchThemes() //Check theme status on launch if automatic theme change is enabled
        
        //Set a timer to check the theme status so that if the app is open when the time changes, the theme will change
        let automaticThemeSwitcherTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(AppDelegate.checkToSwitchThemes), userInfo: nil, repeats: true)
        RunLoop.current().add(automaticThemeSwitcherTimer, forMode: RunLoopMode.commonModes)
        
        return true
    }
    
    /**
     Called when 3D touch icon shortcut is tapped
     */
    public func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        let mainViewController = window?.rootViewController as! MainViewController
        let presets = UserDefaults.standard().array(forKey: "PresetWaterValues") as! [Float]
        
        AppDelegate.delay(0.2) { //Delay is for aesthetic purposes although required for the custom entry to get the view loaded first before drawing its paths
            switch shortcutItem.type {
            case "com.theoven.H2O.smallPresetEntry": //First preset
                mainViewController.addWaterToToday(presets[0])
            case "com.theoven.H2O.mediumPresetEntry": //Second preset
                mainViewController.addWaterToToday(presets[1])
            case "com.theoven.H2O.largePresetEntry": //Third preset
                mainViewController.addWaterToToday(presets[2])
            case "com.theoven.H2O.customEntry": //Custom entry
                mainViewController.customEntryButtonTapped(mainViewController._customEntryButton)
            default:
                return
            }
        }
    }
    
    public func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    public func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    public func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    public func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    public func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    //MARK: - Default Settings
    
    /**
     Sets default preset values if none exist
     */
    private func setPresets() {
        let presetWaterValuesString = "PresetWaterValues"
        guard UserDefaults.standard().array(forKey: presetWaterValuesString) != nil else {
            let presets :[Float] = [8.0, 17.0, 23.0]
            UserDefaults.standard().set(presets, forKey: presetWaterValuesString)
            UserDefaults.standard().synchronize()
            
            return
        }
    }
    
    /**
     Sets default goal value if none exists
     */
    private func setGoal() {
        let goalValueString = "GoalValue"
        guard UserDefaults.standard().float(forKey: goalValueString) != 0 else {
            let goal :Float = 87.0
            UserDefaults.standard().set(goal, forKey: goalValueString)
            
            return
        }
    }
    
    /**
     Sets default theme value if none exist
     */
    private func setDefaultTheme() {
        let themeString = "DarkMode"
        guard UserDefaults.standard().string(forKey: themeString) != nil else {
            let theme = "YES"
            UserDefaults.standard().set(theme, forKey: themeString)
            
            return
        }
    }
    
    //MARK: - Theme Management
    
    /**
     Checks the time of day and changes the theme if automatic theme change is enabled and if it is not set correctly based on current time of day. 6AM - 6PM is light mode and 6PM to 6AM is dark mode
     */
    func checkToSwitchThemes() {
        let automaticThemeChangeEnabled = UserDefaults.standard().bool(forKey: "AutomaticThemeChange") //Get automatic status of automatic theme change
        
        if automaticThemeChangeEnabled {
            let calendar = Calendar.current() //Calendar type
            
            let currentDateComponents = calendar.components([.hour], from: Date()) //Components for the current day to get hour and minutes to see if it is appropriate to change themes
            
            if currentDateComponents.hour > 5 && currentDateComponents.hour < 18 { //If between 6AM and 6PM
                if AppDelegate.isDarkModeEnabled() { //If dark mode is enabled
                    AppDelegate.toggleDarkMode(false) //Activate light mode
                    NotificationCenter.default().post(name: Notification.Name(rawValue: "DarkModeToggled"), object: nil) //Update view controllers
                }
            } else { //If its between 6PM and 6AM
                if !AppDelegate.isDarkModeEnabled() { //If light mode is enabled
                    AppDelegate.toggleDarkMode(true) //Activate dark mode
                    NotificationCenter.default().post(name: Notification.Name(rawValue: "DarkModeToggled"), object: nil) //Update viewcontrollers
                }
            }
        }
    }
    
    /**
     Reloads a view controller from scratch including all views, subviews and the status bar. Used when theme changing
     
     - parameter viewController: View controller to reload
     */
    class func reloadViewController(_ viewController :UIViewController) {
        viewController.viewDidLoad()
        viewController.viewWillAppear(true)
        viewController.viewDidAppear(true)
        viewController.setNeedsStatusBarAppearanceUpdate() //Refresh status bar
        AppDelegate.reloadSubviews(viewController.view) //Refresh views
    }
    
    /**
     Reloads all subviews and their subviews
     
     - parameter view: Root view in view controller
     */
    private class func reloadSubviews(_ view :UIView) {
        for subview in view.subviews {
            subview.setNeedsLayout()
            subview.setNeedsDisplay()
            subview.awakeFromNib()
            
            reloadSubviews(subview)
        }
    }
    
    /**
     Function to tell is dark mode is enabled in NSUserDefaults
     
     - returns: Dark mode enabled status
     */
    class func isDarkModeEnabled() -> Bool {
        let darkModeEnabled = UserDefaults.standard().string(forKey: "DarkMode")
        
        if darkModeEnabled == "YES" {
            return true
        } else {
            return false
        }
    }
    
    /**
     Toggles dark mode in NSUserDefaults
     
     - parameter enabled: Dark mode on
     */
    class func toggleDarkMode(_ enabled :Bool) {
        var toggle = ""
        
        if enabled {
            toggle = "YES"
        } else {
            toggle = "NO"
        }
        
        UserDefaults.standard().set(toggle, forKey: "DarkMode")
    }
    
    // MARK: - Class functions
    
    ///- returns: Current AppDelegate
    class func getAppDelegate() -> AppDelegate {
        return (UIApplication.shared().delegate as? AppDelegate)!
    }
    
    /// Delays block of code from running by a specified amount of time
    ///- parameters:
    ///   - delay: Time to delay code from being ran
    class func delay(_ delay:Double, closure:()->()) {
        DispatchQueue.main.after(when: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { 
            closure()
        }
    }
    
    /**
     Creates dynamic 3D touch shortcuts to quick add water entries
     */
    class func createShortcuts() {
        let presets = UserDefaults.standard().array(forKey: "PresetWaterValues") as! [Float]
        
        let smallPresetShortcut = UIApplicationShortcutItem(type: "com.theoven.H2O.smallPresetEntry", localizedTitle: String(Int(presets[0])) + Constants.standardUnit.rawValue, localizedSubtitle: "", icon: UIApplicationShortcutIcon(templateImageName: "DarkSmallPresetImage"), userInfo: nil)
        
        let mediumPresetShortcut = UIApplicationShortcutItem(type: "com.theoven.H2O.mediumPresetEntry", localizedTitle: String(Int(presets[1])) + Constants.standardUnit.rawValue, localizedSubtitle: "", icon: UIApplicationShortcutIcon(templateImageName: "DarkMediumPresetImage"), userInfo: nil)
        
        let largePresetShortcut = UIApplicationShortcutItem(type: "com.theoven.H2O.largePresetEntry", localizedTitle: String(Int(presets[2])) + Constants.standardUnit.rawValue, localizedSubtitle: "", icon: UIApplicationShortcutIcon(templateImageName: "DarkLargePresetImage"), userInfo: nil)
        
        let customShortcut = UIApplicationShortcutItem(type: "com.theoven.H2O.customEntry", localizedTitle: "Custom", localizedSubtitle: "", icon: UIApplicationShortcutIcon(type: .add), userInfo: nil)

        UIApplication.shared().shortcutItems = [smallPresetShortcut, mediumPresetShortcut, largePresetShortcut, customShortcut]
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.theoven.H2O" in the application's documents Application Support directory.
        let urls = FileManager.default().urlsForDirectory(.documentDirectory, inDomains: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main().urlForResource("H2O", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = try! self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

