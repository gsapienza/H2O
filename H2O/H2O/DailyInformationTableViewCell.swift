//
//  DailyInformationTableViewCell.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/22/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

protocol DailyInformationTableViewCellProtocol {
    func getEntriesForDay(_ cell :DailyInformationTableViewCell) -> [Entry]
    func promptEntryDeletion(_ cellToDeleteFrom: DailyInformationTableViewCell, index :Int)
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (_delegate?.getEntriesForDay(self).count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = bounds.height * 0.7
        
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ENTRY_INFO_CELL", for: indexPath) as! InformationEntryInfoCollectionViewCell
        
        let entry = _delegate?.getEntriesForDay(self)[(indexPath as NSIndexPath).row]
        let entryTimeDate = entry!.date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        let timeString = dateFormatter.string(from: entryTimeDate! as Date)
        
        cell._timeLabel.text = timeString
        
        let entryAmount = String(entry!.amount!) + Constants.standardUnit.rawValue
       
        cell._entryAmountLabel.text = entryAmount
        
        cell._delegate = self
        
        return cell
    }
}

extension DailyInformationTableViewCell :InformationEntryInfoCollectionViewCellProtocol {
    func promptEntryDeletion(_ cell: InformationEntryInfoCollectionViewCell) {
        let indexPath = _dayEntriesCollectionView.indexPath(for: cell)
                
        _delegate?.promptEntryDeletion(self, index: (indexPath! as NSIndexPath).row)
    }
}
