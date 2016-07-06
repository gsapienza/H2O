//
//  DailyInformationTableViewCell.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/22/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

protocol DailyInformationTableViewCellProtocol {
    func getEntriesForDay( cell :DailyInformationTableViewCell) -> [Entry]
    func promptEntryDeletion( cellToDeleteFrom: DailyInformationTableViewCell, index :Int)
}

class DailyInformationTableViewCell: UITableViewCell {

    @IBOutlet weak var dailyEntryDateView: DailyEntryDateView!
    @IBOutlet weak var dayEntriesCollectionView: UICollectionView!
    
    var delegate :DailyInformationTableViewCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dayEntriesCollectionView.delegate = self
        dayEntriesCollectionView.dataSource = self
    }

}

extension DailyInformationTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView( _ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (delegate?.getEntriesForDay(cell: self).count)!
    }
    
    func collectionView( _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = bounds.height * 0.7
        
        return CGSize(width: size, height: size)
    }
    
    func collectionView( _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ENTRY_INFO_CELL", for: indexPath) as! InformationEntryInfoCollectionViewCell
        
        let entry = delegate?.getEntriesForDay(cell: self)[(indexPath as NSIndexPath).row]
        let entryTimeDate = entry!.date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        let timeString = dateFormatter.string(from: entryTimeDate! as Date)
        
        cell.timeLabel.text = timeString
        
        let entryAmount = String(entry!.amount!) + Constants.standardUnit.rawValue
       
        cell.entryAmountLabel.text = entryAmount
        
        cell.delegate = self
        
        return cell
    }
}

extension DailyInformationTableViewCell :InformationEntryInfoCollectionViewCellProtocol {
    func promptEntryDeletion( cell: InformationEntryInfoCollectionViewCell) {
        let indexPath = dayEntriesCollectionView.indexPath(for: cell)
                
        delegate?.promptEntryDeletion(cellToDeleteFrom: self, index: (indexPath! as NSIndexPath).row)
    }
}
