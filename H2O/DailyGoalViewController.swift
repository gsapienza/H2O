//
//  DailyGoalViewController.swift
//  H2O
//
//  Created by Gregory Sapienza on 11/17/16.
//  Copyright © 2016 Midnite. All rights reserved.
//

import UIKit

class DailyGoalViewController: UIViewController, BoardingProtocol {
    
    //MARK: - Strings
    
    /// String for title label.
    private static let titleString = "set_your_daily_goal".localized
    
    /// String for next button.
    private static let nextButtonString = "next_navigation_item".localized
    
    //MARK: - Public iVars
    
    /// First label.
    var titleLabel :GSMagicTextLabel {
        get {
            return _titleLabel
        }
    }
    
    //MARK: - Private iVars
    
    /// Backing label to title label so we can use lazy loading. Lazy loading a var declared in a protocol leads to a Seg Fault 11. Bug filed here: https://bugs.swift.org/browse/SR-1825
    private lazy var _titleLabel :GSMagicTextLabel = self.generateTitleLabel(text: titleString)
    
    /// View for preset changer text field.
    private lazy var presetChangerView :PresetValueChangerView = self.generateGoalPresetChangerView()
    
    //MARK: - Public
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var navigationItem = self.navigationItem
        configureNavigationItem(navigationItem: &navigationItem, title: "", rightBarButtonItemTitle: DailyGoalViewController.nextButtonString)
        
        titleLabel.text = DailyGoalViewController.titleString
        
        presetChangerView.presetValueTextField.becomeFirstResponder()
        
        //---Title Label---//
        
        view.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 80))
        view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50))
        
        //--Preset Value Changer---//
        
        view.addSubview(presetChangerView)
        
        presetChangerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: presetChangerView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: presetChangerView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: -50))
        view.addConstraint(NSLayoutConstraint(item: presetChangerView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200))
        view.addConstraint(NSLayoutConstraint(item: presetChangerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 150))
    }
    
    //MARK: - BoardingProtocol
    
    func animateIn(completion: @escaping (Bool) -> Void) {
        let duration = 0.5
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .allowUserInteraction, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0, animations: { 
                self.presetChangerView.transform = CGAffineTransform(scaleX: 0, y: 0)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: duration, animations: {
                self.presetChangerView.transform = CGAffineTransform.identity
            })
        }) { (Bool) in
            completion(true)
        }
    }
    
    func animateOut(completion: @escaping (Bool) -> Void) {
        UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction, animations: {
            self.presetChangerView.transform = CGAffineTransform(scaleX: 0, y: 0)
        }) { (Bool) in
            completion(true)
        }
    }
    
    func onRightBarButton() {
        if let presetText = presetChangerView.presetValueTextField.text {
            guard let presetValue = Float(presetText) else {
                GSAnimations.invalid(layer: presetChangerView.layer, completion: { (Bool) in
                })
                return
            }
            
            if presetValue != 0 {
                AppUserDefaults.setDailyGoalValue(goal: presetValue)
                let connectViewController = ConnectViewController()
                navigationController?.pushViewController(connectViewController, animated: true)
            } else {
                GSAnimations.invalid(layer: presetChangerView.layer, completion: { (Bool) in
                })
            }
        }
    }
}

// MARK: - Private Generators
private extension DailyGoalViewController {
    func generateGoalPresetChangerView() -> PresetValueChangerView {
        let view = PresetValueChangerView(fontSize: 50)
        view.presetValueTextField.placeholder = "64"
        view.toolbarEnabled = false
        
        return view
    }
}
