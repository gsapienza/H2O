//
//  AppDelegate.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/16/16.
//  Copyright © 2016 Skyscrapers.IO. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

@UIApplicationMain
public class AppDelegate: UIResponder, UIApplicationDelegate {

    public var window: UIWindow?
    private var _user :User?
    
    var navigationController: UINavigationController {
        return window!.rootViewController as! UINavigationController
    }
    
    lazy var primaryViewController: UIViewController = {
        
        if AppUserDefaults.getBoardingWasDismissed() {
            let viewController = WelcomeViewController()
            viewController.navigationThemeDidChangeHandler = { [weak self] theme in
                if let navigationController = self?.navigationController {
                    navigationController.navigationBar.applyTheme(navigationTheme: theme)
                }
            }
            return viewController
        } else {
            let viewController: MainViewController = UIStoryboard(storyboard: .Main).instantiateViewController()
            viewController.navigationThemeDidChangeHandler = { [weak self] theme in
                if let navigationController = self?.navigationController {
                    navigationController.navigationBar.applyTheme(navigationTheme: theme)
                }
            }
            return viewController
        }
    }()
    
    var user :User? {
        return _user
    }
    
    /**
     Are test cases currently running based on the APP_IS_RUNNING_TEST environment variable
     
     - returns: true if test cases are running
     */
    class func isRunningTest() -> Bool {
        let environment = ProcessInfo.processInfo.environment
        
        let isRunningTest = environment["APP_IS_RUNNING_TEST"]
        
        if isRunningTest == "YES" {
            return true
        } else {
            return false
        }
    }

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path {
            print("Documents Directory: " + documentsPath)
        }
        
        if !AppUserDefaults.getWasOpenedOnce() {
            setDefaultPresets()
            setDefaultGoal()
            
            AppUserDefaults.setAppWasOpenedOnce(openedOnce: true)
        }
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient) //Wont pause music in the background anymore. Instead plays sounds in the background
        
        WatchConnection.standardWatchConnection.activateSession() //Activates a session to communicate with the watch if there is one.
        
        _user = User.loadUser() //Loads user data from database
        
        checkHealthKitStatus()
        
        WatchConnection.standardWatchConnection.beginSync { (replyHandler :[String : Any]) in
        }
        
        primaryViewController.view.backgroundColor = UIColor.clear
        
        navigationController.setViewControllers([primaryViewController], animated: false)
        
        if !AppUserDefaults.getBoardingWasDismissed() {
           //pushBoardingViewControllerOnRoot()
        } else {
            AppDelegate.createShortcuts() //Creates 3D touch shortcuts
        }
        
        return true
    }
    

    public func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        guard let navigationController = window?.rootViewController as? UINavigationController else {
            return
        }
        
        guard let mainViewController = navigationController.viewControllers.first as? MainViewController else {
            return
        }
        
        if let presets = AppUserDefaults.getPresetWaterValues() {
            delay(delay: 0.2) { //Delay is for aesthetic purposes although required for the custom entry to get the view loaded first before drawing its paths
                switch shortcutItem.type {
                case ShortcutItemValue.smallEntry.rawValue: //First preset
                    mainViewController.addWaterToToday(amount: presets[0])
                case ShortcutItemValue.mediumEntry.rawValue: //Second preset
                    mainViewController.addWaterToToday(amount: presets[1])
                case ShortcutItemValue.largeEntry.rawValue: //Third preset
                    mainViewController.addWaterToToday(amount: presets[2])
                case ShortcutItemValue.customEntry.rawValue: //Custom entry
                    mainViewController.customEntryButtonTapped(customButton: mainViewController.customEntryButton)
                default:
                    return
                }
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
        checkHealthKitStatus()
    }

    public func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    public func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    private func checkHealthKitStatus() {
        let healthKitService = Service.serviceForName(managedObjectContext: managedObjectContext, serviceName: SupportedServices.healthkit.rawValue)
        
        if healthKitService == nil {
            if SupportedServices.healthkit.model().isAuthorized() {
                if let service = Service.create(name: SupportedServices.healthkit.rawValue, token: nil, isAuthorized: true) {
                    getAppDelegate().user?.addService(service: service)
                }
            }
        } else {
            if SupportedServices.healthkit.model().isAuthorized() {
                healthKitService?.isAuthorized = true
            } else {
                healthKitService?.isAuthorized = false
            }
            
            saveContext()
        }
    
    }
    
    //MARK: - UI
    
    /// Configures the view controllers navigation bar.
    private func configureNavigationBar(navigationBar :inout UINavigationBar) {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        navigationBar.backgroundColor = UIColor.clear
    }
    
    //MARK: - Default Settings
    
    
    /// Sets default preset values if none exist
    private func setDefaultPresets() {
        AppUserDefaults.setPresetWaterValues(presets: defaultPresets)
    }
    
    /// Sets default goal value if none exists
    private func setDefaultGoal() {
        AppUserDefaults.setDailyGoalValue(goal: defaultDailyGoal)
    }
    
    // MARK: - Class functions
    
    /**
     Creates dynamic 3D touch shortcuts to quick add water entries
     */
    class func createShortcuts() {
        if let presets = AppUserDefaults.getPresetWaterValues() {
            let smallPresetShortcut = UIApplicationShortcutItem(type: ShortcutItemValue.smallEntry.rawValue, localizedTitle: String(Int(presets[0])) + standardUnit.rawValue, localizedSubtitle: "", icon: UIApplicationShortcutIcon(templateImageName: "darkSmallPresetImage"), userInfo: nil)
            
            let mediumPresetShortcut = UIApplicationShortcutItem(type: ShortcutItemValue.mediumEntry.rawValue, localizedTitle: String(Int(presets[1])) + standardUnit.rawValue, localizedSubtitle: "", icon: UIApplicationShortcutIcon(templateImageName: "darkMediumPresetImage"), userInfo: nil)
            
            let largePresetShortcut = UIApplicationShortcutItem(type: ShortcutItemValue.largeEntry.rawValue, localizedTitle: String(Int(presets[2])) + standardUnit.rawValue, localizedSubtitle: "", icon: UIApplicationShortcutIcon(templateImageName: "darkLargePresetImage"), userInfo: nil)
            
            let customShortcut = UIApplicationShortcutItem(type: ShortcutItemValue.customEntry.rawValue, localizedTitle: "Custom", localizedSubtitle: "", icon: UIApplicationShortcutIcon(type: .add), userInfo: nil)
            
            UIApplication.shared.shortcutItems = [smallPresetShortcut, mediumPresetShortcut, largePresetShortcut, customShortcut]
        }
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.theoven.H2O" in the application's documents Application Support directory.
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        //let urls = FileManager.default.urlsForDirectory(.documentDirectory, inDomains: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "H2O", withExtension: "momd")
        return NSManagedObjectModel(contentsOf: modelURL!)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("H2O.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject

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

