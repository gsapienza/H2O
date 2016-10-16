//
//  InformationViewControllerState.swift
//  H2O
//
//  Created by Gregory Sapienza on 10/15/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

extension InformationViewController {
    enum State: Equatable {
        case viewing
        case selecting(selectedRows: IndexSet)
        case deleting(entries: [Entry])
        
    }
    
}

func ==(_ lhs :InformationViewController.State, _ rhs :InformationViewController.State) -> Bool {
    switch (lhs, rhs) {
    case (.viewing, .viewing):
        return true
    default:
        return false
    }
}
