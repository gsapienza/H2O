//
//  CustomEntryView.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/18/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

protocol CustomEntryViewProtocol {
    
    /// Gets drop view as its animating
    ///
    /// - parameter layer: Layer animating
    func dropletLayerDidUpdate(layer :GSAnimatingProgressLayer)
}

class CustomEntryView: UIView {
    //MARK: - Public iVars
    
    /// Text field where the user can enter how much water they drank
    var amountTextField :UITextField!
    
    /// Frame for custom button that should be used in custom button path
    var customButtonFrame :CGRect!
    
    /// Corner radius of custom button that should be used in custom button path
    var customButtonCornerRadius :CGFloat!
    
    /// Frame for circle dial that should be used in circle dial path
    var circleDialFrame :CGRect!
    
    /// Corner radius of circle dial that should be used in circle path
    var circleDialCornerRadius :CGFloat!
    
    /// Frame for droplet that should be used when sending it to the bottom of the screen
    var dropletAtBottomFrame :CGRect!
    
    /// Delegate to send messages containing updates to layer
    var delegate :CustomEntryViewProtocol?
    
    //MARK: - Private iVars
    
    /// View that contains the amount text field and unit label. Combined to make positioning everything easier
    private var viewContainer :UIView!
    
    /// Shape of outlining circle that will be morphed
    private var customButtonToDialCircleShapeLayer :CAShapeLayer!
    
    /// Layer for the blue droplet that appears after the circle path transforms into the droplet path
    var dropletShapeLayer :GSAnimatingProgressLayer!
    
    /// Standard outline width for shapes
    private let lineWidth :CGFloat = 0.5
    
    /// Path for custom button
    private var customButtonPath :CGPath {
        return generateCustomButtonShapePath(frame: customButtonFrame, cornerRadius: customButtonCornerRadius).cgPath
    }
    
    /// Path for circle dial
    private var circleDialPath :CGPath {
        return generateCircleShapePath(frame: circleDialFrame, cornerRadius: circleDialCornerRadius).cgPath
    }
    
    /// Path for the droplet resembling a circle before transforming to a droplet
    private var circleDropletPath :CGPath {
        return generateCircleDropletShapePath(frame: circleDialFrame).cgPath
    }
    
    /// Path for droplet when at middle of screen
    private var dropletAtMiddlePath :CGPath {
        return generateMiddleOfViewDropletShapePath(frame: circleDialFrame).cgPath
    }
    
    /// Path for droplet when at bottom of screen
    private var dropletAtBottomPath :CGPath {
        return generateBottomOfViewDropletMorphingShapePath(frame: dropletAtBottomFrame).cgPath
    }
    
    /// Center point of custom button
    private var customButtonCenterPoint :CGPoint {
        return CGPoint(x: customButtonFrame.origin.x + (customButtonFrame.width / 2), y: customButtonFrame.origin.y + (customButtonFrame.height / 2))
    }
    
    /// Center point of the circle dial
    private var circleDialCenterPoint :CGPoint {
        return CGPoint(x: circleDialFrame.origin.x + (circleDialFrame.width / 2), y: circleDialFrame.origin.y + (circleDialFrame.height / 2))
    }
    
    //MARK: - Internal iVars
    
    /// Unit of measurement label next to the amount text field
    var unitLabel :UILabel!
    
    /// Standard animation time for all animations in this view
    let animationDuration = 0.25
    
    //MARK: - View Setup
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        viewContainer = generateViewContainer()
        unitLabel = generateUnitLabel()
        amountTextField = generateAmountTextField()
        customButtonToDialCircleShapeLayer = generateCustomButtonToDialCircleShapeLayer(lineWidth: lineWidth)
        dropletShapeLayer = generateDropletShapeLayer()
        
