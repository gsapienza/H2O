//
//  DailyInformationTableViewCell.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/22/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

protocol DailyInformationTableViewCellProtocol {
    /// Gets array of entries for the date in this cell
    ///
    /// - parameter cell: Cell to to get entries for
    ///
    /// - returns: Array of entries associated with the cell
    func getEntriesForDay(cell :DailyInformationTableViewCell) -> [Entry]?
    
    
    /// Prompt the user to confirm deletion of a particular entry
    ///
    /// - parameter cellToDeleteFrom: Cell to delete entry from
    /// - parameter index:            Index of entry to delete
    func promptEntryDeletion(cellToDeleteFrom: DailyInformationTableViewCell, index :Int)
    
    
    /// Get the current state of the information view controller.
    ///
    /// - returns: Viewing, selecting or delete state.
    func getState() -> InformationViewController.State
    
    /// Entry has been selected in selection state.
    ///
    /// - parameter cell:       Cell selected.
    /// - parameter entryIndex: Index of entry selected within this cell.
    func entrySelected(cell :DailyInformationTableViewCell, entryIndex :Int)
}

class DailyInformationTableViewCell: UITableViewCell {

    //MARK: - Public iVars
    
    /// Date view displaying the date
    @IBOutlet weak var dailyEntryDateView: DailyEntryDateView!
    
    /// Collection view displaying the entries
    @IBOutlet weak var dayEntriesCollectionView: UICollectionView!
    
    /// Delegate to communicate with this cell and the view controller containing it
    var delegate :DailyInformationTableViewCellProtocol?
    
    //MARK: - Setup
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dayEntriesCollectionView.delegate = self
        dayEntriesCollectionView.dataSource = self
    }
    
    //MARK: - Internal
    
    /// Sets cell visual state to match the state of the parent view controller.
    ///
    /// - parameter cell: Cell to set visual state.
    func refreshStateForCell(cell :InformationEntryInfoCollectionViewCell) {
        if let delegate = delegate {
            switch delegate.getState() {
            case InformationViewController.State.viewing:
                WobbleAnimation.stop(view: cell)
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
        guard let entriesForDay = delegate?.getEntriesForDay(cell: self) else {
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
        
        guard let entriesForDay = delegate?.getEntriesForDay(cell: self) else {
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

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? InformationEntryInfoCollectionViewCell else {
            return
        }
        
        if let delegate = delegate {
            switch delegate.getState() {
            case let InformationViewController.State.selecting(selectedRows):
                cell.animateBorder(toValue: 30)
                delegate.entrySelected(cell: self, entryIndex: indexPath.item)
                break
            default:
                break
            }
        }
    }
}
