//
//  NotificationViewController.swift
//  NotificationContent
//
//  Created by Gregory Sapienza on 3/25/17.
//  Copyright © 2017 Skyscrapers.IO. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    private lazy var fluidView: H2OFluidView = {
        let view = H2OFluidView()
        
        view.liquidFillColor = StandardColors.waterColor //Water fill

        return view
    }()
    
    private lazy var dailyEntryDial: DailyEntryDial = {
        let view = DailyEntryDial()
        
        view.innerCircleColor = StandardColors.primaryColor
        view.outerCircleColor = UIColor(red: 27/255, green: 119/255, blue: 135/255, alpha: 0.3)
        
        return view
    }()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //---Fluid View---//
        
        view.addSubview(fluidView)
       
        fluidView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints([
            NSLayoutConstraint(item: fluidView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: fluidView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: fluidView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: fluidView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        ])
        
        //---Daily Entry Dial---//
        
        view.addSubview(dailyEntryDial)
        
        dailyEntryDial.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints([
            NSLayoutConstraint(item: dailyEntryDial, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: dailyEntryDial, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: dailyEntryDial, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.7, constant: 0),
            NSLayoutConstraint(item: dailyEntryDial, attribute: .width, relatedBy: .equal, toItem: dailyEntryDial, attribute: .height, multiplier: 1, constant: 0)
            ])

    }
    
    func didReceive(_ notification: UNNotification) {

    }

}
