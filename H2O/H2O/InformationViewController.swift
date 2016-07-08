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
    func entryWasDeleted( dateOfEntry :Date)
    
    /**
     Determines the user set goal from NSUserDefaults
     
     - returns: Goal float value set by user
     */
    func informationViewGetGoal() -> Float
}

class InformationViewController: Popsicle {
    
    //MARK: - UI
    
    /// Navigation bar for cancel and done button
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    /// Background blur view
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    /// Table view to hold dates and their entries
    @IBOutlet weak var informationTableView: UITableView!
    
    /// Label in the middle of the screen if no data was entered yet. Table is not present when this is displayed
    @IBOutlet weak var noDataLabel: UILabel!
    
    /// Weekly graph view in the header of the water data table view
    let weeklyBarGraphView = WeekBarGraphView()

    //MARK: - Data
    
    /// Array that contains dictionaries that contain dates as well as the water entry data entered for that day. Each dictionary contains a date and entries value
    var dateCollection :[[String : AnyObject]]?
    
    /// Date cell that containes an entry ready to be deleted
    var cellToDeleteFrom = DailyInformationTableViewCell()
    
    /// Index of the entry within the date cell that will be deleted. This is used so that the user can select and item to delete then get a confirmation alert before the deletion takes place. This stores the index to delete so the confirmation alert can perform the actual delete action
    var indexOfEntryToDelete = -1
    
   // var lastScrollOffset = CGPoint(x: 0, y: 0)
    
    /// Delegate to inform the presenting view controller changes to entries
    var informationViewControllerDelegate :InformationViewControllerProtocol?
    
    //MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateCollection = AppDelegate.getAppDelegate().user!.getEntriesForDates() //Populate the table from core data
        
