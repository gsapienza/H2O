//
//  ServiceIntergrationModel.swift
//  H2O
//
//  Created by Gregory Sapienza on 12/8/16.
//  Copyright © 2016 City Pixels. All rights reserved.
//

import Foundation

enum SupportedServices: String {
    case healthkit = "HealthKit"
    
    func image() -> UIImage {
        switch self {
        case .healthkit:
            return UIImage(assetIdentifier: .healthKitCellImage)
        }
    }
    
    func model() -> ServiceIntergrationProtocol {
        switch self {
        case .healthkit:
            return HealthKitService()
        }
    }
    
    static func allSupportedServices() -> [SupportedServices] {
        return [.healthkit]
    }
}

class ServiceIntergrationModel {
    func addEntryToAuthorizedServices(amount: Float, date: Date) {
        guard let services = getAppDelegate().user?.services else {
            print("No services.")
            return
        }
        
        for service in services {
            guard let service = service as? Service else {
                return
            }
            
            let supportedService = SupportedServices(rawValue: service.name)
            
            if service.isAuthorized.boolValue {
                supportedService?.model().addEntry(amount: amount, date: date)
            }
        }
    }
    
    func deleteEntryFromAuthorizedServices(date: Date) {
        guard let services = getAppDelegate().user?.services else {
            print("No services.")
            return
        }
        
        for service in services {
            guard let service = service as? Service else {
                return
            }
                        
            let supportedService = SupportedServices(rawValue: service.name)
            
            if service.isAuthorized.boolValue {
                supportedService?.model().deleteEntry(date: date)
            }
        }
    }
}
