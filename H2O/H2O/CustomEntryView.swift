//
//  CustomEntryView.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/18/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

class CustomEntryView: UIView {
    //MARK: - Public iVars
    
    /// Corner radius to start at. The custom button corner radius
    var startingCornerRadius :CGFloat = 0
    
    /// Corner radius to end at. The circle outline with the amount entry
    var endingCornerRadius :CGFloat = 0
    
    /// Frame for placement for the custom button. Where it looks as if the morphingShape is the actual custom button
    var startingFrame = CGRect()
    
    /// Frame for the final circle outling
    var endingFrame = CGRect()
    
    /// Text field where the user can enter how much water they drank
    var amountTextField = UITextField()
    
    //MARK: - Private iVars
    
    /// View that contains the amount text field and unit label. Combined to make positioning everything easier
    private var viewContainer = UIView()
    
    /// Shape of outlining circle that will be morphed
    private let morphingShape = CAShapeLayer()
    
    /// Layer for the blue droplet that appears after the circle path transforms into the droplet path
    private let dropletShapeLayer = CAShapeLayer()
    
    /// Standard outline width for shapes
    private let lineWidth :CGFloat = 0.5
    
    //MARK: - Internal iVars
    
    /// Unit of measurement label next to the amount text field
    internal var unitLabel = UILabel()
    
    /// Standard animation time for all animations in this view
    internal let animationDuration = 0.25
    
    //MARK: - Private Shape Paths
    
    /// Custom button path
    private var customButtonShapePath :UIBezierPath {
        set{}
        get {
            let rectanglePath = UIBezierPath(roundedRect: CGRect(x: startingFrame.origin.x, y: startingFrame.origin.y, width: floor(startingFrame.width * 1.00000 + 0.5) - floor(startingFrame.width * 0.00000 + 0.5), height: floor(startingFrame.height * 1.00000 + 0.5) - floor(startingFrame.height * 0.00000 + 0.5)), cornerRadius: startingCornerRadius)
            
            return rectanglePath
        }
    }
    
    /// Circle outline path
    private var circleShapePath :UIBezierPath {
        set{}
        get {
            let ovalPath = UIBezierPath(roundedRect: CGRect(x: endingFrame.origin.x, y: endingFrame.origin.y, width: floor(endingFrame.width * 1.00000 + 0.5) - floor(endingFrame.width * 0.00000 + 0.5), height: floor(endingFrame.height * 1.00000 + 0.5) - floor(endingFrame.height * 0.00000 + 0.5)), cornerRadius: endingCornerRadius)
            
            return ovalPath
        }
    }
    
    /// Circle that resembles the circle shape path to morph into the droplet
    private var startingDropletMorphingShapePath :UIBezierPath {
        set{}
        get {
            let startDropletPath = UIBezierPath()
            startDropletPath.move(to: CGPoint(x: endingFrame.minX + 0.00000 * endingFrame.width, y: endingFrame.minY + 0.51044 * endingFrame.height))
            startDropletPath.addCurve(to: CGPoint(x: endingFrame.minX + 0.50000 * endingFrame.width, y: endingFrame.minY + 1.00000 * endingFrame.height), controlPoint1: CGPoint(x: endingFrame.minX + 0.00000 * endingFrame.width, y: endingFrame.minY + 0.78114 * endingFrame.height), controlPoint2: CGPoint(x: endingFrame.minX + 0.22484 * endingFrame.width, y: endingFrame.minY + 1.00000 * endingFrame.height))
            startDropletPath.addCurve(to: CGPoint(x: endingFrame.minX + 1.00000 * endingFrame.width, y: endingFrame.minY + 0.51044 * endingFrame.height), controlPoint1: CGPoint(x: endingFrame.minX + 0.77516 * endingFrame.width, y: endingFrame.minY + 1.00000 * endingFrame.height), controlPoint2: CGPoint(x: endingFrame.minX + 1.00000 * endingFrame.width, y: endingFrame.minY + 0.78114 * endingFrame.height))
            startDropletPath.addCurve(to: CGPoint(x: endingFrame.minX + 0.50000 * endingFrame.width, y: endingFrame.minY + 0.00000 * endingFrame.height), controlPoint1: CGPoint(x: endingFrame.minX + 1.00000 * endingFrame.width, y: endingFrame.minY + 0.18923 * endingFrame.height), controlPoint2: CGPoint(x: endingFrame.minX + 0.75817 * endingFrame.width, y: endingFrame.minY + 0.00000 * endingFrame.height))
            startDropletPath.addCurve(to: CGPoint(x: endingFrame.minX + 0.00000 * endingFrame.width, y: endingFrame.minY + 0.51044 * endingFrame.height), controlPoint1: CGPoint(x: endingFrame.minX + 0.24183 * endingFrame.width, y: endingFrame.minY + 0.00000 * endingFrame.height), controlPoint2: CGPoint(x: endingFrame.minX + 0.00000 * endingFrame.width, y: endingFrame.minY + 0.18855 * endingFrame.height))
            startDropletPath.close()
            startDropletPath.usesEvenOddFillRule = true
            
            return startDropletPath
        }
    }
    
