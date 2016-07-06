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
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var informationTableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    let weeklyBarGraphView = WeekBarGraphView()

    var dateCollection :[[String : AnyObject]]?
    
    var cellToDeleteFrom = DailyInformationTableViewCell()
    var indexOfEntryToDelete = -1
    
    var lastScrollOffset = CGPoint(x: 0, y: 0)
    
        /// Delegate to inform the presenting view controller changes to entries
    var informationViewControllerDelegate :InformationViewControllerProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateCollection = AppDelegate.getAppDelegate().user!.getEntriesForDates()
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
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        navigationBar.backgroundColor = UIColor.clear()
        
        let navigationItem = UINavigationItem()
        navigationItem.title = "Information"
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: StandardColors.primaryColor, NSFontAttributeName: StandardFonts.boldFont(20)] //Navigation bar view properties
        
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(InformationViewController.onCloseButton))
        
        closeButton.setTitleTextAttributes([NSForegroundColorAttributeName: StandardColors.primaryColor, NSFontAttributeName: StandardFonts.regularFont(18)], for: UIControlState()) //Close button view properties
        
        navigationItem.leftBarButtonItem = closeButton
        
        navigationBar.items = [navigationItem]
    }
    
    private func setupBlurView() {
        if AppDelegate.isDarkModeEnabled() {
            blurView.effect = UIBlurEffect(style: .dark)
        } else {
            blurView.effect = UIBlurEffect(style: .light)
        }
    }
    
    private func setupTableView() {
        informationTableView.dataSource = self
        informationTableView.delegate = self
        
        informationTableView.separatorColor = StandardColors.primaryColor
    }
    
    private func setupNoDataLabel() {
        noDataLabel.text = "No Water Data Logged"
        noDataLabel.textColor = StandardColors.primaryColor
        noDataLabel.font = StandardFonts.boldFont(24)
    }
    
    private func setupWeeklyBarGraphView() {
        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 250))
        
        informationTableView.tableHeaderView = tableHeaderView
        
        let barGraphMargin :CGFloat = 10
        weeklyBarGraphView.frame = CGRect(x: barGraphMargin, y: barGraphMargin, width: view.bounds.width - barGraphMargin * 2, height: tableHeaderView.bounds.height - barGraphMargin * 2)
        
        let topGradientColor = UIColor(red: 134, green: 226, blue: 246, alpha: 1).cgColor
        let bottomGradientColor = StandardColors.waterColor.cgColor
        weeklyBarGraphView.gradientColors = [topGradientColor, bottomGradientColor]
        
        let roundedGoal = 50.0 * floor((informationViewControllerDelegate!.informationViewGetGoal() / 50.0) + 0.5)
        weeklyBarGraphView.yAxisRange = (0, Double(roundedGoal))
        weeklyBarGraphView.goal = informationViewControllerDelegate!.informationViewGetGoal()
        
        tableHeaderView.addSubview(weeklyBarGraphView)
    }
    
    func onCloseButton() {
        dismissPopsicle()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension InformationViewController :UITableViewDataSource, UITableViewDelegate {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DAILY_INFO_CELL", for: indexPath) as! DailyInformationTableViewCell
        
        let cellDateCollection = dateCollection![(indexPath as NSIndexPath).row]
        
        let calendar = Calendar.current //Calendar type
        
        let dateComponents = calendar.components([.day, .month, .year], from: cellDateCollection["date"] as! Date)
        
        let dateFormatter = DateFormatter()
        
        cell.dailyEntryDateView.monthLabel.text = dateFormatter.monthSymbols[dateComponents.month! - 1].lowercased()
        cell.dailyEntryDateView.dayLabel.text = String(dateComponents.day!)
        
        cell.delegate = self
        
        cell.dayEntriesCollectionView.reloadData()
        
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
    func getEntriesForDay( cell: DailyInformationTableViewCell) -> [Entry] {
        let indexPathForCell = informationTableView.indexPath(for: cell)
        
        let dict = dateCollection![((indexPathForCell as NSIndexPath?)?.row)!]
        
        let entries = dict["entries"] as! [Entry]
        
        return entries
    }
    
    func promptEntryDeletion( cellToDeleteFrom: DailyInformationTableViewCell, index :Int) {
        self.cellToDeleteFrom = cellToDeleteFrom
        indexOfEntryToDelete = index
        
        let alert = UIAlertController(title: "Delete Entry", message: "Are you sure you want to delete this entry?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (alert: UIAlertAction!) in
            self.onEntryDeletion()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func onEntryDeletion() {
        let indexPath = informationTableView.indexPath(for: cellToDeleteFrom)
        
        var dict = dateCollection![(indexPath! as NSIndexPath).row]
        
        var entries = dict["entries"] as! [Entry]
        
        let entry = entries[indexOfEntryToDelete]
        
        let dateOfEntry = entry.date
        
        entry.deleteEntry()
        
        entries.remove(at: indexOfEntryToDelete)
        
        dateCollection![(indexPath! as NSIndexPath).row]["entries"] = entries
        
        let indexPathToDelete = IndexPath(item: indexOfEntryToDelete, section: 0)
        
        cellToDeleteFrom.dayEntriesCollectionView.deleteItems(at: [indexPathToDelete])
        
        if entries.count == 0 {
            dateCollection?.remove(at: (indexPath! as NSIndexPath).row)
            
            informationTableView.deleteRows(at: [indexPath!], with: .fade)
        }
        
        informationViewControllerDelegate?.entryWasDeleted(dateOfEntry: dateOfEntry!)
    }
}
