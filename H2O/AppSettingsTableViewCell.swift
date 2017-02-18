//
//  AppSettingsTableViewCell.swift
//  H2O
//
//  Created by Gregory Sapienza on 2/12/17.
//  Copyright © 2017 Skyscrapers.IO. All rights reserved.
//

import UIKit

class AppSettingsTableViewCell: UITableViewCell {
    
    // MARK: - Public iVars

    var setting: Setting? {
        didSet {
            //---Title Label---//
            
            titleLabel.text = setting?.title
            
            //---Decorator---//
            
            if let imageName = setting?.imageName {
                decorationView.image = UIImage(named: imageName)
            }
        }
    }
    
    /// Image view representing setting.
    private let decorationView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    /// Label for setting
    private let titleLabel: UILabel = {
        let label = UILabel()
    
        label.textColor = StandardColors.primaryColor
    
        return label
    }()
    
    // MARK: - Private iVars

    /// Control for setting.
    var controlView: UISwitch = UISwitch()
    
    // MARK: - Public

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //---Layout---//
        
        var layout = SettingLayout(decoration: decorationView, title: titleLabel, control: controlView, controlSize: controlView.bounds.size)
        layout.layout(in: bounds)
        
        //---View---//
        
        backgroundColor = StandardColors.standardSecondaryColor
    }
    
    // MARK: - Private

    private func customInit() {
        //---Seperator---//
        
        selectionStyle = .none
        
        //---View---//
        
        addSubview(decorationView)
        addSubview(titleLabel)
        addSubview(controlView)
    }
}