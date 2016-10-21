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
    func informationViewControllerGoal() -> Float
}

class InformationViewController: Popsicle {
    
    //MARK: - Public iVars
    
    /// Navigation bar for cancel and done button
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    /// Background blur view
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    /// Table view to hold dates and their entries
    @IBOutlet weak var informationTableView: UITableView!
    
    /// Label in the middle of the screen if no data was entered yet. Table is not present when this is displayed
    @IBOutlet weak var noDataLabel: UILabel!
    
    /// Delegate to inform the presenting view controller changes to entries
    var informationViewControllerDelegate :InformationViewControllerProtocol?
    
    /// User set goal
    var goal :Float!
    
    //MARK: - Internal iVars
    
    /// Array that contains dictionaries that contain dates as well as the water entry data entered for that day. Each dictionary contains a date and entries value
   // var dateCollection :[[String : AnyObject]]?
    
    var dayEntries :[DayEntry]?
    
    /// Date cell that containes an entry ready to be deleted
    var cellToDeleteFrom :DailyInformationTableViewCell!
    
    /// Index of the entry within the date cell that will be deleted. This is used so that the user can select and item to delete then get a confirmation alert before the deletion takes place. This stores the index to delete so the confirmation alert can perform the actual delete action
    var indexOfEntryToDelete = -1
    
    /// Weekly graph view in the header of the water data table view
    var weeklyBarGraphView :WeekBarGraphView!
    
    //MARK: - Private iVars
    
    /// State of the information table view.
    fileprivate var state = State.viewing
    
    //MARK: - Public
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let dateCollection = getAppDelegate().user!.entriesForDates() //Populate the table from core data
        
        dayEntries = populateEntriesForDates(collection: dateCollection)
        
        configureNavigationBar()
        configureTableView()
        configureNoDataLabel()
        configureBlurView()
        
        weeklyBarGraphView = generateWeeklyGraphView()
        
        stateDidChange()
        
