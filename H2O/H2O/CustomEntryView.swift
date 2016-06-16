//
//  CustomEntryView.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/18/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

class CustomEntryView: UIView {
        /// Shape of outlining circle that will be morphed
    let _morphingShape = CAShapeLayer()
    
        /// Corner radius to start at. The custom button corner radius
    var _startingCornerRadius :CGFloat = 0
    
        /// Corner radius to end at. The circle outline with the amount entry
    var _endingCornerRadius :CGFloat = 0
    
        /// Frame for placement for the custom button. Where it looks as if the morphingShape is the actual custom button
    var _startingFrame = CGRect()
    
        /// Frame for the final circle outling
    var _endingFrame = CGRect()
    
        /// Layer for the blue droplet that appears after the circle path transforms into the droplet path
    let _dropletShapeLayer = CAShapeLayer()
    
        /// Standard outline width for shapes
    let _lineWidth :CGFloat = 0.5
    
        /// Standard animation time for all animations in this view
    let _animationDuration = 0.25
    
        /// Custom button path
    var _customButtonShapePath :UIBezierPath {
        set{}
        get {
            let rectanglePath = UIBezierPath(roundedRect: CGRect(x: _startingFrame.origin.x, y: _startingFrame.origin.y, width: floor(_startingFrame.width * 1.00000 + 0.5) - floor(_startingFrame.width * 0.00000 + 0.5), height: floor(_startingFrame.height * 1.00000 + 0.5) - floor(_startingFrame.height * 0.00000 + 0.5)), cornerRadius: _startingCornerRadius)
            
            return rectanglePath
        }
    }
    
        /// Circle outline path
    var _circleShapePath :UIBezierPath {
        set{}
        get {
            let ovalPath = UIBezierPath(roundedRect: CGRect(x: _endingFrame.origin.x, y: _endingFrame.origin.y, width: floor(_endingFrame.width * 1.00000 + 0.5) - floor(_endingFrame.width * 0.00000 + 0.5), height: floor(_endingFrame.height * 1.00000 + 0.5) - floor(_endingFrame.height * 0.00000 + 0.5)), cornerRadius: _endingCornerRadius)
            
            return ovalPath
        }
    }
    
        /// Circle that resembles the circle shape path to morph into the droplet
    var _startingDropletMorphingShapePath :UIBezierPath {
        set{}
        get {
            let startDropletPath = UIBezierPath()
            startDropletPath.move(to: CGPoint(x: _endingFrame.minX + 0.00000 * _endingFrame.width, y: _endingFrame.minY + 0.51044 * _endingFrame.height))
            startDropletPath.addCurve(to: CGPoint(x: _endingFrame.minX + 0.50000 * _endingFrame.width, y: _endingFrame.minY + 1.00000 * _endingFrame.height), controlPoint1: CGPoint(x: _endingFrame.minX + 0.00000 * _endingFrame.width, y: _endingFrame.minY + 0.78114 * _endingFrame.height), controlPoint2: CGPoint(x: _endingFrame.minX + 0.22484 * _endingFrame.width, y: _endingFrame.minY + 1.00000 * _endingFrame.height))
            startDropletPath.addCurve(to: CGPoint(x: _endingFrame.minX + 1.00000 * _endingFrame.width, y: _endingFrame.minY + 0.51044 * _endingFrame.height), controlPoint1: CGPoint(x: _endingFrame.minX + 0.77516 * _endingFrame.width, y: _endingFrame.minY + 1.00000 * _endingFrame.height), controlPoint2: CGPoint(x: _endingFrame.minX + 1.00000 * _endingFrame.width, y: _endingFrame.minY + 0.78114 * _endingFrame.height))
            startDropletPath.addCurve(to: CGPoint(x: _endingFrame.minX + 0.50000 * _endingFrame.width, y: _endingFrame.minY + 0.00000 * _endingFrame.height), controlPoint1: CGPoint(x: _endingFrame.minX + 1.00000 * _endingFrame.width, y: _endingFrame.minY + 0.18923 * _endingFrame.height), controlPoint2: CGPoint(x: _endingFrame.minX + 0.75817 * _endingFrame.width, y: _endingFrame.minY + 0.00000 * _endingFrame.height))
            startDropletPath.addCurve(to: CGPoint(x: _endingFrame.minX + 0.00000 * _endingFrame.width, y: _endingFrame.minY + 0.51044 * _endingFrame.height), controlPoint1: CGPoint(x: _endingFrame.minX + 0.24183 * _endingFrame.width, y: _endingFrame.minY + 0.00000 * _endingFrame.height), controlPoint2: CGPoint(x: _endingFrame.minX + 0.00000 * _endingFrame.width, y: _endingFrame.minY + 0.18855 * _endingFrame.height))
            startDropletPath.close()
            startDropletPath.usesEvenOddFillRule = true
            
            return startDropletPath
        }
    }
    