        setupNavigationBar()
        setupBlurView()
        setupTableView()
        setupNoDataLabel()
        setupWeeklyBarGraphView()
    }

    /**
     Sets up view properties for the navigation bar
     */
    private func setupNavigationBar() {
        //Transparent navigation bar
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        navigationBar.backgroundColor = UIColor.clear()
        
        //Navigation item setup
        let navigationItem = UINavigationItem()
        navigationItem.title = "Information"
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: StandardColors.primaryColor, NSFontAttributeName: StandardFonts.boldFont(20)] //Navigation bar view properties
        
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(InformationViewController.onCloseButton))
        
        closeButton.setTitleTextAttributes([NSForegroundColorAttributeName: StandardColors.primaryColor, NSFontAttributeName: StandardFonts.regularFont(18)], for: UIControlState()) //Close button view properties
        
        navigationItem.leftBarButtonItem = closeButton
        
        navigationBar.items = [navigationItem]
    }
    
    
    /// Layout for background blur view
    private func setupBlurView() {
        if AppDelegate.isDarkModeEnabled() {
            blurView.effect = UIBlurEffect(style: .dark)
        } else {
            blurView.effect = UIBlurEffect(style: .light)
        }
    }
    
    /// Layout for the table view
    private func setupTableView() {
        informationTableView.dataSource = self
        informationTableView.delegate = self
        
        informationTableView.separatorColor = StandardColors.primaryColor //White or black seperator line
    }
    
    /// Layout for the no data label that appears when no entries have been made
    private func setupNoDataLabel() {
        noDataLabel.text = "No Water Data Logged"
        noDataLabel.textColor = StandardColors.primaryColor
        noDataLabel.font = StandardFonts.boldFont(24)
    }
    
    /// Layout for the weekly bar graph in the table header view
    private func setupWeeklyBarGraphView() {
        //Header view creation
        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 250))
        
        informationTableView.tableHeaderView = tableHeaderView
        
        
        let barGraphMargin :CGFloat = 10 //Margin around the bar graph
        
        weeklyBarGraphView.frame = CGRect(x: barGraphMargin, y: barGraphMargin, width: view.bounds.width - barGraphMargin * 2, height: tableHeaderView.bounds.height - barGraphMargin * 2)
        
        //Gradients for the bar graph
        let topGradientColor = UIColor(red: 134, green: 226, blue: 246, alpha: 1).cgColor
        let bottomGradientColor = StandardColors.waterColor.cgColor
        weeklyBarGraphView.gradientColors = [topGradientColor, bottomGradientColor]
        
        //Goal line setup
        let roundedGoal = 50.0 * floor((informationViewControllerDelegate!.informationViewGetGoal() / 50.0) + 0.5)
        weeklyBarGraphView.yAxisRange = (0, Double(roundedGoal))
        weeklyBarGraphView.goal = informationViewControllerDelegate!.informationViewGetGoal()
        
        tableHeaderView.addSubview(weeklyBarGraphView)
    }
    
    //MARK: - Actions
    
    /// When the close button is tapped
    func onCloseButton() {
        dismissPopsicle()
    }
    
    /// When the user confirms a delete is allowed this will delete the entry from the database and table view
    func onEntryDeletion() {
        let indexPath = informationTableView.indexPath(for: cellToDeleteFrom) //Index path for cell to delete entry from
        
        var dict = dateCollection![(indexPath! as NSIndexPath).row] //Dictionary of date and entry data
        
        var entries = dict["entries"] as! [Entry] //Get the entries from the dictionary
        
        let entry = entries[indexOfEntryToDelete] //Entry to delete
        
        let dateOfEntry = entry.date
        
        entry.deleteEntry() //Perform the delete of entry
        
        entries.remove(at: indexOfEntryToDelete) //Remove the entry from the array just recovered
        
        dateCollection![(indexPath! as NSIndexPath).row]["entries"] = entries //Set the entries amount in the collection view to the new entries data set without the deleted entry
        
        let indexPathToDelete = IndexPath(item: indexOfEntryToDelete, section: 0) //Index path of entry in the collection view in the date cell
        
        cellToDeleteFrom.dayEntriesCollectionView.deleteItems(at: [indexPathToDelete]) //Delete the item from the collection view. Animated
        
        if entries.count == 0 { //If there are no entries left
            dateCollection?.remove(at: (indexPath! as NSIndexPath).row) //Remove the dictionary representing the date from the date collection
            
            informationTableView.deleteRows(at: [indexPath!], with: .fade) //Delete the date row
        }
        
        informationViewControllerDelegate?.entryWasDeleted(dateOfEntry: dateOfEntry!) //Call when entry was deleted
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension InformationViewController :UITableViewDataSource, UITableViewDelegate {
    
    /// Shows the no data label if not entries are present otherwise returns the amount of days of which entries were made
    func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = (dateCollection?.count)!
        
        if numberOfRows == 0 {
            noDataLabel.isHidden = false
            informationTableView.isHidden = true
        } else {
            noDataLabel.isHidden = true
            informationTableView.isHidden = false
        }
        
        return numberOfRows
    }
    
    /// Cells contain the date with a collection view of entries
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DAILY_INFO_CELL", for: indexPath) as! DailyInformationTableViewCell
        
        let cellDateCollection = dateCollection![(indexPath as NSIndexPath).row] //Dictionary data for use in cell
        
        let calendar = Calendar.current //Calendar type
        
        let dateComponents = calendar.components([.day, .month, .year], from: cellDateCollection["date"] as! Date) //Get the date from the dictionary
        
        let dateFormatter = DateFormatter()
        
        //Set the daily entry month and day label to one that corresponds with the date
        cell.dailyEntryDateView.monthLabel.text = dateFormatter.monthSymbols[dateComponents.month! - 1].lowercased()
        cell.dailyEntryDateView.dayLabel.text = String(dateComponents.day!)
        
        cell.delegate = self //Delegate will allow the cell to recover entries on a particular date
        
        cell.dayEntriesCollectionView.reloadData() //Reload collection view in cell because while reusing cells, it will not refresh automatically and may display inccorect data
        
        return cell
    }
    
   /* func scrollViewDidScroll( scrollView: UIScrollView) {
        let graphHeaderTransformValue :CGFloat = (1.0 / weeklyBarGraphView.bounds.height) * 2
        
        setAnchorPoint(CGPoint(x: 0.5, y: 1), view: weeklyBarGraphView)
        let xScale = weeklyBarGraphView.transform.a
        let yScale = weeklyBarGraphView.transform.d
        
        if scrollView.contentOffset.y > lastScrollOffset.y {
           // weeklyBarGraphView.transform = CGAffineTransformMakeScale(xScale - graphHeaderTransformValue, yScale - graphHeaderTransformValue)
        } else {
           // weeklyBarGraphView.transform = CGAffineTransformMakeScale(xScale + graphHeaderTransformValue, yScale + graphHeaderTransformValue)
        }
        
        lastScrollOffset = scrollView.contentOffset
    }
    
    func setAnchorPoint( anchorPoint: CGPoint, view: UIView){
        let oldOrigin = view.frame.origin
        view.layer.anchorPoint = anchorPoint
        let newOrigin = view.frame.origin
        
        let transition = CGPoint (x: newOrigin.x - oldOrigin.x, y: newOrigin.y - oldOrigin.y)
        
        view.center = CGPoint (x: view.center.x - transition.x, y: view.center.y - transition.y)
    }*/
}

// MARK: - DailyInformationTableViewCellProtocol
extension InformationViewController :DailyInformationTableViewCellProtocol {
    func getEntriesForDay(cell: DailyInformationTableViewCell) -> [Entry] {
        let indexPathForCell = informationTableView.indexPath(for: cell)
        
        let dict = dateCollection![((indexPathForCell as NSIndexPath?)?.row)!]
        
        let entries = dict["entries"] as! [Entry]
        
        return entries
    }
    
    func promptEntryDeletion(cellToDeleteFrom: DailyInformationTableViewCell, index :Int) {
        self.cellToDeleteFrom = cellToDeleteFrom
        indexOfEntryToDelete = index
        
        let alert = UIAlertController(title: "Delete Entry", message: "Are you sure you want to delete this entry?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (alert: UIAlertAction!) in
            self.onEntryDeletion()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
