//
//  DailyInformationTableViewCell.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/22/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

protocol DailyInformationTableViewCellProtocol {
    func getEntriesForDay(cell :DailyInformationTableViewCell) -> [Entry]
    func promptEntryDeletion(entry :Entry)
}

class DailyInformationTableViewCell: UITableViewCell {

    @IBOutlet weak var _dailyEntryDateView: DailyEntryDateView!
    @IBOutlet weak var _dayEntriesCollectionView: UICollectionView!
    
    var _delegate :DailyInformationTableViewCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _dayEntriesCollectionView.delegate = self
        _dayEntriesCollectionView.dataSource = self
    }

}

extension DailyInformationTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (_delegate?.getEntriesForDay(self).count)!
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = bounds.height * 0.7
        
        return CGSizeMake(size, size)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ENTRY_INFO_CELL", forIndexPath: indexPath) as! InformationEntryInfoCollectionViewCell
        
        let entry = _delegate?.getEntriesForDay(self)[indexPath.row]
        let entryTimeDate = entry!.date
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        let timeString = dateFormatter.stringFromDate(entryTimeDate!)
        
        cell._timeLabel.text = timeString
        
        let entryAmount = String(entry!.amount!) + Constants.standardUnit.rawValue
        
        cell._entryAmountLabel.text = entryAmount
        
        cell._delegate = self
        
        return cell
    }
}

extension DailyInformationTableViewCell :InformationEntryInfoCollectionViewCellProtocol {
    func promptEntryDeletion(cell: InformationEntryInfoCollectionViewCell) {
        let indexPath = _dayEntriesCollectionView.indexPathForCell(cell)
        
        let entry = _delegate?.getEntriesForDay(self)[indexPath!.row]
        
        _delegate?.promptEntryDeletion(entry!)
    }
}
