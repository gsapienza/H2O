//
//  EntryButtonNode.swift
//  H2O
//
//  Created by Gregory Sapienza on 9/15/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import SpriteKit

class EntryButtonNode: SKSpriteNode {
    
    //MARK: - Public iVars
    
    /// Label describing the amount of water that the button will add.
    var titleLabel :SKLabelNode!
    
    /// Amount that button will add to goal, sets the titleLabel to this value plus the unit following.
    var amount :Float = 0 {
        didSet {
            titleLabel.text = String(Int(amount)) + standardUnit.rawValue
        }
    }
    
    /// Set to whether the button should be highlighted or not. Changes the button background and text color.
    var highlighted :Bool = false {
        didSet {
            if highlighted {
                titleLabel.fontColor = StandardColors.waterColor
                let texture = SKTexture(assetIdentifier: .highlightedEntryButton)
                self.texture = texture
            } else {
                titleLabel.fontColor = UIColor.white
                let texture = SKTexture(assetIdentifier: .entryButton)
                self.texture = texture
            }
        }
    }
    
    //MARK: - Public
    
    /// Initializes sub nodes. Made public due to no plain init function being present on SKNode.
    func initialize() {
        titleLabel = generateEntryButtonLabel()
    }
    
    /// Lays out positions and sizes of subnodes.
    func layout() {
        //---Title Label---
        titleLabel.position = CGPoint(x: 0, y: -(titleLabel.frame.height / 2))
        addChild(titleLabel)
    }
}

// MARK: - Private Generators
private extension EntryButtonNode {
    
    /// Generates a label to be used as the title label representing the button.
    ///
    /// - returns: Label node for title.
    func generateEntryButtonLabel() -> SKLabelNode {
        let node = SKLabelNode()
        node.fontColor = UIColor.white
        node.fontSize = 16
        node.fontName = UIFont.systemFont(ofSize: node.fontSize).fontName
        
        return node
    }
}