        /// Water droplet path
    var _endingDropletMorphingShapePath :UIBezierPath {
        set{}
        get {
            let endDropletPath = UIBezierPath()
            endDropletPath.move(to: CGPoint(x: _endingFrame.minX + 0.29583 * _endingFrame.width, y: _endingFrame.minY + 0.62993 * _endingFrame.height))
            endDropletPath.addCurve(to: CGPoint(x: _endingFrame.minX + 0.50000 * _endingFrame.width, y: _endingFrame.minY + 0.81667 * _endingFrame.height), controlPoint1: CGPoint(x: _endingFrame.minX + 0.29583 * _endingFrame.width, y: _endingFrame.minY + 0.73319 * _endingFrame.height), controlPoint2: CGPoint(x: _endingFrame.minX + 0.38764 * _endingFrame.width, y: _endingFrame.minY + 0.81667 * _endingFrame.height))
            endDropletPath.addCurve(to: CGPoint(x: _endingFrame.minX + 0.70417 * _endingFrame.width, y: _endingFrame.minY + 0.62993 * _endingFrame.height), controlPoint1: CGPoint(x: _endingFrame.minX + 0.61236 * _endingFrame.width, y: _endingFrame.minY + 0.81667 * _endingFrame.height), controlPoint2: CGPoint(x: _endingFrame.minX + 0.70417 * _endingFrame.width, y: _endingFrame.minY + 0.73319 * _endingFrame.height))
            endDropletPath.addCurve(to: CGPoint(x: _endingFrame.minX + 0.50133 * _endingFrame.width, y: _endingFrame.minY + 0.17917 * _endingFrame.height), controlPoint1: CGPoint(x: _endingFrame.minX + 0.70417 * _endingFrame.width, y: _endingFrame.minY + 0.50741 * _endingFrame.height), controlPoint2: CGPoint(x: _endingFrame.minX + 0.50133 * _endingFrame.width, y: _endingFrame.minY + 0.17917 * _endingFrame.height))
            endDropletPath.addCurve(to: CGPoint(x: _endingFrame.minX + 0.29583 * _endingFrame.width, y: _endingFrame.minY + 0.62993 * _endingFrame.height), controlPoint1: CGPoint(x: _endingFrame.minX + 0.50133 * _endingFrame.width, y: _endingFrame.minY + 0.17917 * _endingFrame.height), controlPoint2: CGPoint(x: _endingFrame.minX + 0.29583 * _endingFrame.width, y: _endingFrame.minY + 0.50715 * _endingFrame.height))
            endDropletPath.close()
            endDropletPath.usesEvenOddFillRule = true
            
            return endDropletPath
        }
    }
    
        /// View that contains the amount text field and unit label. Combined to make positioning everything easier
    let _viewContainer = UIView()
    
        /// Text field where the user can enter how much water they drank
    let _amountTextField = UITextField()
    
        /// Unit of measurement label next to the amount text field
    let _unitLabel = UILabel()
    
    //MARK: - View Setup
    
    /**
     Permanent transparent background
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = UIColor.clear()
    }
    
    /**
     Cleanup when this view is removed from the superview
     */
    override func removeFromSuperview() {
        super.removeFromSuperview()
        
        _dropletShapeLayer.removeFromSuperlayer()
        _amountTextField.text = "" //Sets the entry text to blank
    }
    
