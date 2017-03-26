//
//  LocationMonitor.swift
//  H2O
//
//  Created by Gregory Sapienza on 3/4/17.
//  Copyright © 2017 City Pixels. All rights reserved.
//

import CoreLocation
import MapKit
import UserNotifications

class LocationMonitor: NSObject {
    
    //MARK: - Public iVars
    
    /// Singleton location monitor.
    static let defaultLocationMonitor = LocationMonitor()
    
    // MARK: - Private iVars

    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.delegate = self
        //locationManager.distanceFilter = 50
        locationManager.pausesLocationUpdatesAutomatically = false
        //locationManager.startMonitoringSignificantLocationChanges()
        locationManager.requestAlwaysAuthorization()
      //   locationManager.startMonitoringVisits()
        
        return locationManager
    }()
    
    fileprivate lazy var geocoder: CLGeocoder = {
        let geocoder = CLGeocoder()
        
        return geocoder
    }()
    
    fileprivate var lastLocationCoordinatedNotified = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    // MARK: - Public

    func startMonitoringLocation() {
        locationManager.startMonitoringVisits()

        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Private

    fileprivate func searchForPlace(query: String, in coordinate: CLLocationCoordinate2D, completionHandler: @escaping (_ response: MKLocalSearchResponse?, _ error: Error?) -> Void) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = query
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 7, 7)//MKCoordinateRegion(center: coordinate, span: MKCoordinateSpanMake(0.0001, 0.0001))
        request.region = region
        let search = MKLocalSearch(request: request)
        
        search.start { (response: MKLocalSearchResponse?, error: Error?) in
            completionHandler(response, error)
        }
    }
    
    fileprivate func coordinatesEqual(coor1: CLLocationCoordinate2D, coor2: CLLocationCoordinate2D) -> Bool {
        if coor1.longitude == coor2.longitude && coor1.latitude == coor2.latitude {
            return true
        } else {
            return false
        }
    }
    
    fileprivate func distanceFromCoordinate(fromCoordinate: CLLocationCoordinate2D, toCoordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let earthRadius = 6371.01
        
        let kDegreesToRadians = M_PI / 180.0
        
        let latDis = (fromCoordinate.latitude - toCoordinate.latitude) * kDegreesToRadians
        let lonDis = (fromCoordinate.longitude - toCoordinate.longitude) * kDegreesToRadians

        let fromLat = toCoordinate.latitude * kDegreesToRadians
        let toLat = fromCoordinate.latitude * kDegreesToRadians
        
        let na = pow(sin(latDis / 2), 2) + cos(fromLat) * cos(toLat) * pow(sin(lonDis / 2), 2 )
        let nc = 2 * atan2(sqrt(na), sqrt(1 - na))
        let nd = earthRadius * nc
        
        return nd * 1000
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationMonitor: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        
        manager.startUpdatingLocation()
        
        let testContent = UNMutableNotificationContent()
        testContent.title = "TEST"
        testContent.body = "TEST"
        let testRequest = UNNotificationRequest(identifier: UUID().uuidString, content: testContent, trigger: nil)
        
        UNUserNotificationCenter.current().add(testRequest, withCompletionHandler: { (error: Error?) in
        })
        
        let geocoder = CLGeocoder()
        
        let location = CLLocation(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude)
        
        var street = ""
        geocoder.reverseGeocodeLocation(location) { (placemarks: [CLPlacemark]?, error: Error?) in
            if let placemark = placemarks?.last {
                if let thoroughfare = placemark.thoroughfare {
                    street = thoroughfare
                }
            } else {
                street = "FAIL"
            }
        }
        
        let content = UNMutableNotificationContent()
        content.title = "New Visit"
        content.body = street
        let request = UNNotificationRequest(identifier: "NEWVISITTEST", content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error: Error?) in
        })
        
        
        
        
        
        
        
        
        searchForPlace(query: "restaurant", in: visit.coordinate) { (response: MKLocalSearchResponse?, error: Error?) in
            
            guard let mapItems = response?.mapItems else {
                return
            }
            
            var localMapItem = MKMapItem()
            var smallestDistance: CLLocationDistance = -1
            for mapItem in mapItems {
                guard let mapItemLocation = mapItem.placemark.location else {
                    return
                }
                
                let visitLocation = CLLocation(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude)

                let distance = visitLocation.distance(from: mapItemLocation)
                
                if distance < smallestDistance || smallestDistance == -1 {
                    smallestDistance = distance
                    localMapItem = mapItem
                }
            }
            
            print(smallestDistance)
            
            let minimumAcceptableDistanceFromLocation: CLLocationDistance = 30
            
            if smallestDistance <= minimumAcceptableDistanceFromLocation && !self.coordinatesEqual(coor1: self.lastLocationCoordinatedNotified, coor2: localMapItem.placemark.coordinate) {
                if let locationName = localMapItem.placemark.name {
                    let content = UNMutableNotificationContent()
                    content.title = "Eating Out?"
                    content.body = "Enjoy your meal at \(locationName), remember to drink some water while you are there."
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
                    
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error: Error?) in
                        if let error = error {
                            print(error)
                        } else {
                            self.lastLocationCoordinatedNotified = localMapItem.placemark.coordinate
                        }
                        
                        print("Notification sent")
                    })
                    
                    // print(localMapItem)
                }
            }
            
            smallestDistance = -1
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else {
            return
        }
        
        searchForPlace(query: "restaurant", in: coordinate) { (response: MKLocalSearchResponse?, error: Error?) in
            
            guard let mapItems = response?.mapItems else {
                return
            }
            
            var localMapItem = MKMapItem()
            var smallestDistance: CLLocationDistance = -1
            for mapItem in mapItems {
                guard let mapItemLocation = mapItem.placemark.location else {
                    return
                }
                
                let visitLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                
                let distance = visitLocation.distance(from: mapItemLocation)
                
                if distance < smallestDistance || smallestDistance == -1 {
                    smallestDistance = distance
                    localMapItem = mapItem
                }
            }
            
            print(smallestDistance)
            
            let minimumAcceptableDistanceFromLocation: CLLocationDistance = 30
            
            if smallestDistance <= minimumAcceptableDistanceFromLocation && !self.coordinatesEqual(coor1: self.lastLocationCoordinatedNotified, coor2: localMapItem.placemark.coordinate) {
                if let locationName = localMapItem.placemark.name {
                    let content = UNMutableNotificationContent()
                    content.title = "Eating Out?"
                    content.body = "Enjoy your meal at \(locationName), remember to drink some water while you are there."
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
                    
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error: Error?) in
                        if let error = error {
                            print(error)
                        } else {
                            self.lastLocationCoordinatedNotified = localMapItem.placemark.coordinate
                        }
                        
                        print("Notification sent")
                    })
                    
                    // print(localMapItem)
                }
            }
            
            smallestDistance = -1
        }
        
        manager.stopUpdatingLocation()
    }
}
