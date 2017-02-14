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

    /// Image view representing setting.
    let decorationView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    /// Label for setting
    let titleLabel: UILabel = {
        let label = UILabel()
    
        label.textColor = StandardColors.primaryColor
    
        return label
    }()
    
    // MARK: - Private iVars

    /// Control for setting.
    private let controlView = UISwitch()
    
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
        
        backgroundColor = StandardColors.standardSecondaryColor
        
        var layout = SettingLayout(decoration: decorationView, title: titleLabel, control: controlView, controlSize: controlView.bounds.size)
        layout.layout(in: bounds)
    }
    
    // MARK: - Private

    private func customInit() {
        selectionStyle = .none
        
        addSubview(decorationView)
        addSubview(titleLabel)
        addSubview(controlView)
    }
}