    /**
     Function to set up all of the original paths positioning over the custom button. Sets up appearance as well such as the line width and colors. Also places the view container.
     
     - parameter frame:        Frame of custom button
     - parameter cornerRadius: Custom button corner radius
     */
    func setupStartingPathInFrame(_ frame :CGRect, cornerRadius :CGFloat) {
        _startingFrame = frame
        _startingCornerRadius = cornerRadius
        
        _morphingShape.path = _customButtonShapePath.cgPath

        _morphingShape.lineWidth = _lineWidth
        _morphingShape.strokeColor = StandardColors.primaryColor.cgColor
        _morphingShape.fillColor = UIColor.clear().cgColor
        
        layer.addSublayer(_morphingShape)
        
        setupViewContainer()
    }
    
    /**
     Setup for the view container containing the amount text field and unit label. Positions on top of the custom button with a small scale value
     */
    private func setupViewContainer() {
        _viewContainer.frame = _startingFrame
        _viewContainer.clipsToBounds = true
        _viewContainer.backgroundColor = UIColor.clear()
        
        let scaleAmount :CGFloat = 0.1 //Amount to scale everything in view container. Before scaling up
        
        setupAmountTextField() //Positions text field
        _amountTextField.transform = CGAffineTransform(scaleX: scaleAmount, y: scaleAmount)
        
        setupUnitLabel() //Positions unit label
        
        _unitLabel.transform = CGAffineTransform(scaleX: scaleAmount, y: scaleAmount)
        
        addSubview(_viewContainer)
    }
    
    /**
     Positions the amount entry text field. Simple view properties and position
     */
    private func setupAmountTextField() {
        _amountTextField.frame = CGRect(x: 0, y: 0, width: _viewContainer.bounds.width / 2, height: _viewContainer.bounds.height)
        
        _amountTextField.textColor = StandardColors.waterColor
        _amountTextField.font = StandardFonts.regularFont(80)
        _amountTextField.textAlignment = .right
        _amountTextField.keyboardType = .numberPad
        _amountTextField.keyboardAppearance = StandardColors.standardKeyboardAppearance
        _amountTextField.delegate = self
        _amountTextField.tintColor = StandardColors.waterColor
        _amountTextField.placeholder = "12"
        
        _viewContainer.addSubview(_amountTextField)
    }
    
    /**
     Positions the unit label. Simple view properties and position
     */
    private func setupUnitLabel() {
        _unitLabel.frame = CGRect(x: _viewContainer.bounds.width / 2, y: 0, width: _viewContainer.bounds.width / 2, height: _viewContainer.bounds.height)
        
        _unitLabel.textColor = StandardColors.primaryColor
        _unitLabel.font = StandardFonts.thinFont(80)
        _unitLabel.text = Constants.standardUnit.rawValue
        _unitLabel.textAlignment = .left
        
        _viewContainer.addSubview(_unitLabel)
    }
    
    //MARK: - Public animations
    
    /**
     Animation to morph the to the outlining circle for user entry
     
     - parameter endFrame:     Frame of the final circle
     - parameter cornerRadius: Corner radius of the circle
     */
    func morphToCirclePath(_ endFrame :CGRect, cornerRadius :CGFloat) {
        //Set the ivars
        _endingFrame = endFrame
        _endingCornerRadius = cornerRadius
        
        let delay = 0.1
        
        //Delay here for asthetic purposes only. Will work fine without it
        AppDelegate.delay(_animationDuration) {
            self._morphingShape.path = self._circleShapePath.cgPath //Set the path before animating
            
            self.animateViewContainerToFinish({ (Bool) in //Animates the view container to be visble to the user
            })
        }
        
        //Morph path animation
        let morphAnimation = CABasicAnimation(keyPath: "path")
        morphAnimation.fromValue = _customButtonShapePath.cgPath
        morphAnimation.toValue = _circleShapePath.cgPath
        morphAnimation.duration = _animationDuration
        morphAnimation.beginTime = CACurrentMediaTime() + delay //Accounts for delay above
        morphAnimation.isRemovedOnCompletion = false
        
        _morphingShape.add(morphAnimation, forKey: "path")
    }
    