        layout()
    }
    
    /// Layout view positions
    private func layout() {
        //---View Container---
        
        viewContainer.frame = CGRect(x: 0, y: 0, width: circleDialFrame.width, height: circleDialFrame.height)
        viewContainer.center = customButtonCenterPoint
        viewContainer.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        addSubview(viewContainer)
        
        //---Amount Text Field---
        
        amountTextField.frame = CGRect(x: 0, y: 0, width: viewContainer.bounds.width / 2, height: viewContainer.bounds.height)
        viewContainer.addSubview(amountTextField)
        
        //---Unit Label---
        
        unitLabel.frame = CGRect(x: viewContainer.bounds.width / 2, y: 0, width: viewContainer.bounds.width / 2, height: viewContainer.bounds.height)
        viewContainer.addSubview(unitLabel)
        
        layer.addSublayer(customButtonToDialCircleShapeLayer)

        layer.addSublayer(dropletShapeLayer)

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
    
    //MARK: - Public
    
    /**
     Animation to morph the to the outlining circle for user entry
     
     - parameter circleDialFrame:     Frame of the final circle
     - parameter circleDialCornerRadius: Corner radius of the circle
     */
    func animateFromCustomButtonPathToCirclePath(completionHandler: @escaping (Bool) -> Void) {
        customButtonToDialCircleShapeLayer.path = circleDialPath //Set the path before animating
        
        animateViewContainer(toCenter: circleDialCenterPoint, transform: CGAffineTransform.identity) { (Bool) in //Animates the view container to be visble to the user
            self.amountTextField.becomeFirstResponder()
            completionHandler(true)
        }
        

        //Custom Button To Circle Dial Animation
        let customButtonToDialCircleAnimation = CABasicAnimation(keyPath: "path")
        customButtonToDialCircleAnimation.fromValue = customButtonPath
        customButtonToDialCircleAnimation.toValue = circleDialPath
        customButtonToDialCircleAnimation.duration = animationDuration
        
        customButtonToDialCircleShapeLayer.add(customButtonToDialCircleAnimation, forKey: "path")
    }
    
    /**
     Animation to morph the outline circle back into a custom button shape
     
     - parameter completionHandler: Completion of animation of the view container. Not necassarily the morph
     */
    func animateFromDialCirclePathToCustomButtonPath(completionHandler: @escaping (Bool) -> Void) {
        amountTextField.resignFirstResponder()

        animateViewContainer(toCenter: customButtonCenterPoint, transform: CGAffineTransform(scaleX: 0.0001, y: 0.0001)) { (Bool) in //Animates the view container to be visble to the user
            completionHandler(true) //Informs the caller that this animation is complete
        }
        
        self.customButtonToDialCircleShapeLayer.path = customButtonPath
        
        //Circle dial to custom button animation
        let dialCircleToCustomButtonAnimation = CABasicAnimation(keyPath: "path")
        dialCircleToCustomButtonAnimation.fromValue = circleDialPath
        dialCircleToCustomButtonAnimation.toValue = customButtonPath
        dialCircleToCustomButtonAnimation.duration = animationDuration
        dialCircleToCustomButtonAnimation.fillMode = kCAFillModeBackwards
        dialCircleToCustomButtonAnimation.isRemovedOnCompletion = false
        
        customButtonToDialCircleShapeLayer.add(dialCircleToCustomButtonAnimation, forKey: "path")
    }
    
    /**
     Morphs circle into droplet and falls to bottom of screen
     
     - parameter completionHandler: Completion of animation of the view container. Not necassarily the morph
     */
    func animateToDropletPathAndDrop(completionHandler: @escaping (Bool) -> Void) {
        amountTextField.resignFirstResponder()

        animateViewContainer(toCenter: customButtonCenterPoint, transform: CGAffineTransform(scaleX: 0.0001, y: 0.0001)) { (Bool) in //Animates the view container to be visble to the user
            completionHandler(true) //Informs the caller that this animation is complete
        }
        
        customButtonToDialCircleShapeLayer.path = circleDropletPath
        
        //Morph circle dial to a droplet look with a white outline
        let dialCircleToDropletAnimation = CABasicAnimation(keyPath: "path")
        dialCircleToDropletAnimation.fromValue = circleDropletPath
        dialCircleToDropletAnimation.toValue = dropletAtMiddlePath
        dialCircleToDropletAnimation.duration = animationDuration
        dialCircleToDropletAnimation.fillMode = kCAFillModeBackwards
        customButtonToDialCircleShapeLayer.add(dialCircleToDropletAnimation, forKey: "path")
        
        customButtonToDialCircleShapeLayer.path = nil //Remove the circle layer that now looks like a droplet so that we can work with an actual droplet path to animate the blue layer in

        //Setup for droplet layer to fade in after morph is made to show a blue droplet
        
        //Blue droplet opacity animation
        let dropletOpacityAnimation = CABasicAnimation(keyPath: "opacity")
        dropletOpacityAnimation.fromValue = 0
        dropletOpacityAnimation.toValue = 1
        dropletOpacityAnimation.duration = animationDuration
        dropletOpacityAnimation.beginTime = CACurrentMediaTime() + animationDuration * 0.6 //Begin after the circle layer, multiplied by 0.6 because I like the timing and transition better
        dropletOpacityAnimation.fillMode = kCAFillModeBackwards
        dropletOpacityAnimation.isRemovedOnCompletion = false
        dropletShapeLayer.add(dropletOpacityAnimation, forKey: "opacity")
        
        //Make the drop fall
        let dropletFallAnimation = CABasicAnimation(keyPath: "path")
        dropletFallAnimation.fromValue = dropletAtMiddlePath
        dropletFallAnimation.toValue = dropletAtBottomPath
        dropletFallAnimation.duration = animationDuration * 1.5
        dropletFallAnimation.fillMode = kCAFillModeBackwards
        dropletFallAnimation.beginTime = dropletOpacityAnimation.beginTime + animationDuration
        dropletFallAnimation.isRemovedOnCompletion = false
        dropletFallAnimation.setValue("path", forKey: gSAnimationID)
        dropletFallAnimation.delegate = dropletShapeLayer
        dropletShapeLayer.add(dropletFallAnimation, forKey: "path")
    }
    
    /// When an invalid entry is made, this will shake the circle path and the view container to indicate an incorrect entry
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
    private func animateViewContainer(toCenter: CGPoint, transform :CGAffineTransform, completionHandler: @escaping (Bool) -> Void) {
        UIView.animate(withDuration: animationDuration * 1.5, animations: {
            self.viewContainer.center = toCenter
            self.viewContainer.transform = transform
            
            }) { (Bool) in
                self.amountTextField.text = "" //Sets the entry text to blank
                completionHandler(true)
        }
    }
}