    /// Water droplet path
    private var endingDropletMorphingShapePath :UIBezierPath {
        set{}
        get {
            let endDropletPath = UIBezierPath()
            endDropletPath.move(to: CGPoint(x: endingFrame.minX + 0.29583 * endingFrame.width, y: endingFrame.minY + 0.62993 * endingFrame.height))
            endDropletPath.addCurve(to: CGPoint(x: endingFrame.minX + 0.50000 * endingFrame.width, y: endingFrame.minY + 0.81667 * endingFrame.height), controlPoint1: CGPoint(x: endingFrame.minX + 0.29583 * endingFrame.width, y: endingFrame.minY + 0.73319 * endingFrame.height), controlPoint2: CGPoint(x: endingFrame.minX + 0.38764 * endingFrame.width, y: endingFrame.minY + 0.81667 * endingFrame.height))
            endDropletPath.addCurve(to: CGPoint(x: endingFrame.minX + 0.70417 * endingFrame.width, y: endingFrame.minY + 0.62993 * endingFrame.height), controlPoint1: CGPoint(x: endingFrame.minX + 0.61236 * endingFrame.width, y: endingFrame.minY + 0.81667 * endingFrame.height), controlPoint2: CGPoint(x: endingFrame.minX + 0.70417 * endingFrame.width, y: endingFrame.minY + 0.73319 * endingFrame.height))
            endDropletPath.addCurve(to: CGPoint(x: endingFrame.minX + 0.50133 * endingFrame.width, y: endingFrame.minY + 0.17917 * endingFrame.height), controlPoint1: CGPoint(x: endingFrame.minX + 0.70417 * endingFrame.width, y: endingFrame.minY + 0.50741 * endingFrame.height), controlPoint2: CGPoint(x: endingFrame.minX + 0.50133 * endingFrame.width, y: endingFrame.minY + 0.17917 * endingFrame.height))
            endDropletPath.addCurve(to: CGPoint(x: endingFrame.minX + 0.29583 * endingFrame.width, y: endingFrame.minY + 0.62993 * endingFrame.height), controlPoint1: CGPoint(x: endingFrame.minX + 0.50133 * endingFrame.width, y: endingFrame.minY + 0.17917 * endingFrame.height), controlPoint2: CGPoint(x: endingFrame.minX + 0.29583 * endingFrame.width, y: endingFrame.minY + 0.50715 * endingFrame.height))
            endDropletPath.close()
            endDropletPath.usesEvenOddFillRule = true
            
            return endDropletPath
        }
    }
    
