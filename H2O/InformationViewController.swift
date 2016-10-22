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

    //Array of data for entries. Contains date and entries.
    var dayEntries :[DayEntry]?
    
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
    
    /// When the user confirms a delete is allowed this will delete the entry from the database and table view
    fileprivate func delete(entries :[DayEntryIndexPath]) {
        var indexPathsToRemoveFromCell :[Int : [Int]] = [:]
            
        let _ = entries.map { (dayEntryIndex: (dayIndex: Int, entryIndex: Int)) in
            if indexPathsToRemoveFromCell.keys.contains(dayEntryIndex.dayIndex) {
                indexPathsToRemoveFromCell[dayEntryIndex.dayIndex]?.append(dayEntryIndex.entryIndex)
            } else {
                indexPathsToRemoveFromCell[dayEntryIndex.dayIndex] = [dayEntryIndex.entryIndex]
            }
        }
        
        for dayPath in indexPathsToRemoveFromCell {
            guard var dayEntry = dayEntries?[dayPath.key] else {
                fatalError("Day entry not found for index path")
            }
            
            guard let dateOfEntry = dayEntry.getDate() else {
                fatalError("Date not found for entry not found for index path")
            }
            
            var indexPathsToDelete :[IndexPath] = []
            for index in dayPath.value {
                dayEntry.removeEntry(at: index)
                dayEntries?[dayPath.key] = dayEntry //Set value in array to new reference.
                indexPathsToDelete.append(IndexPath(item: index, section: 0))
            }
            
            guard let cellToDeleteFrom = informationTableView.cellForRow(at: IndexPath(row: dayPath.key, section: 0)) as? DailyInformationTableViewCell else {
                fatalError("Cell is not correct type")
            }
            
            cellToDeleteFrom.dayEntriesCollectionView.deleteItems(at: indexPathsToDelete) //Delete the item from the collection view. Animated
            
            if dayEntry.entryCount() == 0 { //If there are no entries left
                dayEntries?.remove(at: dayPath.key)
                
                informationTableView.deleteRows(at: [IndexPath(row :dayPath.key, section :0)], with: .fade) //Delete the date row
            }
            
            informationViewControllerDelegate?.entryWasDeleted(dateOfEntry: dateOfEntry) //Inform the delegate that an entry was deleted.
        }
        
        weeklyBarGraphView.refreshBarGraph()
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
        
        cell.delegate = self //Delegate will allow the cell to recover entries on a particular date
        
        cell.dayEntriesCollectionView.reloadData() //Reload collection view in cell because while reusing cells, it will not refresh automatically and may display inccorect data
        
        return cell
    }
}

// MARK: - DailyInformationTableViewCellProtocol
extension InformationViewController :DailyInformationTableViewCellProtocol {
    func getEntriesForDay(cell: DailyInformationTableViewCell) -> [Entry]? {
        
        guard let indexPath = informationTableView.indexPathForRow(at: cell.center) else {
            return nil
        } //Get the cell by position because when trying to retreive it using the index path for cell, nil will be returned at times if the cell hasnt finished loading
        
        guard let dayEntry = dayEntries?[indexPath.row] else {
            fatalError("Day entry not found for index path")
        }
        
        return dayEntry.getEntries()
    }
    
    func promptEntryDeletion(cellToDeleteFrom: DailyInformationTableViewCell, index :Int) {
        if let dayIndexToDeleteFrom = informationTableView.indexPath(for: cellToDeleteFrom) {
            state = .selecting(selectedEntries: [(dayIndex :dayIndexToDeleteFrom.row, entryIndex :index)])
            stateDidChange()
        }
        
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
    
    func entrySelected(cell: DailyInformationTableViewCell, entryIndex: Int) {
        if let cellIndexPath = informationTableView.indexPath(for: cell) {
            let dayEntryIndexPath = (dayIndex :cellIndexPath.row, entryIndex :entryIndex)
            switch self.state {
            case .viewing:
                fatalError("Shouldn't get in this state.")
            case let .selecting(selectedEntries):
                var entries = selectedEntries
                entries.append(dayEntryIndexPath)
                self.state = .selecting(selectedEntries: entries)
                stateDidChange()
            case .deleting(_):
                fatalError("Shouldn't get in this state.")
            }
        }
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
