//
//  H2OMainScene.swift
//  H2O
//
//  Created by Gregory Sapienza on 9/14/16.
//  Copyright © 2016 City Pixels. All rights reserved.
//

import SpriteKit
import WatchKit

/// Style of the UI of the scene.
///
/// - normal: Scene style when the app is in the foreground.
/// - dock:   Scene style when the app is in the dock
enum H2OMainSceneStyle {
    case normal
    case dock
}

class H2OMainScene: SKScene {
    //MARK: - Public iVars
    
    /// Fluid node for the water background.
    var fluidNode :GSFluidNode!
    
    /// Amount label displaying how much water was drank today.
    var totalAmountLabel :SKLabelNode!
    
    /// Container holding all entry buttons.
    var entryButtonContainer :SKSpriteNode!
    
    /// First entry preset button.
    var entryButton1 :EntryButtonNode!
    
    /// Second entry preset button.
    var entryButton2 :EntryButtonNode!
    
    /// Third entry preset button.
    var entryButton3 :EntryButtonNode!
    
    /// Custom entry button.
    var customEntryButton :EntryButtonNode!

    //MARK: - Public
    
    override init() {
        super.init()
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        initialize()
    }
    
    func setup() {
        customEntryButton.titleLabel.text = "Custom"
        layout()
        
        totalAmountLabel.text = "0oz"
    }
    
    func switchSceneStyle(style :H2OMainSceneStyle) {
        let animationDuration = 0.3
        
        func normalStyle() {
            let totalAmountLabelPositionAction = SKAction.moveTo(y: size.height - size.height / 5.2, duration: animationDuration)
            totalAmountLabel.run(totalAmountLabelPositionAction)
            
            let totalAmountLabelScaleAction = SKAction.scale(to: 1, duration: animationDuration)
            totalAmountLabel.run(totalAmountLabelScaleAction)
            
            let entryButtonContainerFadeAction = SKAction.fadeIn(withDuration: animationDuration)
            entryButtonContainer.run(entryButtonContainerFadeAction)
        }
        
        func dockStyle() {
            let totalAmountLabelPositionAction = SKAction.moveTo(y: size.height / 2, duration: animationDuration)
            totalAmountLabel.run(totalAmountLabelPositionAction)
            
            let scaleToValue :CGFloat = 1.3 //Scale value of the total amount label.
            
            let totalAmountLabelScaleAction = SKAction.scale(to: scaleToValue, duration: animationDuration)
            totalAmountLabel.run(totalAmountLabelScaleAction)
            
            let entryButtonContainerFadeAction = SKAction.fadeOut(withDuration: animationDuration)
            entryButtonContainer.run(entryButtonContainerFadeAction)
        }
        
        switch style {
        case .normal:
            normalStyle()
        case .dock:
            dockStyle()
        }
    }
    
    //MARK: - Private
    
    /// Initializes all nodes in scene
    private func initialize() {
        fluidNode = generateFluidNode()
        totalAmountLabel = generateTotalAmountLabel()
        entryButtonContainer = generateEntryButtonContainer()
        entryButton1 = generateEntryButton()
        entryButton2 = generateEntryButton()
        entryButton3 = generateEntryButton()
        customEntryButton = generateEntryButton()
    }
    
    /// Lays out the positions and sizes of all nodes.
    private func layout() {
        let centerPoint = CGPoint(x: size.width / 2, y: size.height / 2) //Center point of scene.
        let entryButtonSize = CGSize(width: 65, height: 40) //Size of each entry button.
        let verticalDistanceBetweenTotalAndEntryButtons :CGFloat = 45 //Distance between the total amount label and the entry buttons.
        let distanceBetweenEntryButtons :CGFloat = 6 //Horizontal and vertical distance between enrtry buttons.
        
        //---Fluid Node---
        fluidNode.position = CGPoint(x: 0, y: 0)
        fluidNode.size = size
        fluidNode.layout()
        addChild(fluidNode)
        
        //---Total Amount Label---
        totalAmountLabel.position = CGPoint(x: centerPoint.x, y: size.height - 35) //35 is decided based on aesthetic look of the position.
        addChild(totalAmountLabel)
        
        //---Entry Button Container---
        let entryButtonYValue = totalAmountLabel.position.y - verticalDistanceBetweenTotalAndEntryButtons
        entryButtonContainer.position = CGPoint(x: 0, y: entryButtonYValue)
        entryButtonContainer.size = CGSize(width: size.width, height: size.height - entryButtonYValue)
        addChild(entryButtonContainer)
        
        //---Entry Button 1---
        entryButton1.position = CGPoint(x: centerPoint.x - entryButtonSize.width / 2 - distanceBetweenEntryButtons / 2, y: 0)
        entryButton1.size = entryButtonSize
        entryButtonContainer.addChild(entryButton1)
        entryButton1.layout()
        
        //---Entry Button 2---
        entryButton2.position = CGPoint(x: centerPoint.x + entryButtonSize.width / 2 + distanceBetweenEntryButtons / 2, y: 0)
        entryButton2.size = entryButtonSize
        entryButtonContainer.addChild(entryButton2)
        entryButton2.layout()
        
        //---Entry Button 3---
        entryButton3.position = CGPoint(x: centerPoint.x - entryButtonSize.width / 2 - distanceBetweenEntryButtons / 2, y: entryButton1.position.y - entryButtonSize.height - distanceBetweenEntryButtons)
        entryButton3.size = entryButtonSize
        entryButtonContainer.addChild(entryButton3)
        entryButton3.layout()
        
        //---Custom Entry Button---
        customEntryButton.position = CGPoint(x: centerPoint.x + entryButtonSize.width / 2 + distanceBetweenEntryButtons / 2, y: entryButton2.position.y - entryButtonSize.height - distanceBetweenEntryButtons)
        customEntryButton.size = entryButtonSize
        entryButtonContainer.addChild(customEntryButton)
        customEntryButton.layout()
    }
}


// MARK: - Private Generators
private extension H2OMainScene {
    
    /// Generates a SKNode for the liquid.
    ///
    /// - returns: SKNode representing water colored liquid.
    func generateFluidNode() -> GSFluidNode {
        let node = GSFluidNode()
        node.color = UIColor.black
        node.liquidFillColor = StandardColors.waterColor
        
        return node
    }
    
    /// Generates a SKLabel for the amount of water drank.
    ///
    /// - returns: SKLabel for total water.
    func generateTotalAmountLabel() -> SKLabelNode {
        let node = SKLabelNode()
        node.fontColor = UIColor.white
        node.fontSize = 45
        node.fontName = UIFont.boldSystemFont(ofSize: node.fontSize).fontName
        
        return node
    }
    
    /// Generates background for an entry button.
    ///
    /// - returns: Button with border for entry button.
    func generateEntryButton() -> EntryButtonNode {
        let node = EntryButtonNode()
        node.texture = SKTexture(assetIdentifier: .entryButton) //Default button texture for background.
        node.color = UIColor.clear
        node.initialize()
        
        return node
    }
    
    /// Generates a container node to store entry buttons.
    ///
    /// - returns: Container node for entry buttons.
    func generateEntryButtonContainer() -> SKSpriteNode {
        let node = SKSpriteNode()
        node.color = UIColor.clear
        
        return node
    }
}
