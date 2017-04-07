//
//  LocationMonitor.swift
//  H2O
//
//  Created by Gregory Sapienza on 3/4/17.
//  Copyright © 2017 City Pixels. All rights reserved.
//

import CoreLocation
import MapKit
import GooglePlaces
import UserNotifications

class LocationMonitor: NSObject {
    
    //MARK: - Public iVars
    
    /// Singleton location monitor.
    static let defaultLocationMonitor = LocationMonitor()
    
    // MARK: - Private iVars

    fileprivate lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startMonitoringSignificantLocationChanges() //https://badootech.badoo.com/ios-location-tracking-aac4e2323629 says this helps with the CLVisit monitoring.
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        return locationManager
    }()
    
    fileprivate let placesClient = GMSPlacesClient.shared()
    
    fileprivate var lastLocationCoordinatedNotified = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    // MARK: - Public

    func startMonitoringLocation() {
        locationManager.startMonitoringVisits()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationMonitor: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        locationManager.startMonitoringVisits() //In visit documentation to reset the location manager.

        guard visit.departureDate != Date.distantFuture else {
            return
        }
        
        let testContent = UNMutableNotificationContent()
        testContent.title = "TEST"
        testContent.body = "\(visit)"
        let testRequest = UNNotificationRequest(identifier: UUID().uuidString, content: testContent, trigger: nil)
        
        UNUserNotificationCenter.current().add(testRequest, withCompletionHandler: { (error: Error?) in
        })
        
        var backgroundIndentifier = UIBackgroundTaskInvalid
        
        backgroundIndentifier = UIApplication.shared.beginBackgroundTask {
            UIApplication.shared.endBackgroundTask(backgroundIndentifier)
        }
        
        placesClient.currentPlace { (list: GMSPlaceLikelihoodList?, error: Error?) in
            if let placeLikelihoodList = list {
                for likelihood in placeLikelihoodList.likelihoods {
                    if likelihood.likelihood > 0.1 {
                        let place = likelihood.place
                        
                        let categoryId = "com.theoven.H2O.notification"
                        
                        if place.types.contains("restaurant") {
                            let content = UNMutableNotificationContent()
                            content.categoryIdentifier = categoryId
                            content.title = "Eating Out?"
                            content.body = "Enjoy your meal at \(place.name), remember to drink some water while you are there."
                            
                            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
                            
                            UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error: Error?) in
                                if let error = error {
                                    print(error)
                                }
                                
                                print("Notification sent")
                            })
                            
                            break
                        }
                    }
                }
            }
        }
    }
}