    /**
     Animation to morph the outline circle back into a custom button shape
     
     - parameter completionHandler: Completion of animation of the view container. Not necassarily the morph
     */
    func morphToCustomButtonPath(_ completionHandler: (Bool) -> Void) {
        self._morphingShape.path = _customButtonShapePath.cgPath //Set path back to starting point
        
        animateViewContainerToStart { (Bool) in //Animate the view container back
            completionHandler(true) //Informs the caller that this animation is complete
        }
        
        //Morph path animation
        let morphAnimation = CABasicAnimation(keyPath: "path")
        morphAnimation.fromValue = _circleShapePath.cgPath
        morphAnimation.toValue = _customButtonShapePath.cgPath
        morphAnimation.duration = _animationDuration
        morphAnimation.isRemovedOnCompletion = false
        
        _morphingShape.add(morphAnimation, forKey: "path")
    }
    
    /**
     Morphs circle into droplet
     
     - parameter completionHandler: Completion of animation of the view container. Not necassarily the morph
     */
    func morphToDropletPath(_ completionHandler: (Bool) -> Void) {
        self._morphingShape.path = _endingDropletMorphingShapePath.cgPath //Set path to droplet
        
        animateViewContainerToStart { (Bool) in //Animate the view container back
            completionHandler(true) //Informs the caller that this animation is complete
        }
        
        //Morph path animation
        let morphAnimation = CABasicAnimation(keyPath: "path")
        morphAnimation.fromValue = _startingDropletMorphingShapePath.cgPath //Looks like the circle path that was used before. But this path is adjusted to morph into the droplet
        morphAnimation.toValue = _endingDropletMorphingShapePath.cgPath
        morphAnimation.duration = _animationDuration
        morphAnimation.isRemovedOnCompletion = false
        
        _morphingShape.add(morphAnimation, forKey: "path")
        
        
        
        //Setup for droplet layer to fade in after morph is made to show a blue droplet
        
        _dropletShapeLayer.path = _endingDropletMorphingShapePath.cgPath //Droplet path
        
        _dropletShapeLayer.fillColor = StandardColors.waterColor.cgColor
        _dropletShapeLayer.strokeColor = StandardColors.primaryColor.cgColor
        _dropletShapeLayer.lineWidth = _lineWidth
        _dropletShapeLayer.opacity = 0
        
        layer.addSublayer(_dropletShapeLayer)
        
        //Delay to set the opacity so the morph animation could finish before seeing the blue droplet
        AppDelegate.delay(_animationDuration) {
            self._dropletShapeLayer.opacity = 1
        }
        
        //Blue droplet alpha animation
        let dropletOpacityAnimation = CABasicAnimation(keyPath: "opacity")
        dropletOpacityAnimation.fromValue = 0
        dropletOpacityAnimation.toValue = 1
        dropletOpacityAnimation.duration = _animationDuration
        dropletOpacityAnimation.beginTime = CACurrentMediaTime() + _animationDuration
        dropletOpacityAnimation.isRemovedOnCompletion = false
        
        _dropletShapeLayer.add(dropletOpacityAnimation, forKey: "opacity")
    }
    
