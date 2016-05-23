//
//  InformationViewController.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/22/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

class InformationViewController: Popsicle {
    @IBOutlet weak var _navigationBar: UINavigationBar!
    @IBOutlet weak var _blurView: UIVisualEffectView!
    @IBOutlet weak var _informationTableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupBlurView()
        setupTableView()
    }

    /**
     Sets up view properties for the navigation bar
     */
    private func setupNavigationBar() {
        _navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        _navigationBar.shadowImage = UIImage()
        _navigationBar.translucent = true
        _navigationBar.backgroundColor = UIColor.clearColor()
        
        let navigationItem = UINavigationItem()
        navigationItem.title = "Information"
        _navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: StandardColors.primaryColor, NSFontAttributeName: StandardFonts.boldFont(20)] //Navigation bar view properties
        
        let closeButton = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: #selector(InformationViewController.onCloseButton))
        
        closeButton.setTitleTextAttributes([NSForegroundColorAttributeName: StandardColors.primaryColor, NSFontAttributeName: StandardFonts.regularFont(18)], forState: .Normal) //Close button view properties
        
        navigationItem.leftBarButtonItem = closeButton
        
        _navigationBar.items = [navigationItem]
    }
    
    private func setupBlurView() {
        if AppDelegate.isDarkModeEnabled() {
            _blurView.effect = UIBlurEffect(style: .Dark)
        } else {
            _blurView.effect = UIBlurEffect(style: .Light)
        }
    }
    
    private func setupTableView() {
        _informationTableView.dataSource = self
        _informationTableView.delegate = self
        
        _informationTableView.separatorColor = StandardColors.primaryColor
    }
    
    func onCloseButton() {
        dismissPopsicle()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension InformationViewController :UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DAILY_INFO_CELL", forIndexPath: indexPath)
        
        return cell
    }
}
