//
//  ConnectTableViewCell.swift
//  H2O
//
//  Created by Gregory Sapienza on 12/9/16.
//  Copyright © 2016 Skyscrapers.IO. All rights reserved.
//

import UIKit

class ConnectTableViewCell: UITableViewCell {
    var iconImageView :UIImageView!
    
    var titleLabel :UILabel!
    
    private var buttonBackgroundView :UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        buttonBackgroundView = generateButtonBackground()
        iconImageView = generateIconImageView()
        titleLabel = generateTitleLabel()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        selectionStyle = .none
        backgroundColor = UIColor.clear
        buttonBackgroundView.layer.cornerRadius = bounds.height / 2
        
        layout()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            buttonBackgroundView.backgroundColor = UIColor(colorLiteralRed: 24/255, green: 179/255, blue: 106/255, alpha: 1)
        } else {
            buttonBackgroundView.backgroundColor = StandardColors.primaryColor.withAlphaComponent(0.1)
        }
    }

    private func layout() {
        let iconImageViewWidth :CGFloat = 35
        guard let textSize = titleLabel.text?.size(attributes: [NSFontAttributeName : titleLabel.font]) else { //Gets size of text based on font and string
            fatalError("Text size is nil.")
        }
        
        //---Button Background---//
        
        addSubview(buttonBackgroundView)
        
        buttonBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: buttonBackgroundView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: buttonBackgroundView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 20))
        addConstraint(NSLayoutConstraint(item: buttonBackgroundView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -20))
        addConstraint(NSLayoutConstraint(item: buttonBackgroundView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        
        //---Icon Image View---//
        
        buttonBackgroundView.addSubview(iconImageView)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        buttonBackgroundView.addConstraint(NSLayoutConstraint(item: iconImageView, attribute: .centerY, relatedBy: .equal, toItem: buttonBackgroundView, attribute: .centerY, multiplier: 1, constant: 0))
        buttonBackgroundView.addConstraint(NSLayoutConstraint(item: iconImageView, attribute: .right, relatedBy: .lessThanOrEqual, toItem: buttonBackgroundView, attribute: .centerX, multiplier: 1, constant: iconImageViewWidth / 2 - textSize.width / 2 - 5))
        buttonBackgroundView.addConstraint(NSLayoutConstraint(item: iconImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 35))
        buttonBackgroundView.addConstraint(NSLayoutConstraint(item: iconImageView, attribute: .height, relatedBy: .equal, toItem: iconImageView, attribute: .height, multiplier: 1, constant: 0))
        
        //---Title Label---//
        
        buttonBackgroundView.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        buttonBackgroundView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: buttonBackgroundView, attribute: .centerY, multiplier: 1, constant: 0))
        buttonBackgroundView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .lessThanOrEqual, toItem: buttonBackgroundView, attribute: .centerX, multiplier: 1, constant: iconImageViewWidth / 2 - textSize.width / 2 + 5))
        buttonBackgroundView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: buttonBackgroundView, attribute: .trailing, multiplier: 1, constant: -20))
    }
}

// MARK: - Private Generators
private extension ConnectTableViewCell {
    func generateButtonBackground() -> UIView {
        let view = UIView()
        
        view.backgroundColor = StandardColors.primaryColor.withAlphaComponent(0.1)
        
        return view
    }
    
    func generateIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }
    
    func generateTitleLabel() -> UILabel {
        let label = UILabel()
        
        label.textColor = StandardColors.primaryColor
        label.font = StandardFonts.regularFont(size: 25)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        
        return label
    }
}