    func invalidEntry() {
        let animationDuration :TimeInterval = 0.8
        let moveValue :CGFloat = 20 //initial X translation to shake
        
        let shakeDuration = 0.2

        ///Shake keyframe animation
        UIView.animateKeyframes(withDuration: animationDuration, delay: 0, options: .allowUserInteraction, animations: { () -> Void in
            ///Shake forward
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: shakeDuration, animations: { () -> Void in
                self.layer.position = CGPoint(x: self.layer.position.x + moveValue, y: self.layer.position.y)
            })
            
            ///Shake back
            UIView.addKeyframe(withRelativeStartTime: shakeDuration, relativeDuration: shakeDuration, animations: { () -> Void in
                self.layer.position = CGPoint(x: self.layer.position.x - moveValue * 2, y: self.layer.position.y)
            })
            
            ///Shake forward
            UIView.addKeyframe(withRelativeStartTime: shakeDuration * 2, relativeDuration: shakeDuration, animations: { () -> Void in
                self.layer.position = CGPoint(x: self.layer.position.x + moveValue * 2, y: self.layer.position.y)
            })
            
            ///Shake back
            UIView.addKeyframe(withRelativeStartTime: shakeDuration * 3, relativeDuration: shakeDuration, animations: { () -> Void in
                self.layer.position = CGPoint(x: self.layer.position.x - moveValue, y: self.layer.position.y)
            })
        }) { (Bool) -> Void in
        }
    }
    
    //MARK: - View Container Animations
    
    /**
     Animates the view container with the unit label and text field to the entry point in the outline circle
     
     - parameter completionHandler: When the animation is complete
     */
    private func animateViewContainerToFinish(_ completionHandler: (Bool) -> Void) {
        UIView.animate(withDuration: _animationDuration, animations: {
            self._viewContainer.frame = self._endingFrame //Frame at ending point
            
            self._unitLabel.transform = CGAffineTransform.identity
            self.setupUnitLabel() //Repositions unit label after transform
            
            self._amountTextField.transform = CGAffineTransform.identity
            self.setupAmountTextField() //Repositions text field after transform
            
            }) { (Bool) in
                self._amountTextField.becomeFirstResponder()
                completionHandler(true)
        }
    }
    
    /**
     Animates the view container with the unit label and text field to the invisible original custom button point
     
     - parameter completionHandler: When the animation is complete
     */
    private func animateViewContainerToStart(_ completionHandler: (Bool) -> Void) {
        let scaleAmount :CGFloat = 0.0001
        _amountTextField.resignFirstResponder()

        UIView.animate(withDuration: _animationDuration, animations: {
            self._viewContainer.frame = self._startingFrame //Frame at starting custom button point
            
            self._unitLabel.transform = CGAffineTransform(scaleX: scaleAmount, y: scaleAmount)
            self.setupUnitLabel() //Repositions unit label after transform
            
            self._amountTextField.transform = CGAffineTransform(scaleX: scaleAmount, y: scaleAmount)
            self.setupAmountTextField() //Repositions text field after transform
            
        }) { (Bool) in
            completionHandler(true)
        }
    }
    
    //MARK: - Other
    
    /**
     Allows interaction of all views except for this views background. So taps will hit the superview instead
     */
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        
        if view != self {
            return view
        } else {
            return nil
        }
    }
}

// MARK: - UITextFieldDelegate
extension CustomEntryView :UITextFieldDelegate {
    /**
     Determines whether editing should be allowed. Limitations are that only digits may be entered with a max of 3 digits
     
     - returns: Is editing allowed
     */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        if Int(string) != nil || isBackSpace == -92 { //Is it a number or a backspace value
            if textField.text!.characters.count + 1 > 3 && isBackSpace != -92  { //Is there less than 3 characters or is this not a backspace
                return false
            } else {
                let character = Array(arrayLiteral: Constants.standardUnit.rawValue)[0]
                let sizeOfCharacter = character.size(attributes: [NSFontAttributeName : _unitLabel.font!]) //Gets size of text based on font and string
                
                let amountToMoveCharacters = sizeOfCharacter.width / 2 //Amount to move text field and unit label
                
                //Shifts the text field and unit label if three numbers are entered
                UIView.animate(withDuration: _animationDuration, animations: {
                    if textField.text!.characters.count == 2 && isBackSpace != -92 { //Is there 2 characters and now a third is coming that is not a background
                        
                        //Move everything to the right
                        self._unitLabel.frame = self._unitLabel.frame.offsetBy(dx: amountToMoveCharacters, dy: 0)
                        self._amountTextField.frame = self._amountTextField.frame.offsetBy(dx: amountToMoveCharacters, dy: 0)
                        
                    } else if textField.text!.characters.count == 3 && isBackSpace == -92 { //If there are 3 characters and a backspace is coming to make it two
                        
                        //Move everything to the left
                        self._unitLabel.frame = self._unitLabel.frame.offsetBy(dx: -amountToMoveCharacters, dy: 0)
                        self._amountTextField.frame = self._amountTextField.frame.offsetBy(dx: -amountToMoveCharacters, dy: 0)
                    }
                })
                
                return true
            }
        } else {
            return false
        }
    }
}
