//
//  DailyInformationTableViewCell.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/22/16.
//  Copyright © 2016 City Pixels. All rights reserved.
//

import UIKit

protocol DailyInformationTableViewCellProtocol {
    /// Gets array of entries for the date in this cell
    ///
    /// - parameter dayIndex: The index of the day in day entries.
    ///
    /// - returns: Array of entries associated with the cell
    func getEntriesForDay(dayIndex: Int) -> [Entry]?
    
    
    /// Get the current state of the information view controller.
    ///
    /// - returns: Viewing, selecting or delete state.
    func getState() -> InformationViewController.State
    
    /// Entry has been selected in selection state.
    ///
    /// - parameter dayIndex: The index of the day in day entries.
    /// - parameter entryIndex: Index of entry selected within this cell.
    func entrySelected(dayIndex: Int, entryIndex: Int)
    
    /// Entry has been deselected in entry state.
    ///
    /// - parameter dayIndex: The index of the day in day entries.
    /// - parameter entryIndex: Index of entry selected within this cell.
    func entryDeselected(dayIndex: Int, entryIndex: Int)
    
    /// Return if the entry represented by an index has been previously marked as selected.
    ///
    /// - parameter dayIndex: The index of the day in day entries.
    /// - parameter entryIndex: Index of entry in collection view.
    ///
    /// - returns: True if entry has been selected.
    func isEntrySelected(dayIndex: Int, entryIndex: Int) -> Bool
}

class DailyInformationTableViewCell: UITableViewCell {

    //MARK: - Public iVars
    
    /// Date view displaying the date
    @IBOutlet weak var dailyEntryDateView: DailyEntryDateView!
    
    /// Collection view displaying the entries
    @IBOutlet weak var dayEntriesCollectionView: UICollectionView!
    
    /// Delegate to communicate with this cell and the view controller containing it
    var delegate: DailyInformationTableViewCellProtocol?
    
    /// Essentially the index path row number for this cell. Used to track the cell index because using 'indexPath row of cell' from the table view can be unreliable when reusing cells.
    var dayIndex: Int!
    
    //MARK: - Setup
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dayEntriesCollectionView.delegate = self
        dayEntriesCollectionView.dataSource = self
    }
    
    //MARK: - Internal
    
    /// Refreshes the state for each currently visible cell.
    func refreshCells() {
        for cell in dayEntriesCollectionView.visibleCells {
            guard let cell = cell as? InformationEntryInfoCollectionViewCell else {
                fatalError("Cell is wrong type")
            }
            
            refreshStateForCell(cell: cell)
        }
    }
    
    /// Sets cell visual state to match the state of the parent view controller.
    ///
    /// - parameter cell: Cell to set visual state.
    func refreshStateForCell(cell: InformationEntryInfoCollectionViewCell) {
        if let delegate = delegate {
            switch delegate.getState() {
            case InformationViewController.State.viewing:
                WobbleAnimation.stop(view: cell)
                cell.animateBorder(hidden: true, animated: false)
                break
            case InformationViewController.State.selecting(_):
                WobbleAnimation.start(view: cell, onSide: .left)
                break
            default:
                break
            }
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension DailyInformationTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let entriesForDay = delegate?.getEntriesForDay(dayIndex: dayIndex) else {
            return 0
        }
        
        return entriesForDay.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = bounds.height * 0.7 //70% the height of the cell
        
        return CGSize(width: size, height: size)
    }
    
    ///Entry cells
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ENTRY_INFO_CELL", for: indexPath) as? InformationEntryInfoCollectionViewCell else {
            fatalError("Cell is not correct type")
        }
        
        guard let entriesForDay = delegate?.getEntriesForDay(dayIndex: dayIndex) else {
            fatalError("Entries not found for day.")
        }
        
        let entry = entriesForDay[(indexPath as NSIndexPath).row] //Get an entry from the delegate
        
        let entryTimeDate = entry.date //The date of the entry
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a" //Format into hour, minute, AM/PM
        
        let timeString = dateFormatter.string(from: entryTimeDate as Date) //Get the correct string from the date
        
        cell.timeLabel.text = timeString
        
        let entryAmount = entry.amount.stringValue + standardUnit.rawValue //Entry amount
       
        cell.entryAmountLabel.text = entryAmount
        
        refreshStateForCell(cell: cell) //Refresh state to animate if selecting.
        
        if let delegate = self.delegate {
            if delegate.isEntrySelected(dayIndex: dayIndex, entryIndex: indexPath.item) {
                cell.animateBorder(hidden: false, animated: false) //If the cell was selected then highlight it.
            } else {
                cell.animateBorder(hidden: true, animated: false) //If it has not been selected make sure it is not highlighted.
            }
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? InformationEntryInfoCollectionViewCell else {
            fatalError("Cell is incorrect type")
        }
        
        if let delegate = delegate {
            switch delegate.getState() {
            case InformationViewController.State.selecting(_):
                if delegate.isEntrySelected(dayIndex: dayIndex, entryIndex: indexPath.item) {
                    delegate.entryDeselected(dayIndex: dayIndex, entryIndex: indexPath.item)
                    cell.animateBorder(hidden: true, animated: true) //If the cell was deselected then remove the highlight.
                } else {
                    delegate.entrySelected(dayIndex: dayIndex, entryIndex: indexPath.item)
                    cell.animateBorder(hidden: false, animated: true) //If it has not been selected then highlight the cell.
                }
                break
            default:
                break
            }
        }
    }
}
