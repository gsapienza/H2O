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
     */
    func entryWasDeleted()
    
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

    //Array of data for entries. Contains date and entries.
    var dayEntries :[DayEntry]?
    
    /// Weekly graph view in the header of the water data table view
    var weeklyBarGraphView :WeekBarGraphView!
        
    /// State of the information table view.
    var state = State.viewing
    
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
    
    /// When the user confirms a delete is allowed this will delete the entry from the database and table view
    func delete(entries :[DayEntryIndexPath]) {
        var indexPathsToRemoveFromCell :[Int : [Int]] = [:]
        
        let _ = entries.map { (dayEntryIndex: (dayIndex: Int, entryIndex: Int)) in //Takes all day entry index paths and creates a dictionary where the key is the index of the day and the values are the selected entries.
            if indexPathsToRemoveFromCell[dayEntryIndex.dayIndex] != nil { //If there is no array for the key.
                indexPathsToRemoveFromCell[dayEntryIndex.dayIndex]?.append(dayEntryIndex.entryIndex) //Otherwise just append the entry value to the other entries in the value.
            } else {
                indexPathsToRemoveFromCell[dayEntryIndex.dayIndex] = [dayEntryIndex.entryIndex] //Create one.
            }
        }
        
        var dayIndexesToDelete :[Int] = [] //Day indexes that will be deleted for empty days left after entries are deleted.
        var cellsCompletedTheirDeletions = 0 //A count that will be increased by one after an entry is successfully deleted. Essentially this is here to ensure all entries are deleted before removing an entire day row.
        
        func deleteDayRows() {
            if entries.count == cellsCompletedTheirDeletions { //If each entry has been deleted.
                let dayIndexPathsToDelete :[IndexPath] = dayIndexesToDelete.map({ (index :Int) -> IndexPath in //Create a map of index paths to remove from days.
                    return IndexPath(row: index, section: 0)
                })

                dayEntries = dayEntries?.enumerated().filter { !dayIndexesToDelete.contains($0.offset) }.map { $0.element } //Remove day entries by index.
                informationTableView.deleteRows(at: dayIndexPathsToDelete, with: .fade) //Delete the day rows.
                cellsCompletedTheirDeletions = 0 //Reset this to zero so the if statement wont pass through if another entry is completed deleting.
            }
        }
        for dayPath in indexPathsToRemoveFromCell { //Iterate through the days that have entries to remove.
            guard var dayEntry = dayEntries?[dayPath.key] else {
                fatalError("Day entry not found for index path")
            }
            
            
            var entryIndexesToDelete :[Int] = [] //Will be used as arg to delete entry indexes from the day entry backing a cell collection view in the day cell.
            for index in dayPath.value { //For each entry
                entryIndexesToDelete.append(index) //Append the index path to the array of deletions so we can delete them from the UI.
            }

            if let cellToDeleteFrom = informationTableView.cellForRow(at: IndexPath(row: dayPath.key, section: 0)) as? DailyInformationTableViewCell {
                cellToDeleteFrom.dayEntriesCollectionView.performBatchUpdates({
                    dayEntry.removeEntries(at: entryIndexesToDelete) //Remove it from the table view backing.
                    self.dayEntries?[dayPath.key] = dayEntry //Set the value of the day manipulated in array to new value since it is not a reference type.
                    
                    let indexPathsToDelete :[IndexPath] = entryIndexesToDelete.map({ (index :Int) -> IndexPath in //Will be used as the arg to use to delete index paths from the collection view in the day cell.
                        return IndexPath(row: index, section: 0)
                    })

                    cellToDeleteFrom.dayEntriesCollectionView.deleteItems(at: indexPathsToDelete) //Delete the item from the collection view. Animated
                    cellsCompletedTheirDeletions += entryIndexesToDelete.count //Number of entries being deleted. If this is the last of the entries, then a day cell can be potentially deleted.
                   
                    if dayEntry.entryCount() == 0 { //If there are no entries left
                        dayIndexesToDelete.append(dayPath.key)
                    }
                    
                }, completion: { (Bool) in
                    deleteDayRows() //Delete day rows if possible.
                })
            } else {
                dayEntry.removeEntries(at: entryIndexesToDelete) //Remove it from the table view backing.
                dayEntries?[dayPath.key] = dayEntry //Set the value of the day manipulated in array to new value since it is not a reference type.
                cellsCompletedTheirDeletions += entryIndexesToDelete.count //Number of entries being deleted. If this is the last of the entries, then a day cell can be potentially deleted.
                
                if dayEntry.entryCount() == 0 { //If there are no entries left
                    dayIndexesToDelete.append(dayPath.key)
                }
                
                deleteDayRows() //Delete day rows if possible.
            }
            
            informationViewControllerDelegate?.entryWasDeleted() //Inform the delegate that an entry was deleted.
        }

        weeklyBarGraphView.refreshBarGraph()
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
extension InformationViewController {
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
    
    /// When delete button is tapped in selecting state.
    func onDeleteButton() {
        switch self.state {
        case .viewing:
            fatalError("Shouldn't get in this state.")
        case let .selecting(selectedEntries): //When there have been items selected present an alert view to delete them.
            displayDeleteAlert(title: delete_multiple_water_entries_alert_title_localized_string, message: String(format: are_you_sure_you_want_to_delete_multiple_entries_alert_description_localized_string, selectedEntries.count)) {
                
                self.state = .deleting(entries: selectedEntries)
                self.stateDidChange()
                
                self.state = .viewing
                self.stateDidChange()
            }
        case .deleting(_):
            fatalError("Shouldn't get in this state.")
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension InformationViewController :UITableViewDataSource, UITableViewDelegate {
    
    /// Shows the no data label if not entries are present otherwise returns the amount of days of which entries were made
    func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dayEntries = self.dayEntries else {
            fatalError("Day entries should not be nil")
        }
        
        let numberOfRows = dayEntries.count
        
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
        
        let dayEntry = dayEntries?[indexPath.row]
        
        guard let dayEntryDate = dayEntry?.getDate() else {
            fatalError("Day entry date is nil")
        }
        
        let calendar = Calendar.current //Calendar type
        
        let dateComponents = calendar.dateComponents([.day, .month, .year], from: dayEntryDate) //Get the date from the day entry
        
        let dateFormatter = DateFormatter()
        
        //Set the daily entry month and day label to one that corresponds with the date
        cell.dailyEntryDateView.monthLabel.text = dateFormatter.monthSymbols[dateComponents.month! - 1].lowercased()
        cell.dailyEntryDateView.dayLabel.text = String(dateComponents.day!)
        
        cell.dayIndex = indexPath.row //Day index is simply the index path row.
        
        cell.delegate = self //Delegate will allow the cell to recover entries on a particular date
        
        cell.dayEntriesCollectionView.reloadData() //Reload collection view in cell because while reusing cells, it will not refresh automatically and may display incorect data
        cell.dayEntriesCollectionView.layoutIfNeeded() //Required to start the wobble animation. //QUESTION - Not sure why this starts the animation. Seems it should work without this line. When the entry cells are reloaded.
        
        return cell
    }
}

// MARK: - DailyInformationTableViewCellProtocol
extension InformationViewController :DailyInformationTableViewCellProtocol {
    func getEntriesForDay(dayIndex: Int) -> [Entry]? {
        guard let dayEntry = dayEntries?[dayIndex] else {
            fatalError("Day entry not found for index path")
        }
        
        return dayEntry.getEntries()
    }
    
    func promptEntryDeletion(dayIndex: Int, entryIndex :Int) {
        state = .selecting(selectedEntries: [(dayIndex :dayIndex, entryIndex :entryIndex)])
        stateDidChange()
        
        displayDeleteAlert(title: delete_water_entry_alert_title_localized_string, message: are_you_sure_you_want_to_delete_entry_alert_description_localized_string) { 
            switch self.state {
            case .viewing:
                fatalError("Shouldn't get in this state.")
            case let .selecting(selectedEntries):
                self.state = .deleting(entries: selectedEntries)
            case .deleting(_):
                fatalError("Shouldn't get in this state.")
            }
            
            self.stateDidChange()
        }
    }
    
    func getState() -> InformationViewController.State {
        return state
    }
    
    func entrySelected(dayIndex: Int, entryIndex: Int) {
        let dayEntryIndexPath = (dayIndex :dayIndex, entryIndex :entryIndex)
        switch self.state {
        case .viewing:
            fatalError("Shouldn't get in this state.")
        case let .selecting(selectedEntries):
            var entries = selectedEntries
            entries.append(dayEntryIndexPath)
            self.state = .selecting(selectedEntries: entries)
            stateDidChange()
            
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()
        case .deleting(_):
            fatalError("Shouldn't get in this state.")
        }
    }
    
    func entryDeselected(dayIndex: Int, entryIndex: Int) {
        let dayEntryIndexPath = (dayIndex :dayIndex, entryIndex :entryIndex)
        switch self.state {
        case .viewing:
            fatalError("Shouldn't get in this state.")
        case let .selecting(selectedEntries):
            var entries = selectedEntries
            for (i, entry) in entries.enumerated() {
                if entry == dayEntryIndexPath {
                    entries.remove(at: i)
                }
            }
            self.state = .selecting(selectedEntries: entries)
            stateDidChange()
            
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()
        case .deleting(_):
            fatalError("Shouldn't get in this state.")
        }
    }
    
    func isEntrySelected(dayIndex: Int, entryIndex: Int) -> Bool {
        let dayEntryIndexPath = (dayIndex :dayIndex, entryIndex :entryIndex)
        switch self.state {
        case let .selecting(selectedEntries):
            for entry in selectedEntries {
                if entry == dayEntryIndexPath {
                    return true
                }
            }
            
        default: break
        }
        return false
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
