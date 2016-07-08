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
}

class DailyInformationTableViewCell: UITableViewCell {

    /// Date view displaying the date
    @IBOutlet weak var dailyEntryDateView: DailyEntryDateView!
    
    /// Collection view displaying the entries
    @IBOutlet weak var dayEntriesCollectionView: UICollectionView!
    
    /// Delegate to communicate with this cell and the view controller containing it
    var delegate :DailyInformationTableViewCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dayEntriesCollectionView.delegate = self
        dayEntriesCollectionView.dataSource = self
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
        
        let timeString = dateFormatter.string(from: entryTimeDate! as Date) //Get the correct string from the date
        
        cell.timeLabel.text = timeString
        
        let entryAmount = String(entry!.amount!) + Constants.standardUnit.rawValue //Entry amount
       
        cell.entryAmountLabel.text = entryAmount
        
        cell.delegate = self //Set cell delegate so the user can interact with that cell and actions will call back here
        
        return cell
    }
}

// MARK: - InformationEntryInfoCollectionViewCellProtocol
extension DailyInformationTableViewCell :InformationEntryInfoCollectionViewCellProtocol {
    func promptEntryDeletion(cell: InformationEntryInfoCollectionViewCell) {
        let indexPath = dayEntriesCollectionView.indexPath(for: cell)
                
        delegate?.promptEntryDeletion(cellToDeleteFrom: self, index: (indexPath! as NSIndexPath).row)
    }
}
