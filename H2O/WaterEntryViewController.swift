//
//  WaterEntryViewController.swift
//  H2O
//
//  Created by Gregory Sapienza on 4/7/17.
//  Copyright © 2017 City Pixels. All rights reserved.
//

import UIKit


class WaterEntryViewController: UIViewController, NavigationThemeProtocol {
    
    // MARK: - Public iVars

    var navigationThemeDidChangeHandler: ((NavigationTheme) -> Void)?
    
    // MARK: - Private iVars

    /// Dial representing how much water was consumed.
    private lazy var dailyEntryDial: DailyEntryDial = {
        let view = DailyEntryDial()
    
        if let current = getAppDelegate().user?.amountOfWaterForToday() {
            view.setCurrent(Double(current), animated: false)
        }
        
        if let goal = AppUserDefaults.getDailyGoalValue() {
            view.setTotal(Double(goal), animated: false)
        }
        
        view.addTarget(self, action: #selector(onDailyEntryDialControl), for: .touchUpInside)
        view.innerCircleColor = StandardColors.primaryColor
        view.outerCircleColor = UIColor(red: 27/255, green: 119/255, blue: 135/255, alpha: 0.3)

        return view
    }()
    
    /// Fluid view representing how much water the user has consumed.
    private lazy var fluidView: H2OFluidView = {
        let view = H2OFluidView()
        
        view.liquidFillColor = StandardColors.waterColor
        view.h2OFluidViewDelegate = self
        
        return view
    }()
    
    /// Settings bar button item
    private lazy var settingsBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(assetIdentifier: .settingsBarButtonItem), style: .plain, target: self, action: #selector(onSettingsBarButton))
        
        barButtonItem.tintColor = StandardColors.primaryColor
        
        return barButtonItem
    }()
    
    /// Current view controller state.
    private var state = WaterEntryViewState()
    
    /// Feedback generator for the information view controller.
    private let infoFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    // MARK: - Public
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //---View---//
        
        view.backgroundColor = .black
        
        //---Feedback Generators---//
        
        prepareFeedbackGenerators([infoFeedbackGenerator])
    }
    
    
    // MARK: - Private
    private func setInitialState() {
        if !AppUserDefaults.getInformationViewControllerWasOpenedOnce() {
            state.attributesState.update(with: .neverOpenedInformationViewController)
        }
    }
    
    private func stateDidChange() {
        if state.presentingState == .mainViewControllerPresenting {
            updateNavigationBar(navigationTheme: .hidden)
        }
        
        //Set the information view controller opened user default value so that the dial will not animate to indicate that the user should tap the dial.
        if state.attributesState.contains(.neverOpenedInformationViewController) {
            AppUserDefaults.setInformationViewControllerWasOpenedOnce(openedOnce: false)
            dailyEntryDial.beatAnimation(toggle: true)
        } else {
            AppUserDefaults.setInformationViewControllerWasOpenedOnce(openedOnce: true)
            dailyEntryDial.beatAnimation(toggle: false)
        }
        
        if state.presentingState == .informationViewControllerPresenting {
            presentInformationViewController()
        } else {
            dismiss(animated: true, completion: nil)
        }
       
        if state.presentingState == .settingsViewControllerPresenting {
            presentSettingsViewController()
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    /// Prepares specified feedback generators for impact.
    ///
    /// - Parameter feedbackGenerators: Feedback generators to prepare.
    private func prepareFeedbackGenerators(_ feedbackGenerators: [UIFeedbackGenerator]) {
        for feedbackGenerator in feedbackGenerators {
            feedbackGenerator.prepare()
        }
    }

    /// Presents the information view controller as modal.
    private func presentInformationViewController() {
        state.attributesState.remove(.neverOpenedInformationViewController)
        stateDidChange()
        
        infoFeedbackGenerator.impactOccurred()
        
        let informationViewController: InformationViewController = UIStoryboard(storyboard: .Main).instantiateViewController()
        modalPresentationStyle = .currentContext
        present(informationViewController, animated: true, completion: nil)
    }
    
    /// Presents settings view controller as modal.
    private func presentSettingsViewController() {
        let navigationController: UINavigationController = UIStoryboard(storyboard: .Main).instantiateViewController()
        
        navigationController.navigationBar.barTintColor = StandardColors.standardSecondaryColor
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: StandardColors.primaryColor, NSFontAttributeName: StandardFonts.boldFont(size: 20)] //Navigation bar view properties
        
        present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    
    @objc private func onDailyEntryDialControl() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            self.dailyEntryDial.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { (Bool) in
        }
        
        UIView.animate(withDuration: 0.4, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2, options: .curveEaseOut, animations: {
            self.dailyEntryDial.transform = CGAffineTransform.identity
        }, completion: { (Bool) in
        })
        
        state.presentingState = .informationViewControllerPresenting
        stateDidChange()
    }
    
    @objc private func onSettingsBarButton() {
        state.presentingState = .settingsViewControllerPresenting
        stateDidChange()
    }
}

// MARK: - H2OFluidViewProtocol
extension WaterEntryViewController: H2OFluidViewProtocol {
    func fluidViewLayerDidUpdate(fluidView: GSAnimatingProgressLayer) {
        lastFluidViewPresentationLayerFrame = self.fluidView.liquidLayer.presentation()?.frame
    }
}

