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
    func entryWasDeleted(_ dateOfEntry :Date)
    
    /**
     Determines the user set goal from NSUserDefaults
     
     - returns: Goal float value set by user
     */
    func informationViewGetGoal() -> Float
}

class InformationViewController: Popsicle {
    @IBOutlet weak var _navigationBar: UINavigationBar!
    @IBOutlet weak var _blurView: UIVisualEffectView!
    @IBOutlet weak var _informationTableView: UITableView!
    @IBOutlet weak var _noDataLabel: UILabel!
    
    let _weeklyBarGraphView = WeekBarGraphView()

    var _dateCollection :[[String : AnyObject]]?
    
    var _cellToDeleteFrom = DailyInformationTableViewCell()
    var _indexOfEntryToDelete = -1
    
    var _lastScrollOffset = CGPoint(x: 0, y: 0)
    
        /// Delegate to inform the presenting view controller changes to entries
    var _informationViewControllerDelegate :InformationViewControllerProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _dateCollection = AppDelegate.getAppDelegate().user!.getEntriesForDates()
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
        _navigationBar.setBackgroundImage(UIImage(), for: .default)
        _navigationBar.shadowImage = UIImage()
        _navigationBar.isTranslucent = true
        _navigationBar.backgroundColor = UIColor.clear()
        
        let navigationItem = UINavigationItem()
        navigationItem.title = "Information"
        _navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: StandardColors.primaryColor, NSFontAttributeName: StandardFonts.boldFont(20)] //Navigation bar view properties
        
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(InformationViewController.onCloseButton))
        
        closeButton.setTitleTextAttributes([NSForegroundColorAttributeName: StandardColors.primaryColor, NSFontAttributeName: StandardFonts.regularFont(18)], for: UIControlState()) //Close button view properties
        
        navigationItem.leftBarButtonItem = closeButton
        
        _navigationBar.items = [navigationItem]
    }
    
    private func setupBlurView() {
        if AppDelegate.isDarkModeEnabled() {
            _blurView.effect = UIBlurEffect(style: .dark)
        } else {
            _blurView.effect = UIBlurEffect(style: .light)
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
    
    private func setupWeeklyBarGraphView() {
        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 250))
        
        _informationTableView.tableHeaderView = tableHeaderView
        
        let barGraphMargin :CGFloat = 10
        _weeklyBarGraphView.frame = CGRect(x: barGraphMargin, y: barGraphMargin, width: view.bounds.width - barGraphMargin * 2, height: tableHeaderView.bounds.height - barGraphMargin * 2)
        
        let topGradientColor = UIColor(red: 134, green: 226, blue: 246, alpha: 1).cgColor
        let bottomGradientColor = StandardColors.waterColor.cgColor
        _weeklyBarGraphView.gradientColors = [topGradientColor, bottomGradientColor]
        
        let roundedGoal = 50.0 * floor((_informationViewControllerDelegate!.informationViewGetGoal() / 50.0) + 0.5)
        _weeklyBarGraphView.yAxisRange = (0, Double(roundedGoal))
        _weeklyBarGraphView.goal = _informationViewControllerDelegate!.informationViewGetGoal()
        
        tableHeaderView.addSubview(_weeklyBarGraphView)
    }
    
    func onCloseButton() {
        dismissPopsicle()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension InformationViewController :UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = (_dateCollection?.count)!
        
        if numberOfRows == 0 {
            _noDataLabel.isHidden = false
            _informationTableView.isHidden = true
        } else {
            _noDataLabel.isHidden = true
            _informationTableView.isHidden = false
        }
        
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DAILY_INFO_CELL", for: indexPath) as! DailyInformationTableViewCell
        
        let cellDateCollection = _dateCollection![(indexPath as NSIndexPath).row]
        
        let calendar = Calendar.current() //Calendar type
        
        let dateComponents = calendar.components([.day, .month, .year], from: cellDateCollection["date"] as! Date)
        
        let dateFormatter = DateFormatter()
        
        cell._dailyEntryDateView._monthLabel.text = dateFormatter.monthSymbols[dateComponents.month! - 1].lowercased()
        cell._dailyEntryDateView._dayLabel.text = String(dateComponents.day!)
        
        cell._delegate = self
        
        cell._dayEntriesCollectionView.reloadData()
        
        return cell
    }
    
   /* func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let graphHeaderTransformValue :CGFloat = (1.0 / _weeklyBarGraphView.bounds.height) * 2
        
        setAnchorPoint(CGPoint(x: 0.5, y: 1), view: _weeklyBarGraphView)
        let xScale = _weeklyBarGraphView.transform.a
        let yScale = _weeklyBarGraphView.transform.d
        
        if scrollView.contentOffset.y > _lastScrollOffset.y {
           // _weeklyBarGraphView.transform = CGAffineTransformMakeScale(xScale - graphHeaderTransformValue, yScale - graphHeaderTransformValue)
        } else {
           // _weeklyBarGraphView.transform = CGAffineTransformMakeScale(xScale + graphHeaderTransformValue, yScale + graphHeaderTransformValue)
        }
        
        _lastScrollOffset = scrollView.contentOffset
    }
    
    func setAnchorPoint(_ anchorPoint: CGPoint, view: UIView){
        let oldOrigin = view.frame.origin
        view.layer.anchorPoint = anchorPoint
        let newOrigin = view.frame.origin
        
        let transition = CGPoint (x: newOrigin.x - oldOrigin.x, y: newOrigin.y - oldOrigin.y)
        
        view.center = CGPoint (x: view.center.x - transition.x, y: view.center.y - transition.y)
    }*/
}

// MARK: - DailyInformationTableViewCellProtocol
extension InformationViewController :DailyInformationTableViewCellProtocol {
    func getEntriesForDay(_ cell: DailyInformationTableViewCell) -> [Entry] {
        let indexPathForCell = _informationTableView.indexPath(for: cell)
        
        let dict = _dateCollection![((indexPathForCell as NSIndexPath?)?.row)!]
        
        let entries = dict["entries"] as! [Entry]
        
        return entries
    }
    
    func promptEntryDeletion(_ cellToDeleteFrom: DailyInformationTableViewCell, index :Int) {
        _cellToDeleteFrom = cellToDeleteFrom
        _indexOfEntryToDelete = index
        
        let alert = UIAlertController(title: "Delete Entry", message: "Are you sure you want to delete this entry?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (alert: UIAlertAction!) in
            self.onEntryDeletion()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func onEntryDeletion() {
        let indexPath = _informationTableView.indexPath(for: _cellToDeleteFrom)
        
        var dict = _dateCollection![(indexPath! as NSIndexPath).row]
        
        var entries = dict["entries"] as! [Entry]
        
        let entry = entries[_indexOfEntryToDelete]
        
        let dateOfEntry = entry.date
        
        entry.deleteEntry()
        
        entries.remove(at: _indexOfEntryToDelete)
        
        _dateCollection![(indexPath! as NSIndexPath).row]["entries"] = entries
        
        let indexPathToDelete = IndexPath(item: _indexOfEntryToDelete, section: 0)
        
        _cellToDeleteFrom._dayEntriesCollectionView.deleteItems(at: [indexPathToDelete])
        
        if entries.count == 0 {
            _dateCollection?.remove(at: (indexPath! as NSIndexPath).row)
            
            _informationTableView.deleteRows(at: [indexPath!], with: .fade)
        }
        
        _informationViewControllerDelegate?.entryWasDeleted(dateOfEntry!)
    }
}
