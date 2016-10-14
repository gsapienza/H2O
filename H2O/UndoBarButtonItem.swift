//
//  UndoBarButtonItem.swift
//  H2O
//
//  Created by Gregory Sapienza on 10/14/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

class UndoBarButtonItem: UIBarButtonItem {
    
    /// View that will be contained in the custom view. This will contain all subviews because it is easier to animate because its lifecycle is more predictable than custom view.
    private var view :UIView!
    
    /// Leading constraint for view contained in custom view.
    private var viewLeadingConstraint :NSLayoutConstraint!
    
    /// Image view to display undo icon.
    private var undoImageView :UIImageView!
    
    /// Text label to display undo text.
    private var undoTextLabel :UILabel!
    
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
        
        if !enabled {
            viewLeadingConstraint.constant = -100
            customView?.layoutIfNeeded()
        }
    }
    
    //MARK: - Private
    
    private func initialize() {
        customView = UIView()
        view = generateCustomView()
        undoImageView = generateUndoImageView()
        undoTextLabel = generateUndoTextLabel()
        
        layout()
    }
    
    private func layout() {
        //View
        customView?.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        customView?.addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: customView, attribute: .top, multiplier: 1, constant: 0))
        viewLeadingConstraint = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: customView, attribute: .leading, multiplier: 1, constant: 0)
        customView?.addConstraint(viewLeadingConstraint)
        customView?.addConstraint(NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: customView, attribute: .trailing, multiplier: 1, constant: 0))
        customView?.addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: customView, attribute: .bottom, multiplier: 1, constant: 0))


        //Undo Image View
        
        view?.addSubview(undoImageView!)
        
        let undoImageViewWidth :CGFloat = 22
        let undoImageViewHeight :CGFloat = 25
        
        undoImageView?.translatesAutoresizingMaskIntoConstraints = false
        
        view?.addConstraint(NSLayoutConstraint(item: undoImageView!, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0))
        view?.addConstraint(NSLayoutConstraint(item: undoImageView!, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view?.addConstraint(NSLayoutConstraint(item: undoImageView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: undoImageViewWidth))
        view?.addConstraint(NSLayoutConstraint(item: undoImageView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: undoImageViewHeight))
        
        //Undo Text Label
        
        view.addSubview(undoTextLabel!)
        
        let undoImageViewDistanceFromUndoLabel :CGFloat = 5
        
        undoTextLabel?.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: undoTextLabel!, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: undoTextLabel!, attribute: .leading, relatedBy: .equal, toItem: undoImageView!, attribute: .trailing, multiplier: 1, constant: undoImageViewDistanceFromUndoLabel))
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
            self.view.alpha = 1
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
            self.view.alpha = 0
            customView.layoutIfNeeded()
        }
    }
}

// MARK: - Private Generators
private extension UndoBarButtonItem {
    
    /// Generates a custom view for bar button.
    ///
    /// - returns: Custom view to display in bar button.
    func generateCustomView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        
        return view
    }
    
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
        label.text = undo_navigation_item_localized_string
        label.textColor = UIColor.white
        
        return label
    }
}