//MARK: - Private Generators
extension CustomEntryView {
    
    /// Generates a container to hold the text field the unitlabel
    ///
    /// - returns: View container
    func generateViewContainer() -> UIView {
        let view = UIView()
        
        view.clipsToBounds = true
        view.backgroundColor = UIColor.clear
        
        return view
    }
    
    /// Generates a unit label dispaying the unit of measurement
    ///
    /// - returns: Label of unit of measurement
    func generateUnitLabel() -> UILabel {
        let label = UILabel()
        
        label.textColor = StandardColors.primaryColor
        label.font = StandardFonts.thinFont(size: 80)
        label.text = standardUnit.rawValue
        label.textAlignment = .left
        label.baselineAdjustment = .alignCenters
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }
    
    /// Generates a number text field to enter a new value
    ///
    /// - returns: Text field for numbers
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
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 30
        
        return textField
    }
    
    /// Generates the shape layer that will convert from custom button -> circle dial outling -> droplet
    ///
    /// - parameter lineWidth: Width of the stroke
    ///
    /// - returns: Shape layer to animate
    func generateCustomButtonToDialCircleShapeLayer(lineWidth :CGFloat) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        
        shapeLayer.lineWidth = lineWidth
        shapeLayer.strokeColor = StandardColors.primaryColor.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        return shapeLayer
    }
    
    /// Generates a droplet layer to use for fading in and dropping
    ///
    /// - returns: Shape layer for droplet
    func generateDropletShapeLayer() -> GSAnimatingProgressLayer {
        let shapeLayer = GSAnimatingProgressLayer()
        
        shapeLayer.opacity = 1 //Droplet final opacity
        shapeLayer.fillColor = StandardColors.waterColor.cgColor
        shapeLayer.progressDelegate = self
        shapeLayer.keyValuesToMonitor = ["path"]
        
        return shapeLayer
    }
    
    /// Generates custom button path
    ///
    /// - parameter frame:        Frame of custom button
    /// - parameter cornerRadius: Corner radius of the custom button
    ///
    /// - returns: Path resembling custom button
    func generateCustomButtonShapePath(frame :CGRect, cornerRadius :CGFloat) -> UIBezierPath {
        let path = UIBezierPath(roundedRect: CGRect(x: frame.origin.x, y: frame.origin.y, width: floor(frame.width * 1.00000 + 0.5) - floor(frame.width * 0.00000 + 0.5), height: floor(frame.height * 1.00000 + 0.5) - floor(frame.height * 0.00000 + 0.5)), cornerRadius: cornerRadius)
        
        return path
    }
    
    /// Generates circle outline path that is the size of the dial
    ///
    /// - parameter frame:        Frame of dial
    /// - parameter cornerRadius: Corner radius of the circle dial
    ///
    /// - returns: Path resembling the outer circle dial
    func generateCircleShapePath(frame :CGRect, cornerRadius :CGFloat) -> UIBezierPath {
        let path = UIBezierPath(roundedRect: CGRect(x: frame.origin.x, y: frame.origin.y, width: floor(frame.width * 1.00000 + 0.5) - floor(frame.width * 0.00000 + 0.5), height: floor(frame.height * 1.00000 + 0.5) - floor(frame.height * 0.00000 + 0.5)), cornerRadius: cornerRadius)
        
        return path
    }
    
    /// Generates a circle that resembles the circle shape path and has enough control points to morph into the droplet
    ///
    /// - parameter frame: Frame of the circle dial
    ///
    /// - returns: Path resembling the outer circle dial
    func generateCircleDropletShapePath(frame :CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.51044 * frame.height))
        path.addCurve(to: CGPoint(x: frame.minX + 0.50000 * frame.width, y: frame.minY + 1.00000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.78114 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.22484 * frame.width, y: frame.minY + 1.00000 * frame.height))
        path.addCurve(to: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 0.51044 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.77516 * frame.width, y: frame.minY + 1.00000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 0.78114 * frame.height))
        path.addCurve(to: CGPoint(x: frame.minX + 0.50000 * frame.width, y: frame.minY + 0.00000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 0.18923 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.75817 * frame.width, y: frame.minY + 0.00000 * frame.height))
        path.addCurve(to: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.51044 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.24183 * frame.width, y: frame.minY + 0.00000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.18855 * frame.height))
        path.close()
        path.usesEvenOddFillRule = true
        
        return path
    }
    
    /// Generates a droplet path to appear in the middle of the screen where the dial is located
    ///
    /// - parameter frame: Frame of the circle dial where the drop will appear
    ///
    /// - returns: Path of liquid drop
    func generateMiddleOfViewDropletShapePath(frame :CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: frame.minX + 0.29583 * frame.width, y: frame.minY + 0.62993 * frame.height))
        path.addCurve(to: CGPoint(x: frame.minX + 0.50000 * frame.width, y: frame.minY + 0.81667 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.29583 * frame.width, y: frame.minY + 0.73319 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.38764 * frame.width, y: frame.minY + 0.81667 * frame.height))
        path.addCurve(to: CGPoint(x: frame.minX + 0.70417 * frame.width, y: frame.minY + 0.62993 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.61236 * frame.width, y: frame.minY + 0.81667 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.70417 * frame.width, y: frame.minY + 0.73319 * frame.height))
        path.addCurve(to: CGPoint(x: frame.minX + 0.50133 * frame.width, y: frame.minY + 0.17917 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.70417 * frame.width, y: frame.minY + 0.50741 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.50133 * frame.width, y: frame.minY + 0.17917 * frame.height))
        path.addCurve(to: CGPoint(x: frame.minX + 0.29583 * frame.width, y: frame.minY + 0.62993 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.50133 * frame.width, y: frame.minY + 0.17917 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.29583 * frame.width, y: frame.minY + 0.50715 * frame.height))
        path.close()
        path.usesEvenOddFillRule = true
        
        return path
    }
    
    /// Generates a droplet path to appear at the bottom of the screen
    ///
    /// - parameter frame: Frame of the droplet at the bottom of the screen
    ///
    /// - returns: Path of liquid drop located at bottom of screen
    func generateBottomOfViewDropletMorphingShapePath(frame :CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: frame.minX + 0.29583 * frame.width, y: frame.minY + 0.62993 * frame.height))
        path.addCurve(to: CGPoint(x: frame.minX + 0.50000 * frame.width, y: frame.minY + 0.81667 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.29583 * frame.width, y: frame.minY + 0.73319 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.38764 * frame.width, y: frame.minY + 0.81667 * frame.height))
        path.addCurve(to: CGPoint(x: frame.minX + 0.70417 * frame.width, y: frame.minY + 0.62993 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.61236 * frame.width, y: frame.minY + 0.81667 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.70417 * frame.width, y: frame.minY + 0.73319 * frame.height))
        path.addCurve(to: CGPoint(x: frame.minX + 0.50133 * frame.width, y: frame.minY + 0.17917 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.70417 * frame.width, y: frame.minY + 0.50741 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.50133 * frame.width, y: frame.minY + 0.17917 * frame.height))
        path.addCurve(to: CGPoint(x: frame.minX + 0.29583 * frame.width, y: frame.minY + 0.62993 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.50133 * frame.width, y: frame.minY + 0.17917 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.29583 * frame.width, y: frame.minY + 0.50715 * frame.height))
        path.close()
        path.usesEvenOddFillRule = true
        
        return path
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
        let backSpaceUnicodeValue :Int32 = -92
        
        if Int(string) != nil || isBackSpace == backSpaceUnicodeValue { //Is it a number or a backspace value
            if textField.text!.characters.count + 1 > 3 && isBackSpace != backSpaceUnicodeValue  { //Is there less than 3 characters or is this not a backspace
                return false
            } else {
                let character = Array(arrayLiteral: standardUnit.rawValue).first!
                let sizeOfCharacter = character.size(attributes: [NSFontAttributeName : unitLabel.font!]) //Gets size of text based on font and string
                
                let amountToMoveCharacters = sizeOfCharacter.width / 2 //Amount to move text field and unit label
                
                //Shifts the text field and unit label if three numbers are entered
                UIView.animate(withDuration: animationDuration, animations: {
                    if textField.text!.characters.count == 2 && isBackSpace != backSpaceUnicodeValue { //Is there 2 characters and now a third is coming that is not a background
                        
                        //Move everything to the right
                        self.unitLabel.frame = self.unitLabel.frame.offsetBy(dx: amountToMoveCharacters, dy: 0)
                        self.amountTextField.frame = self.amountTextField.frame.offsetBy(dx: amountToMoveCharacters, dy: 0)
                        
                    } else if textField.text!.characters.count == 3 && isBackSpace == backSpaceUnicodeValue { //If there are 3 characters and a backspace is coming to make it two
                        
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

// MARK: - GSAnimatingProgressLayerProtocol
extension CustomEntryView :GSAnimatingProgressLayerProtocol {
    func layerDidUpdate(key: String) {
       // print(dropletShapeLayer.presentation()!.path?.boundingBoxOfPath)
        delegate?.dropletLayerDidUpdate(layer: dropletShapeLayer)
    }
}
