//
//  ViewControllerAlertExtension.swift
//  H2O
//
//  Created by Gregory Sapienza on 10/22/16.
//  Copyright © 2016 Midnite. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /// Displays alert view controller for a delete action.
    ///
    /// - parameter title:        Title of alert.
    /// - parameter message:      Message of alert.
    /// - parameter deleteAction: What to run when delete button is tapped.
    func displayDeleteAlert(title :String, message :String, deleteAction: @escaping () -> Void) {
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.prepare()
        feedbackGenerator.notificationOccurred(.warning)
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "delete_alert_button".localized, style: .destructive, handler: { (alert: UIAlertAction!) in
            deleteAction()
        }))
        
        alert.addAction(UIAlertAction(title: "cancel_navigation_item".localized, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
