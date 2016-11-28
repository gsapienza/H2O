//
//  InformationViewControllerState.swift
//  H2O
//
//  Created by Gregory Sapienza on 10/15/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

typealias DayEntryIndexPath = (dayIndex: Int, entryIndex: Int)

extension InformationViewController {
    enum State {
        case viewing
        case selecting(selectedEntries: [DayEntryIndexPath])
        case deleting(entries: [DayEntryIndexPath])
        
    }
    
    func stateDidChange() {
        enum LeftBarButton {
            case close
            case delete
        }
        
        enum RightBarButton {
            case edit
            case done
        }
        
        let leftBarItem :(style :LeftBarButton?, enabled: Bool)?
        let rightBarItem :RightBarButton?
        
        switch state {
        case .viewing:
            leftBarItem = (.close, enabled: true)
            rightBarItem = .edit
            for cell in informationTableView.visibleCells {
                guard let cell = cell as? DailyInformationTableViewCell else {
                    fatalError("Cell is wrong type")
                }
                
                cell.refreshCells()
            }
            break
        case let .selecting(selectedEntries):
            leftBarItem = (.delete, enabled: !selectedEntries.isEmpty)
            rightBarItem = .done
            for cell in informationTableView.visibleCells {
                guard let cell = cell as? DailyInformationTableViewCell else {
                    fatalError("Cell is wrong type")
                }
                
                cell.refreshCells()
            }
            
            break
        case let .deleting(entries):
            leftBarItem = nil
            rightBarItem = nil
            delete(entries: entries)
            break
        }
        
        //Navigation item setup
        let navigationItem = UINavigationItem()
        
        //Navigation Title
        
        navigationItem.title = information_navigation_title_localized_string
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: StandardColors.primaryColor, NSFontAttributeName: StandardFonts.boldFont(size: 20)] //Navigation bar view properties
        
        let buttonTitleFontSize :CGFloat = 18
        
        let normalTitleTextAttributes = [NSForegroundColorAttributeName: StandardColors.primaryColor, NSFontAttributeName: StandardFonts.regularFont(size: buttonTitleFontSize)] as [String : Any]
        let deleteTitleTextAttributes = [NSForegroundColorAttributeName: StandardColors.standardRedColor, NSFontAttributeName: StandardFonts.regularFont(size: buttonTitleFontSize)] as [String : Any]
        let deleteDisabledTitleTextAttributes = [NSForegroundColorAttributeName: StandardColors.standardRedColor.withAlphaComponent(0.5), NSFontAttributeName: StandardFonts.regularFont(size: buttonTitleFontSize)] as [String : Any]
        
        
        //Left Bar Button
        
        let leftBarButton = leftBarItem.map { buttonItem -> UIBarButtonItem? in
            guard let leftBarItem = leftBarItem else {
                print("Left Bar Item is nil")
                return nil
            }
            
            guard let leftBarItemStyle = leftBarItem.style else {
                print("Left Bar Item style not set")
                return nil
            }
            
            switch leftBarItemStyle {
            case .close:
                let barButton = UIBarButtonItem(title: close_navigation_item_localized_string, style: .plain, target: self, action: #selector(InformationViewController.onCloseButton))
                barButton.setTitleTextAttributes(normalTitleTextAttributes, for: .normal)
                barButton.isEnabled = leftBarItem.enabled
                return barButton
            case .delete:
                let barButton = UIBarButtonItem(title: delete_navigation_item_localized_string, style: .plain, target: self, action: #selector(InformationViewController.onDeleteButton))
                barButton.setTitleTextAttributes(deleteTitleTextAttributes, for: .normal)
                barButton.setTitleTextAttributes(deleteDisabledTitleTextAttributes, for: .disabled)
                barButton.isEnabled = leftBarItem.enabled
                return barButton
            }
        }
        
        if let leftBarButton = leftBarButton {
            navigationItem.leftBarButtonItem = leftBarButton
        }
        
        
        //Right Bar Button
        
        let rightBarButton = rightBarItem.map { buttonItem -> UIBarButtonItem? in
            guard let rightBarItem = rightBarItem else {
                print("Right Bar Item is nil")
                return nil
            }
            
            switch rightBarItem {
            case .edit:
                return UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(onEditButton))
            case .done:
                return UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDoneButton))
            }
        }
        
        if let rightBarButton = rightBarButton {
            rightBarButton?.setTitleTextAttributes(normalTitleTextAttributes, for: .normal)
            navigationItem.rightBarButtonItem = rightBarButton
        }
        
        navigationBar.items = [navigationItem]
    }
}

func ==(_ lhs :DayEntryIndexPath, _ rhs :DayEntryIndexPath) -> Bool {
    if lhs.dayIndex == rhs.dayIndex && lhs.entryIndex == rhs.entryIndex {
        return true
    } else {
        return false
    }
}
