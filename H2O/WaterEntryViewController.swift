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
    
    /// Navigation bar theme handler.
    var navigationThemeDidChangeHandler: ((NavigationTheme) -> Void)?
    
    /// Model for water entries.
    var model: WaterEntryController?
    
    // MARK: - Private iVars

    /// Entry buttons for preset values specified by the user.
    private lazy var entryButtons: [EntryButton] = {
        guard let presetValues = AppUserDefaults.getPresetWaterValues() else {
            return []
        }
        
        let entryButtons = presetValues.map({ (value: Float) -> EntryButton in
            let button = EntryButton()
            
            button.addTarget(self, action: #selector(onEntryButton), for: .touchUpInside)
            button.amount = Double(value)
            
            return button
        })
        
        return entryButtons
    }()
    
    /// Entry button to open a custom view to enter any value.
    private lazy var customEntryButton: CustomEntryButton = {
        let button = CustomEntryButton()
        
        button.setTitle("Custom", for: .normal)
        
        return button
    }()
    
    /// View to enter a custom amount.
    fileprivate lazy var customEntryView: CustomEntryView = {
        let view = CustomEntryView()
        
        view.delegate = self
        
        return view
    }()
    
    /// View for confetti to burst when the user hit their goal
    fileprivate lazy var confettiArea: L360ConfettiArea = {
        let view = L360ConfettiArea()
        
        view.isUserInteractionEnabled = false
        
        return view
    }()
    
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
    fileprivate lazy var fluidView: H2OFluidView = {
        let view = H2OFluidView()
        
        view.isUserInteractionEnabled = false
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
    
    /// Undo bar button item.
    fileprivate lazy var undoBarButtonItem: UndoBarButtonItem = {
        let barButtonItem = UndoBarButtonItem(enabled: false)
        
        barButtonItem.addTarget(target: self, action: #selector(onUndoButtonBarButton))

        return barButtonItem
    }()
    
    /// Current view controller state.
    private var state = WaterEntryViewState()
    
    /// Feedback generator for the information view controller.
    private let infoFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    /// Feedback generator.
    private let feedbackGenerator = UINotificationFeedbackGenerator()

    // MARK: - Public
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //---View---//
        
        view.backgroundColor = .black

        //---Daily Entry Dial---//
        
        view.addSubview(dailyEntryDial)
        
        dailyEntryDial.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints([
            NSLayoutConstraint(item: dailyEntryDial, attribute: .top, relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1, constant: 80),
            NSLayoutConstraint(item: dailyEntryDial, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: dailyEntryDial, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -50),
            NSLayoutConstraint(item: dailyEntryDial, attribute: .width, relatedBy: .equal, toItem: dailyEntryDial, attribute: .height, multiplier: 1, constant: 0),
            ])
        
        //---Custom Entry Button---//
        
        view.addSubview(customEntryButton)
        
        customEntryButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints([
            NSLayoutConstraint(item: customEntryButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottomMargin, multiplier: 1, constant: -60),
            NSLayoutConstraint(item: customEntryButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: customEntryButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: customEntryButton, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.45, constant: 0),
            ])
        
        //---Entry Buttons---//
        
        for (i, entryButton) in entryButtons.enumerated() {
            view.addSubview(entryButton)
            
            entryButton.translatesAutoresizingMaskIntoConstraints = false
            
            view.addConstraints([
                NSLayoutConstraint(item: entryButton, attribute: .bottom, relatedBy: .equal, toItem: customEntryButton, attribute: .top, multiplier: 1, constant: -50),
                NSLayoutConstraint(item: entryButton, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.25, constant: 0),
                NSLayoutConstraint(item: entryButton, attribute: .height, relatedBy: .equal, toItem: entryButton, attribute: .width, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: entryButton, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: CGFloat(i + 1) / CGFloat(entryButtons.count), constant: 0)
                ])
        }
        
        //---Confetti View---//
        
        view.addSubview(confettiArea)
        
        confettiArea.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints([
            NSLayoutConstraint(item: confettiArea, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: confettiArea, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: confettiArea, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: confettiArea, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
            ])
        
        //---Fluid View---//
        
        view.addSubview(fluidView)
        
        fluidView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints([
            NSLayoutConstraint(item: fluidView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: fluidView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: fluidView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: fluidView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
            ])
        
        //---Custom Entry View---//
        
        customEntryView.customButtonFrame = customEntryButton.frame
        customEntryView.customButtonCornerRadius = customEntryButton.layer.cornerRadius
        customEntryView.circleDialFrame = dailyEntryDial.frame
        customEntryView.circleDialCornerRadius = dailyEntryDial.bounds.width / 2
        customEntryView.dropletAtBottomFrame = CGRect(x: dailyEntryDial.frame.origin.x, y: self.view.frame.height, width: dailyEntryDial.frame.width, height: dailyEntryDial.frame.height)
        
        //---State---//
        
        setInitialState()
    }
    
    // MARK: - Private
    
    private func setInitialState() {
        if !AppUserDefaults.getInformationViewControllerWasOpenedOnce() {
            state.attributesState.update(with: .neverOpenedInformationViewController)
        }
        
        stateDidChange()
    }
    
    private func stateDidChange() {
        if state.presentingState == .mainViewControllerPresenting {
            prepareFeedbackGenerators([infoFeedbackGenerator, feedbackGenerator])
            updateNavigationBar(navigationTheme: .hidden)
            dismiss(animated: true, completion: nil)
            let settingsBarButtonItem = UIBarButtonItem(image: UIImage(assetIdentifier: .settingsBarButtonItem), style: .plain, target: self, action: #selector(onSettingsBarButton))
            settingsBarButtonItem.tintColor = StandardColors.primaryColor
            navigationItem.hidesBackButton = true
            navigationItem.leftBarButtonItem = undoBarButtonItem
            navigationItem.rightBarButtonItem = settingsBarButtonItem
        }
        
        if state.presentingState == .informationViewControllerPresenting {
            presentInformationViewController()
        }
        
        if state.presentingState == .settingsViewControllerPresenting {
            presentSettingsViewController()
        }
        
        if state.presentingState == .customEntryViewPresenting {
            presentCustomEntryView()
            prepareFeedbackGenerators([infoFeedbackGenerator, feedbackGenerator])
            updateNavigationBar(navigationTheme: .hidden)
            dismiss(animated: true, completion: nil)
        } else {
          //  hideCustomEntryView()
        }
        
        //Set the information view controller opened user default value so that the dial will not animate to indicate that the user should tap the dial.
        if state.attributesState.contains(.neverOpenedInformationViewController) {
            AppUserDefaults.setInformationViewControllerWasOpenedOnce(openedOnce: false)
            dailyEntryDial.beatAnimation(toggle: true)
        } else {
            AppUserDefaults.setInformationViewControllerWasOpenedOnce(openedOnce: true)
            dailyEntryDial.beatAnimation(toggle: false)
        }
        
        if state.attributesState.contains(.undoButtonPresenting) {
            undoBarButtonItem.enable()
        } else {
            undoBarButtonItem.disable()
        }
    }

    /// Presents the information view controller as modal.
    private func presentInformationViewController() {
        state.attributesState.remove(.neverOpenedInformationViewController)
        
        infoFeedbackGenerator.impactOccurred()
        
        let informationViewController: InformationViewController = UIStoryboard(storyboard: .Main).instantiateViewController()
        informationViewController.modalPresentationStyle = .custom
        informationViewController.dismissAction = {
            self.state.presentingState = .mainViewControllerPresenting
            self.stateDidChange()
        }
        
        present(informationViewController, animated: true, completion: nil)
    }
    
    /// Presents settings view controller as modal.
    private func presentSettingsViewController() {
        let navigationController: UINavigationController = UIStoryboard(storyboard: .Main).instantiateViewController()
        
        navigationController.navigationBar.barTintColor = StandardColors.standardSecondaryColor
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: StandardColors.primaryColor, NSFontAttributeName: StandardFonts.boldFont(size: 20)] //Navigation bar view properties
        
        if let settingsViewController = navigationController.viewControllers.first as? InAppSettingsViewController {
            settingsViewController.dismissAction = {
                self.state.presentingState = .mainViewControllerPresenting
                self.stateDidChange()
            }
        }
        
        present(navigationController, animated: true, completion: nil)
    }
    
    /// Presents custom entry view.
    private func presentCustomEntryView() {
        customEntryView.animateFromCustomButtonPathToCirclePath { (Bool) in
        }
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .allowUserInteraction, animations: {
            let scale = CGAffineTransform.identity
            let alpha: CGFloat = 1
            
            self.customEntryButton.transform = scale
            self.customEntryButton.alpha = alpha
            
            self.dailyEntryDial.transform = scale
            self.dailyEntryDial.alpha = alpha
            
            for entryButton in self.entryButtons {
                entryButton.transform = scale
                entryButton.alpha = alpha
            }
        }, completion: { _ in
        })
        
        //Navigation bar setup for controlling custom entry
        
        let cancelBarButton = UIBarButtonItem(title: "cancel_navigation_item".localized, style: .plain, target: self, action: #selector(onCancelCustomEntryBarButton))
        
        cancelBarButton.setTitleTextAttributes([NSForegroundColorAttributeName: StandardColors.standardRedColor, NSFontAttributeName: StandardFonts.regularFont(size: 18)], for: UIControlState()) //Cancel button view properties
        
        let doneBarButton = UIBarButtonItem(title: "done_navigation_item".localized, style: .plain, target: self, action: #selector(onDoneCustomEntryBarButton))
        
        doneBarButton.setTitleTextAttributes([NSForegroundColorAttributeName: StandardColors.waterColor, NSFontAttributeName: StandardFonts.boldFont(size: 18)], for: UIControlState()) //Done button view properties
        
        navigationItem.leftBarButtonItem = cancelBarButton
        navigationItem.rightBarButtonItem = doneBarButton
    }
    
    /// Hides custom entry view.
    private func hideCustomEntryView() {
        customEntryView.animateFromDialCirclePathToCustomButtonPath { (Bool) in
        }
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .allowUserInteraction, animations: {
            let scale = CGAffineTransform.identity
            let alpha: CGFloat = 1
            
            self.customEntryButton.transform = scale
            self.customEntryButton.alpha = alpha
            
            self.dailyEntryDial.transform = scale
            self.dailyEntryDial.alpha = alpha
            
            for entryButton in self.entryButtons {
                entryButton.transform = scale
                entryButton.alpha = alpha
            }
        }, completion: { _ in
        })
    }
    
    /// Prepares specified feedback generators for impact.
    ///
    /// - Parameter feedbackGenerators: Feedback generators to prepare.
    private func prepareFeedbackGenerators(_ feedbackGenerators: [UIFeedbackGenerator]) {
        for feedbackGenerator in feedbackGenerators {
            feedbackGenerator.prepare()
        }
    }
    
    // MARK: - Actions
    
    @objc private func onEntryButton(_ button: EntryButton) {
        AudioToolbox.standardAudioToolbox.playAudio(WaterDrop1Sound, repeatEnabled: false)
        
        feedbackGenerator.notificationOccurred(.success)
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            button.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { (Bool) in
        }
        
        UIView.animate(withDuration: 0.4, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2, options: .curveEaseOut, animations: {
            button.transform = CGAffineTransform.identity
        }, completion: { (Bool) in
        })
    }
    
    @objc private func onCustomEntryButton(_ button: CustomEntryButton) {
        AudioToolbox.standardAudioToolbox.playAudio(LightClickSound, repeatEnabled: false)

        state.presentingState = .customEntryViewPresenting
        stateDidChange()
    }
    
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
    
    ///When the undo button was tapped.
    @objc private func onUndoButtonBarButton() {
        state.attributesState.update(with: .undoButtonPresenting)
        stateDidChange()
    }
    
    @objc private func onDoneCustomEntryBarButton() {
        if customEntryView.amountTextField.text != "" { //If the text field is not blank
            customEntryView.animateToDropletPathAndDrop(completionHandler: { (Bool) in
                delay(delay: 0.5, closure: {
                    self.state.presentingState = .mainViewControllerPresenting
                    self.stateDidChange()
                })
            })
        } else {
            feedbackGenerator.notificationOccurred(.error)
            customEntryView.invalidEntry()
        }
    }
    
    ///When the cancel bar button is tapped when the custom entry view is present
    @objc private func onCancelCustomEntryBarButton() {
        state.presentingState = .mainViewControllerPresenting
        stateDidChange()
    }
    
    ///When undo button becomes disabled.
    @objc private func onUndoDisabledTimer() {
        state.attributesState.remove(.undoButtonPresenting)
        stateDidChange()
    }
}

// MARK: - CustomEntryViewProtocol
extension WaterEntryViewController: CustomEntryViewProtocol {
    func dropletLayerDidUpdate(layer: GSAnimatingProgressLayer) {
        
        guard
            let fluidPresentationLayerFrame = fluidView.liquidLayer.presentation()?.frame,
            let lastCustomViewDropletPresentationLayerFrame = customEntryView.dropletShapeLayer.presentation()!.path?.boundingBoxOfPath
        else {
            return
        }
        
        if (fluidPresentationLayerFrame.intersects(lastCustomViewDropletPresentationLayerFrame)) {
            AudioToolbox.standardAudioToolbox.playAudio(WaterSound, repeatEnabled: false)
          //  monitoringCustomViewDropletMovements = false
        }
    }
}

// MARK: - H2OFluidViewProtocol
extension WaterEntryViewController: H2OFluidViewProtocol {
    func fluidViewLayerDidUpdate(fluidView: GSAnimatingProgressLayer) {
      //  lastFluidViewPresentationLayerFrame = fluidView.liquidLayer.presentation()?.frame
    }
}

// MARK: - BoardingProtocol
extension WaterEntryViewController: BoardingProtocol {
    func animateIn(completion: @escaping (Bool) -> Void) {
        view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        view.alpha = 0
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .allowUserInteraction, animations: {
            self.view.transform = CGAffineTransform.identity
            self.view.alpha = 1
        }, completion: { _ in
            completion(true)
        })
    }
    
    func animateOut(completion: @escaping (Bool) -> Void) {
        
    }
}