    //MARK: - View Setup
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = UIColor.clear
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        
        dropletShapeLayer.removeFromSuperlayer()
        amountTextField.text = "" //Sets the entry text to blank
    }
    
    ///Allows interaction of all views except for this views background. So taps will hit the superview instead
    override func hitTest( _ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        
        if view != self {
            return view
        } else {
            return nil
        }
    }
    
    /**
     Function to set up all of the original paths positioning over the custom button. Sets up appearance as well such as the line width and colors. Also places the view container.
     
     - parameter frame:        Frame of custom button
     - parameter cornerRadius: Custom button corner radius
     */
    func setupStartingPathInFrame( frame :CGRect, cornerRadius :CGFloat) {
        startingFrame = frame
        startingCornerRadius = cornerRadius
        
        morphingShape.path = customButtonShapePath.cgPath

        morphingShape.lineWidth = lineWidth
        morphingShape.strokeColor = StandardColors.primaryColor.cgColor
        morphingShape.fillColor = UIColor.clear.cgColor
        
        layer.addSublayer(morphingShape)
        
        viewContainer = generateViewContainer()
        unitLabel = generateUnitLabel()
        amountTextField = generateAmountTextField()
        
        layout()
    }
    
    private func layout() {
        //---View Container---
        
        viewContainer.frame = startingFrame
        addSubview(viewContainer)
        
        //---Amount Text Field---
        
        amountTextField.frame = CGRect(x: 0, y: 0, width: viewContainer.bounds.width / 2, height: viewContainer.bounds.height)
        viewContainer.addSubview(amountTextField)
        
        //---Unit Label---
        
        unitLabel.frame = CGRect(x: viewContainer.bounds.width / 2, y: 0, width: viewContainer.bounds.width / 2, height: viewContainer.bounds.height)
        viewContainer.addSubview(unitLabel)
    }
    
    //MARK: - Public
    
    /**
     Animation to morph the to the outlining circle for user entry
     
     - parameter endFrame:     Frame of the final circle
     - parameter cornerRadius: Corner radius of the circle
     */
    func morphToCirclePath( endFrame :CGRect, cornerRadius :CGFloat) {
        //Set the ivars
        endingFrame = endFrame
        endingCornerRadius = cornerRadius
        
        let delay = 0.1
        
        //Delay here for asthetic purposes only. Will work fine without it
        AppDelegate.delay(animationDuration) {
            self.morphingShape.path = self.circleShapePath.cgPath //Set the path before animating
            
            self.animateViewContainerToFinish(completionHandler: { (Bool) in //Animates the view container to be visble to the user
            })
        }
        
        //Morph path animation
        let morphAnimation = CABasicAnimation(keyPath: "path")
        morphAnimation.fromValue = customButtonShapePath.cgPath
        morphAnimation.toValue = circleShapePath.cgPath
        morphAnimation.duration = animationDuration
        morphAnimation.beginTime = CACurrentMediaTime() + delay //Accounts for delay above
        morphAnimation.isRemovedOnCompletion = false
        
        morphingShape.add(morphAnimation, forKey: "path")
    }
    
    /**
     Animation to morph the outline circle back into a custom button shape
     
     - parameter completionHandler: Completion of animation of the view container. Not necassarily the morph
     */
    func morphToCustomButtonPath( completionHandler: @escaping (Bool) -> Void) {
        self.morphingShape.path = customButtonShapePath.cgPath //Set path back to starting point
        
        animateViewContainerToStart { (Bool) in //Animate the view container back
            completionHandler(true) //Informs the caller that this animation is complete
        }
        
        //Morph path animation
        let morphAnimation = CABasicAnimation(keyPath: "path")
        morphAnimation.fromValue = circleShapePath.cgPath
        morphAnimation.toValue = customButtonShapePath.cgPath
        morphAnimation.duration = animationDuration
        morphAnimation.isRemovedOnCompletion = false
        
        morphingShape.add(morphAnimation, forKey: "path")
    }
    
    /**
     Morphs circle into droplet
     
     - parameter completionHandler: Completion of animation of the view container. Not necassarily the morph
     */
    func morphToDropletPath( completionHandler: @escaping (Bool) -> Void) {
        self.morphingShape.path = endingDropletMorphingShapePath.cgPath //Set path to droplet
        
        animateViewContainerToStart { (Bool) in //Animate the view container back
            completionHandler(true) //Informs the caller that this animation is complete
        }
        
        //Morph path animation
        let morphAnimation = CABasicAnimation(keyPath: "path")
        morphAnimation.fromValue = startingDropletMorphingShapePath.cgPath //Looks like the circle path that was used before. But this path is adjusted to morph into the droplet
        morphAnimation.toValue = endingDropletMorphingShapePath.cgPath
        morphAnimation.duration = animationDuration
        morphAnimation.isRemovedOnCompletion = false
        
        morphingShape.add(morphAnimation, forKey: "path")
        
        
        //Setup for droplet layer to fade in after morph is made to show a blue droplet
        
        dropletShapeLayer.path = endingDropletMorphingShapePath.cgPath //Droplet path
        
        dropletShapeLayer.fillColor = StandardColors.waterColor.cgColor
        dropletShapeLayer.strokeColor = StandardColors.primaryColor.cgColor
        dropletShapeLayer.lineWidth = lineWidth
        dropletShapeLayer.opacity = 0
        
        layer.addSublayer(dropletShapeLayer)
        
        //Delay to set the opacity so the morph animation could finish before seeing the blue droplet
        AppDelegate.delay(animationDuration) {
            self.dropletShapeLayer.opacity = 1
        }
        
        //Blue droplet alpha animation
        let dropletOpacityAnimation = CABasicAnimation(keyPath: "opacity")
        dropletOpacityAnimation.fromValue = 0
        dropletOpacityAnimation.toValue = 1
        dropletOpacityAnimation.duration = animationDuration
        dropletOpacityAnimation.beginTime = CACurrentMediaTime() + animationDuration
        dropletOpacityAnimation.isRemovedOnCompletion = false
        
        dropletShapeLayer.add(dropletOpacityAnimation, forKey: "opacity")
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
    
    //MARK: - Private
    
    /**
     Animates the view container with the unit label and text field to the entry point in the outline circle
     
     - parameter completionHandler: When the animation is complete
     */
    private func animateViewContainerToFinish( completionHandler: @escaping (Bool) -> Void) {
        UIView.animate(withDuration: animationDuration, animations: {
            self.viewContainer.frame = self.endingFrame //Frame at ending point
            
            self.unitLabel.transform = CGAffineTransform.identity
            self.unitLabel = self.generateUnitLabel() //Repositions unit label after transform
            
            self.amountTextField.transform = CGAffineTransform.identity
            self.amountTextField = self.generateAmountTextField() //Repositions text field after transform
            
            }) { (Bool) in
                self.amountTextField.becomeFirstResponder()
                completionHandler(true)
        }
    }
    
    /**
     Animates the view container with the unit label and text field to the invisible original custom button point
     
     - parameter completionHandler: When the animation is complete
     */
    private func animateViewContainerToStart( completionHandler: @escaping (Bool) -> Void) {
        let scaleAmount :CGFloat = 0.0001
        amountTextField.resignFirstResponder()

        UIView.animate(withDuration: animationDuration, animations: {
            self.viewContainer.frame = self.startingFrame //Frame at starting custom button point
            
            self.unitLabel.transform = CGAffineTransform(scaleX: scaleAmount, y: scaleAmount)
            self.unitLabel = self.generateUnitLabel() //Repositions unit label after transform
            
            self.amountTextField.transform = CGAffineTransform(scaleX: scaleAmount, y: scaleAmount)
            self.amountTextField = self.generateAmountTextField() //Repositions text field after transform
            
        }) { (Bool) in
            completionHandler(true)
        }
    }
}

