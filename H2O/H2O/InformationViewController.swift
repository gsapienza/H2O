//
//  InformationViewController.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/22/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

protocol InformationViewControllerProtocol {
    /**
     Called when a water entry was deleted for any day
     
     - parameter dateOfEntry: Date that the entry was created
     */
    func entryWasDeleted(dateOfEntry :NSDate)
}

class InformationViewController: Popsicle {
    @IBOutlet weak var _navigationBar: UINavigationBar!
    @IBOutlet weak var _blurView: UIVisualEffectView!
    @IBOutlet weak var _informationTableView: UITableView!
    @IBOutlet weak var _noDataLabel: UILabel!
    
    var _dateCollection :[[String : AnyObject]]?
    
    var _cellToDeleteFrom = DailyInformationTableViewCell()
    var _indexOfEntryToDelete = -1
    
        /// Delegate to inform the presenting view controller changes to entries
    var _informationViewControllerDelegate :InformationViewControllerProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _dateCollection = AppDelegate.getAppDelegate().user!.getEntriesForDates()
        setupNavigationBar()
        setupBlurView()
        setupTableView()
        setupNoDataLabel()
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
    
    private func setupNoDataLabel() {
        _noDataLabel.text = "No Water Data Logged"
        _noDataLabel.textColor = StandardColors.primaryColor
        _noDataLabel.font = StandardFonts.boldFont(24)
    }
    
    func onCloseButton() {
        dismissPopsicle()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension InformationViewController :UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = (_dateCollection?.count)!
        
        if numberOfRows == 0 {
            _noDataLabel.hidden = false
            _informationTableView.hidden = true
        } else {
            _noDataLabel.hidden = true
            _informationTableView.hidden = false
        }
        
        return numberOfRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DAILY_INFO_CELL", forIndexPath: indexPath) as! DailyInformationTableViewCell
        
        let cellDateCollection = _dateCollection![indexPath.row]
        
        let calendar = NSCalendar.currentCalendar() //Calendar type
        
        let dateComponents = calendar.components([.Day, .Month, .Year], fromDate: cellDateCollection["date"] as! NSDate)
        
        let dateFormatter = NSDateFormatter()
        
        cell._dailyEntryDateView._monthLabel.text = dateFormatter.monthSymbols[dateComponents.month - 1].lowercaseString
        cell._dailyEntryDateView._dayLabel.text = String(dateComponents.day)
        
        cell._delegate = self
        
        return cell
    }
}

// MARK: - DailyInformationTableViewCellProtocol
extension InformationViewController :DailyInformationTableViewCellProtocol {
    func getEntriesForDay(cell: DailyInformationTableViewCell) -> [Entry] {
        let indexPathForCell = _informationTableView.indexPathForCell(cell)
        
        let dict = _dateCollection![(indexPathForCell?.row)!]
        
        let entries = dict["entries"] as! [Entry]
        
        return entries
    }
    
    func promptEntryDeletion(cellToDeleteFrom: DailyInformationTableViewCell, index :Int) {
        _cellToDeleteFrom = cellToDeleteFrom
        _indexOfEntryToDelete = index
        
        let alert = UIAlertController(title: "Delete Entry", message: "Are you sure you want to delete this entry?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: { (alert: UIAlertAction!) in
            self.onEntryDeletion()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func onEntryDeletion() {
        let indexPath = _informationTableView.indexPathForCell(_cellToDeleteFrom)
        
        var dict = _dateCollection![indexPath!.row]
        
        var entries = dict["entries"] as! [Entry]
        
        let entry = entries[_indexOfEntryToDelete]
        
        let dateOfEntry = entry.date?.copy() as! NSDate
        
        entry.deleteEntry()
        
        entries.removeAtIndex(_indexOfEntryToDelete)
        
        _dateCollection![indexPath!.row]["entries"] = entries
        
        let indexPathToDelete = NSIndexPath(forItem: _indexOfEntryToDelete, inSection: 0)
        
        _cellToDeleteFrom._dayEntriesCollectionView.deleteItemsAtIndexPaths([indexPathToDelete])
        
        if entries.count == 0 {
            _dateCollection?.removeAtIndex(indexPath!.row)
            
            _informationTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }
        
        _informationViewControllerDelegate?.entryWasDeleted(dateOfEntry)
    }
}
