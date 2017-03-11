//
//  LocationMonitor.swift
//  H2O
//
//  Created by Gregory Sapienza on 3/4/17.
//  Copyright © 2017 Skyscrapers.IO. All rights reserved.
//

import CoreLocation
import MapKit

class LocationMonitor: NSObject {
    
    //MARK: - Public iVars
    
    /// Singleton location monitor.
    static let defaultLocationMonitor = LocationMonitor()
    
    // MARK: - Private iVars

    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        return locationManager
    }()
    
    fileprivate lazy var geocoder: CLGeocoder = {
        let geocoder = CLGeocoder()
        
        return geocoder
    }()
    
    // MARK: - Public

    func startMonitoringLocation() {
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Private

    fileprivate func searchForPlace(query: String, in coordinate: CLLocationCoordinate2D, completionHandler: @escaping (_ response: MKLocalSearchResponse?, _ error: Error?) -> Void) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = query
        var region = MKCoordinateRegion()
        region.center = coordinate
        request.region = region
        let search = MKLocalSearch(request: request)
        
        search.start { (response: MKLocalSearchResponse?, error: Error?) in
            completionHandler(response, error)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationMonitor: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let lastLocation = locations.last else {
            return
        }
        
        searchForPlace(query: "restaurant", in: lastLocation.coordinate) { (response: MKLocalSearchResponse?, error: Error?) in
            
            guard let mapItems = response?.mapItems else {
                return
            }
            
            var mapLocItem = MKMapItem()
            var smallest: CLLocationDistance?
            for mapItem in mapItems {
                guard let mapItemLocation = mapItem.placemark.location else {
                    return
                }

                let distance = lastLocation.distance(from: mapItemLocation)
                
                if var smallest = smallest {
                    if distance < smallest {
                        smallest = distance
                        mapLocItem = mapItem
                    }
                } else {
                    smallest = distance
                    mapLocItem = mapItem
                }
            }
            
            print(smallest)

            smallest = 0
            print(mapLocItem)
        }
    }
    
    
}
