//
//  WelcomeViewController.swift
//  H2O
//
//  Created by Gregory Sapienza on 11/17/16.
//  Copyright © 2016 Skyscrapers.IO. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController, BoardingProtocol, NavigationThemeProtocol {

    //MARK: - Strings
    
    /// String for title label.
    private static let titleString = "Welcome To"
    
    /// String for secondary title label.
    private static let secondaryTitleString = "H2O"
    
    /// String for next button.
    private static let nextButtonString = "Next"
    
    //MARK: - Public iVars
    
    /// First label.
    var titleLabel :GSMagicTextLabel {
        get {
            return _titleLabel
        }
    }
    
    var navigationThemeDidChangeHandler: ((NavigationTheme) -> Void)?
    
    //MARK: - Private iVars
    
    /// Backing label to title label so we can use lazy loading. Lazy loading a var declared in a protocol leads to a Seg Fault 11. Bug filed here: https://bugs.swift.org/browse/SR-1825
    private lazy var _titleLabel :GSMagicTextLabel = self.generateTitleLabel(text: WelcomeViewController.titleString)
    
    /// Second label.
    private lazy var h2OLabel :UILabel = {
        let label = UILabel()

        label.text = secondaryTitleString
        label.font = StandardFonts.regularFont(size: 54)
        label.textAlignment = .center
        label.textColor = StandardColors.primaryColor
        
        return label
    }()
    
    /// View displaying water bottle animation.
    private lazy var waterBottleView :WaterBottleView = {
        let view = WaterBottleView()
        
        return view
    }()
    
    //MARK: - Public
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //---Navigation Item---//
        
        var navigationItem = self.navigationItem
        configureNavigationItem(navigationItem: &navigationItem, title: "", rightBarButtonItemTitle: WelcomeViewController.nextButtonString)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateNavigationBar(navigationTheme: .hidden)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //---Navigation Controller---//
    
        navigationController?.delegate = self
    }
    
    //MARK: - Private
    
    private func customInit() {
        //---Title Label---//
        
        view.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 80))
        view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50))
        
        //---H2O Label---//
        
        view.addSubview(h2OLabel)
        
        h2OLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: h2OLabel, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1, constant: 10))
        view.addConstraint(NSLayoutConstraint(item: h2OLabel, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: h2OLabel, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        
        //---Water Bottle View---//
        
        view.addSubview(waterBottleView)
        
        waterBottleView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: waterBottleView, attribute: .top, relatedBy: .equal, toItem: h2OLabel, attribute: .bottom, multiplier: 1, constant: 100))
        view.addConstraint(NSLayoutConstraint(item: waterBottleView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -100))
        view.addConstraint(NSLayoutConstraint(item: waterBottleView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: waterBottleView, attribute: .width, relatedBy: .equal, toItem: waterBottleView, attribute: .height, multiplier: 119/326, constant: 0))
    }
    
    //MARK: - BoardingProtocol
    
    func animateOut(completion: @escaping (Bool) -> Void) {
        UIView.animate(withDuration: 0.5, animations: {
            self.h2OLabel.alpha = 0
            self.waterBottleView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        }) { (Bool) in
            completion(true)
        }
    }
    
    func animateIn(completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    
    func onRightBarButton() {
        let dailyGoalViewController = DailyGoalViewController()
        navigationController?.pushViewController(dailyGoalViewController, animated: true)
    }
}


// MARK: - UINavigationControllerDelegate
extension WelcomeViewController: UINavigationControllerDelegate {
    /**
     Animates the navigation controller to zoom into cell that was tapped and transition to the next view controller with the transition animation. Cell tapped is determined in the collection view didSelect delegate method
     
     - returns: Transition animation to move to device view controller
     */
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return BoardingAnimatingTransitioning()
    }
}