//MARK: - Private Generators
extension CustomEntryView {
    func generateViewContainer() -> UIView {
        let view = UIView()
        
        view.clipsToBounds = true
        view.backgroundColor = UIColor.clear
        
        return view
    }
    
    func generateUnitLabel() -> UILabel {
        let label = UILabel()
        
        label.textColor = StandardColors.primaryColor
        label.font = StandardFonts.thinFont(size: 80)
        label.text = standardUnit.rawValue
        label.textAlignment = .left
       // label.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        return label
    }
    
    func generateAmountTextField() -> UITextField {
        let textField = UITextField()
        
        textField.textColor = StandardColors.waterColor
        textField.font = StandardFonts.regularFont(size: 80)
        textField.textAlignment = .right
        textField.keyboardType = .numberPad
        textField.keyboardAppearance = StandardColors.standardKeyboardAppearance
        textField.delegate = self
        textField.tintColor = StandardColors.waterColor
        textField.placeholder = "12"
        //textField.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        return textField
    }
}

// MARK: - UITextFieldDelegate
extension CustomEntryView :UITextFieldDelegate {
    /**
     Determines whether editing should be allowed. Limitations are that only digits may be entered with a max of 3 digits
     
     - returns: Is editing allowed
     */
    func textField( _ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        if Int(string) != nil || isBackSpace == -92 { //Is it a number or a backspace value
            if textField.text!.characters.count + 1 > 3 && isBackSpace != -92  { //Is there less than 3 characters or is this not a backspace
                return false
            } else {
                let character = Array(arrayLiteral: standardUnit.rawValue).first!
                let sizeOfCharacter = character.size(attributes: [NSFontAttributeName : unitLabel.font!]) //Gets size of text based on font and string
                
                let amountToMoveCharacters = sizeOfCharacter.width / 2 //Amount to move text field and unit label
                
                //Shifts the text field and unit label if three numbers are entered
                UIView.animate(withDuration: animationDuration, animations: {
                    if textField.text!.characters.count == 2 && isBackSpace != -92 { //Is there 2 characters and now a third is coming that is not a background
                        
                        //Move everything to the right
                        self.unitLabel.frame = self.unitLabel.frame.offsetBy(dx: amountToMoveCharacters, dy: 0)
                        self.amountTextField.frame = self.amountTextField.frame.offsetBy(dx: amountToMoveCharacters, dy: 0)
                        
                    } else if textField.text!.characters.count == 3 && isBackSpace == -92 { //If there are 3 characters and a backspace is coming to make it two
                        
                        //Move everything to the left
                        self.unitLabel.frame = self.unitLabel.frame.offsetBy(dx: -amountToMoveCharacters, dy: 0)
                        self.amountTextField.frame = self.amountTextField.frame.offsetBy(dx: -amountToMoveCharacters, dy: 0)
                    }
                })
                
                return true
            }
        } else {
            return false
        }
    }
}