        layout()
    }
    
    //MARK: - Private
    
    private func layout() {
        //---Header view creation---
        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height / 2.8)) //Height of header determined by what seemed to look best
        
        informationTableView.tableHeaderView = tableHeaderView
        
        //---Weekly Bar Graph View---
        
        let barGraphMargin :CGFloat = 10 //Margin around the bar graph
        
        weeklyBarGraphView.frame = CGRect(x: barGraphMargin, y: barGraphMargin, width: view.bounds.width - barGraphMargin * 2, height: tableHeaderView.bounds.height - barGraphMargin * 2)
        
        tableHeaderView.addSubview(weeklyBarGraphView)
    }
    
    private func populateEntriesForDates(collection :[[String : AnyObject]]) -> [DayEntry]? {
         return collection.map { (dateEntries :[String : AnyObject]) in
            guard
                let date = dateEntries["date"] as? Date,
                let entries = dateEntries["entries"] as? [Entry]
            else {
                fatalError("Entry objects are not correct type")
            }
            
            return DayEntry(date: date, entries: entries)
        }
    }
    
    fileprivate func stateDidChange() {
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
            endSelecting()
            break
        case let .selecting(selectedEntries):
            leftBarItem = (.delete, enabled: !selectedEntries.isEmpty)
            rightBarItem = .done
            beginSelecting()
            break
        case let .deleting(entries):
            leftBarItem = (.delete, enabled: true)
            rightBarItem = .done
            break
        }
        
        //Navigation item setup
        let navigationItem = UINavigationItem()
        
        //Navigation Title
        
        navigationItem.title = information_navigation_title_localized_string
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: StandardColors.primaryColor, NSFontAttributeName: StandardFonts.boldFont(size: 20)] //Navigation bar view properties
        
        
        let normalTitleTextAttributes = [NSForegroundColorAttributeName: StandardColors.primaryColor, NSFontAttributeName: StandardFonts.regularFont(size: 18)] as [String : Any]
        let deleteTitleTextAttributes = [NSForegroundColorAttributeName: StandardColors.standardRedColor, NSFontAttributeName: StandardFonts.regularFont(size: 18)] as [String : Any]
        let deleteDisabledTitleTextAttributes = [NSForegroundColorAttributeName: StandardColors.standardRedColor.withAlphaComponent(0.5), NSFontAttributeName: StandardFonts.regularFont(size: 18)] as [String : Any]

        
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
                let barButton = UIBarButtonItem(title: delete_navigation_item_localized_string, style: .plain, target: self, action: #selector(InformationViewController.onCloseButton))
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
    
    /// Begin selecing view arrangments daily information cells.
    private func beginSelecting() {
        for cell in informationTableView.visibleCells {
            if let cell = cell as? DailyInformationTableViewCell {
                cell.beginSelecting()
            }
        }
    }
    
    /// End selecting view arrangments daily information cells.
    private func endSelecting() {
        for cell in informationTableView.visibleCells {
            if let cell = cell as? DailyInformationTableViewCell {
                cell.endSelecting()
            }
        }
    }
    
    //MARK: - Internal
    
    /// When the user confirms a delete is allowed this will delete the entry from the database and table view
    func onEntryDeletion() {
        let indexPath = informationTableView.indexPath(for: cellToDeleteFrom) //Index path for cell to delete entry from
        
        var dict = dateCollection![(indexPath! as NSIndexPath).row] //Dictionary of date and entry data
        
        var entries = dict["entries"] as! [Entry] //Get the entries from the dictionary
        
        let entry = entries[indexOfEntryToDelete] //Entry to delete
        
        let dateOfEntry = entry.date
        
        entry.deleteEntry() //Perform the delete of entry
        
        entries.remove(at: indexOfEntryToDelete) //Remove the entry from the array just recovered
        
        dateCollection![(indexPath! as NSIndexPath).row]["entries"] = entries as AnyObject //Set the entries amount in the collection view to the new entries data set without the deleted entry
        
        let indexPathToDelete = IndexPath(item: indexOfEntryToDelete, section: 0) //Index path of entry in the collection view in the date cell
        
        cellToDeleteFrom.dayEntriesCollectionView.deleteItems(at: [indexPathToDelete]) //Delete the item from the collection view. Animated
        
        if entries.count == 0 { //If there are no entries left
            dateCollection?.remove(at: (indexPath! as NSIndexPath).row) //Remove the dictionary representing the date from the date collection
            
            informationTableView.deleteRows(at: [indexPath!], with: .fade) //Delete the date row
        }
        
        informationViewControllerDelegate?.entryWasDeleted(dateOfEntry: dateOfEntry) //Call when entry was deleted
    }
}

// MARK: - Private Generators
private extension InformationViewController {
    
    /// Generates a weekly chart view that increments its y values by 50.
    ///
    /// - returns: Bar graph displaying days of the week.
    func generateWeeklyGraphView() -> WeekBarGraphView {
        let view = WeekBarGraphView()
        
        //Gradients for the bar graph
        let topGradientColor = UIColor(red: 134, green: 226, blue: 246, alpha: 1).cgColor
        let bottomGradientColor = StandardColors.waterColor.cgColor
        view.gradientColors = [topGradientColor, bottomGradientColor]
        
        //Goal line setup
        let roundedUpToNearestFiftyGoal = 50.0 * ceil((informationViewControllerDelegate!.informationViewControllerGoal() / 50.0)) //Rounded goal to the next 50 ex: 87 becomes 100
        view.yAxisRange = (0, Double(roundedUpToNearestFiftyGoal))
        view.delegate = self

        return view
    }
}

//MARK: - Private View Configurations
private extension InformationViewController {
    ///Configures the navigation bar
    func configureNavigationBar() {
        //Transparent navigation bar
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        navigationBar.backgroundColor = UIColor.clear
    }
    
    
    /// Configures the background blur view
    func configureBlurView() {
        if AppUserDefaults.getDarkModeEnabled() {
            blurView.effect = UIBlurEffect(style: .dark)
        } else {
            blurView.effect = UIBlurEffect(style: .light)
        }
    }
    
