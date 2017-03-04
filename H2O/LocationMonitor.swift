//
//  LocationMonitor.swift
//  H2O
//
//  Created by Gregory Sapienza on 3/4/17.
//  Copyright © 2017 Skyscrapers.IO. All rights reserved.
//

import CoreLocation

class LocationMonitor: NSObject {
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        return locationManager
    }()
    
    func startMonitoringLocation() {
        locationManager.startUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationMonitor: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations.last)
    }
    
    
}
