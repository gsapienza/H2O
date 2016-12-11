//
//  ServiceIntergrationModel.swift
//  H2O
//
//  Created by Gregory Sapienza on 12/8/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import Foundation

enum SupportedServices {
    case healthkit
    
    func string() -> String {
        switch self {
        case .healthkit:
            return "HealthKit"
        }
    }
    
    func image() -> UIImage {
        switch self {
        case .healthkit:
            return UIImage(assetIdentifier: .healthKitCellImage)
        }
    }
    
    static func allSupportedServices() -> [SupportedServices] {
        return [.healthkit]
    }
}

class ServiceIntergrationModel {
    
}