    /// Configures the table view
    func configureTableView() {
        informationTableView.dataSource = self
        informationTableView.delegate = self
        
        informationTableView.separatorColor = StandardColors.primaryColor //White or black seperator line
    }
    
    /// Configures the no data label that appears when no entries have been made
    func configureNoDataLabel() {
        noDataLabel.text = no_water_date_logged_localized_string
        noDataLabel.textColor = StandardColors.primaryColor
        noDataLabel.font = StandardFonts.boldFont(size: 24)
    }
}

//MARK: - Target Action
internal extension InformationViewController {
    /// When the close bar button is tapped
    func onCloseButton() {
        dismissPopsicle()
    }
    
    /// When edit button button is tapped in viewing state.
    func onEditButton() {
        state = .selecting(selectedEntries: [])
        stateDidChange()
    }
    
    /// When done button is tapped in edit state.
    func onDoneButton() {
        state = .viewing
        stateDidChange()
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
        
        let dateComponents = calendar.dateComponents([.day, .month, .year], from: cellDateCollection["date"] as! Date) //Get the date from the dictionary
        
        let dateFormatter = DateFormatter()
        
        //Set the daily entry month and day label to one that corresponds with the date
        cell.dailyEntryDateView.monthLabel.text = dateFormatter.monthSymbols[dateComponents.month! - 1].lowercased()
        cell.dailyEntryDateView.dayLabel.text = String(dateComponents.day!)
        
        cell.delegate = self //Delegate will allow the cell to recover entries on a particular date
        
        cell.dayEntriesCollectionView.reloadData() //Reload collection view in cell because while reusing cells, it will not refresh automatically and may display inccorect data
        
        return cell
    }
}

// MARK: - DailyInformationTableViewCellProtocol
extension InformationViewController :DailyInformationTableViewCellProtocol {
    func getEntriesForDay(cell: DailyInformationTableViewCell) -> [Entry] {
        let indexPathForCell = informationTableView.indexPathForRow(at: cell.center) //Get the cell by position because when trying to retreive it using the index path for cell, nil will be returned at times if the cell hasnt finished loading
        
        let dict = dateCollection![((indexPathForCell as NSIndexPath?)?.row)!]
        
        let entries = dict["entries"] as! [Entry]
        
        return entries
    }
    
    func promptEntryDeletion(cellToDeleteFrom: DailyInformationTableViewCell, index :Int) {
        self.cellToDeleteFrom = cellToDeleteFrom
        indexOfEntryToDelete = index
        
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.prepare()
        feedbackGenerator.notificationOccurred(.warning)
        
        let alert = UIAlertController(title: delete_water_entry_alert_title_localized_string, message: are_you_sure_you_want_to_delete_entry_alert_description_localized_string, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: delete_alert_button_localized_string, style: .destructive, handler: { (alert: UIAlertAction!) in
            self.onEntryDeletion()
            self.weeklyBarGraphView.refreshBarGraph()
        }))
        
        alert.addAction(UIAlertAction(title: cancel_navigation_item_localized_string, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func getState() -> InformationViewController.State {
        return state
    }
}

// MARK: - WeekBarGraphViewProtocol
extension InformationViewController :WeekBarGraphViewProtocol {
    func weekBarGraphViewGoal() -> Float {
        return informationViewControllerDelegate!.informationViewControllerGoal()
    }
    
    func weekBarGraphViewWeekValues() -> WeekValues {
        let lastWeekValues = getAppDelegate().user!.waterValuesThisWeek()
        
        return WeekValues(sunday: CGFloat(lastWeekValues[0]), monday: CGFloat(lastWeekValues[1]), tuesday: CGFloat(lastWeekValues[2]), wednesday: CGFloat(lastWeekValues[3]), thursday: CGFloat(lastWeekValues[4]), friday: CGFloat(lastWeekValues[5]), saturday: CGFloat(lastWeekValues[6]))
    }
}
