//
//  UndoBarButtonItem.swift
//  H2O
//
//  Created by Gregory Sapienza on 10/14/16.
//  Copyright © 2016 Skyscrapers.IO. All rights reserved.
//

import UIKit

class UndoBarButtonItem: UIBarButtonItem {
    
    /// View that will be contained in the custom view. This will contain all subviews because it is easier to animate because its lifecycle is more predictable than custom view.
    private var button :UndoButton!
    
    /// Leading constraint for view contained in custom view.
    private var viewLeadingConstraint :NSLayoutConstraint!
    
    override init() {
        super.init()
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    /// Init an enabled or disabled bar button.
    ///
    /// - parameter enabled: If enabled the bar button will display and be active otherwise it will be hidden.
    init(enabled :Bool) {
        super.init()
        initialize()
        
        guard let customView = self.customView else {
            print("Custom View is nil.")
            return
        }
        
        if !enabled {
            viewLeadingConstraint.constant = -customView.bounds.width
            customView.layoutIfNeeded()
        }
    }
    
    //MARK: - Public
    
    func addTarget(target :Any?, action :Selector) {
        button.addTarget(target, action: action, for: .touchUpInside)
    }
    
    //MARK: - Private
    
    private func initialize() {
        customView = UIView()
        button = UndoButton()
        
        layout()
    }
    
    private func layout() {
        guard let customView = self.customView else {
            print("Custom View is nil.")
            return
        }
        
        customView.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
        
        //Button
        
        customView.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        customView.addConstraint(NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: customView, attribute: .top, multiplier: 1, constant: 0))
        viewLeadingConstraint = NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: customView, attribute: .leading, multiplier: 1, constant: 0)
        customView.addConstraint(viewLeadingConstraint)
        customView.addConstraint(NSLayoutConstraint(item: button, attribute: .trailing, relatedBy: .equal, toItem: customView, attribute: .trailing, multiplier: 1, constant: 0))
        customView.addConstraint(NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: customView, attribute: .bottom, multiplier: 1, constant: 0))
    }
    
    //MARK: - Public
    
    /// Enable bar button by making it active and animating in place.
    func enable() {
        isEnabled = true
        
        guard let customView = self.customView else {
            print("Custom View is nil")
            return
        }
        
        viewLeadingConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.button.alpha = 1
            customView.layoutIfNeeded()
        }
    }
    
    /// Disable bar button by making it inactive and animating out of place.
    func disable() {
        isEnabled = false
        
        guard let customView = self.customView else {
            print("Custom View is nil")
            return
        }
        
        viewLeadingConstraint.constant = -customView.frame.width
        UIView.animate(withDuration: 0.3) {
            self.button.alpha = 0
            customView.layoutIfNeeded()
        }
    }
}

class UndoButton :UIButton {
    /// Image view to display undo icon.
    private var undoImageView :UIImageView!
    
    /// Text label to display undo text.
    private var undoTextLabel :UILabel!
    
    /// Value determining if layout subviews has already been called once.
    private var layoutSubviewsCalledOnce = false
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                alpha = 0.5
            } else {
                alpha = 1
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !layoutSubviewsCalledOnce { //Called once when this function is called. When animating this function will be called again and running the following code will make things look wacky.
            undoImageView = generateUndoImageView()
            undoTextLabel = generateUndoTextLabel()
            
            layout()
            
            layoutSubviewsCalledOnce = true
        }
    }
    
    //MARK: - Private
    
    private func layout() {
        //Undo Image View
        
        let undoImageViewWidth :CGFloat = 22
        let undoImageViewHeight :CGFloat = 25
        let undoImageViewToTextLabelSpacing :CGFloat = 5
        
        undoImageView.frame = CGRect(x: 0, y: bounds.height / 2 - undoImageViewHeight / 2, width: undoImageViewWidth, height: undoImageViewHeight)
        addSubview(undoImageView!)
        
        //Undo Text Label
        
        undoTextLabel.frame = CGRect(x: undoImageViewWidth + undoImageViewToTextLabelSpacing, y: 0, width: bounds.size.width - undoImageViewWidth - undoImageViewToTextLabelSpacing, height: bounds.height)
        addSubview(undoTextLabel!)
    }
}

// MARK: - Private Generators
private extension UndoButton {
    /// Generates an image view to display an undo icon.
    ///
    /// - returns: Image view representing undo icon.
    func generateUndoImageView() -> UIImageView {
        let image = UIImage(assetIdentifier: .undoButtonItem)
        let imageView = UIImageView(image: image)
        
        return imageView
    }
    
    /// Generates a text label to display undo text.
    ///
    /// - returns: Text label displaying undo text.
    func generateUndoTextLabel() -> UILabel {
        let label = UILabel()
        label.text = "undo_navigation_item".localized
        label.textColor = UIColor.white
        
        return label
    }
}
