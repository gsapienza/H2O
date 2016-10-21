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
    func getEntriesForDay(cell :DailyInformationTableViewCell) -> [Entry]
    
    
    /// Prompt the user to confirm deletion of a particular entry
    ///
    /// - parameter cellToDeleteFrom: Cell to delete entry from
    /// - parameter index:            Index of entry to delete
    func promptEntryDeletion(cellToDeleteFrom: DailyInformationTableViewCell, index :Int)
    
    
    /// Get the current state of the information view controller.
    ///
    /// - returns: Viewing, selecting or delete state.
    func getState() -> InformationViewController.State
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
    
    /// Arrange cell view for selecting mode.
    func beginSelecting() {
        for cell in dayEntriesCollectionView.visibleCells {
            guard let cell = cell as? InformationEntryInfoCollectionViewCell else {
                return
            }
            
            WobbleAnimation.start(view: cell, onSide: .left)
            if let longPressGestureRecognizer = cell.longPressGestureRecognizer {
                longPressGestureRecognizer.isEnabled = false
            }
        }
    }
    
    /// Arrange cell view when ending selection mode.
    func endSelecting() {
        for cell in dayEntriesCollectionView.visibleCells {
            guard let cell = cell as? InformationEntryInfoCollectionViewCell else {
                return
            }
            
            WobbleAnimation.stop(view: cell)
            if let longPressGestureRecognizer = cell.longPressGestureRecognizer {
                longPressGestureRecognizer.isEnabled = true
            }
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension DailyInformationTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (delegate?.getEntriesForDay(cell: self).count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = bounds.height * 0.7 //70% the height of the cell
        
        return CGSize(width: size, height: size)
    }
    
    ///Entry cells
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ENTRY_INFO_CELL", for: indexPath) as! InformationEntryInfoCollectionViewCell
        
        let entry = delegate?.getEntriesForDay(cell: self)[(indexPath as NSIndexPath).row] //Get an entry from the delegate
        
        let entryTimeDate = entry!.date //The date of the entry
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a" //Format into hour, minute, AM/PM
        
        let timeString = dateFormatter.string(from: entryTimeDate as Date) //Get the correct string from the date
        
        cell.timeLabel.text = timeString
        
        let entryAmount = entry!.amount.stringValue + standardUnit.rawValue //Entry amount
       
        cell.entryAmountLabel.text = entryAmount
        
        cell.delegate = self //Set cell delegate so the user can interact with that cell and actions will call back here
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? InformationEntryInfoCollectionViewCell else {
            return
        }
        
        if let delegate = delegate {
            switch delegate.getState() {
            case InformationViewController.State.viewing:
                WobbleAnimation.stop(view: cell)
                if let longPressGestureRecognizer = cell.longPressGestureRecognizer {
                    longPressGestureRecognizer.isEnabled = true
                }
                break
            case InformationViewController.State.selecting(_):
                WobbleAnimation.start(view: cell, onSide: .left)
                if let longPressGestureRecognizer = cell.longPressGestureRecognizer {
                    longPressGestureRecognizer.isEnabled = false
                }
                break
            default:
                break
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? InformationEntryInfoCollectionViewCell else {
            return
        }
        
        if let delegate = delegate {
            switch delegate.getState() {
            case let InformationViewController.State.selecting(selectedRows):
                
                cell.animateBorder(toValue: 30, isDelegate: false)
                break
            default:
                break
            }
        }
    }
}

// MARK: - InformationEntryInfoCollectionViewCellProtocol
extension DailyInformationTableViewCell :InformationEntryInfoCollectionViewCellProtocol {
    func promptEntryDeletion(cell: InformationEntryInfoCollectionViewCell) {
        let indexPath = dayEntriesCollectionView.indexPath(for: cell)
                
        delegate?.promptEntryDeletion(cellToDeleteFrom: self, index: (indexPath! as NSIndexPath).row)
    }
}
