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
