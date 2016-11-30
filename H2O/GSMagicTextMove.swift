//
//  GSMagicTextMove.swift
//  H2O
//
//  Created by Gregory Sapienza on 11/18/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit
import CoreText

class GSMagicLabel :UILabel {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
      
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

protocol GSMagicTextMoveProtocol {
    func animate(to newString :String)
    func getMatchingCharacters(firstString: String, secondString: String, matchingCharacterAction :(Int, Int) -> Void, nonMatchingSecondStringCharacterAction :(Int) -> Void, nonMatchingFirstStringCharacterAction :(Int) -> Void)
    func renderString(from text :String, shapeLayer :(CAShapeLayer) -> Void) -> (positions :[CGPoint], glyphLayers :[CAShapeLayer])
}

extension UILabel :GSMagicTextMoveProtocol, CAAnimationDelegate {
    private static let TextAnimationLayerKey = "TextAnimationLayerKey"
    private static let OriginalColorKey = "OriginalColorKey"
    
    func animate(to newString: String) {
        guard let text = self.text else {
            print("Text is empty.")
            return
        }
        
        let originalColor = textColor
        textColor = UIColor.clear
        self.text = newString

        let textAnimationLayer = CALayer()
        textAnimationLayer.frame = bounds
        layer.addSublayer(textAnimationLayer)
        
        let firstStringLayers = renderString(from: text, shapeLayer: { letterLayer in
            textAnimationLayer.addSublayer(letterLayer)
        })
        
       let secondStringLayers = renderString(from: newString, shapeLayer: { letterLayer in
            letterLayer.transform = CATransform3DMakeScale(0, 0, 0)
            textAnimationLayer.addSublayer(letterLayer)
        })
        
        let firstString = text.replacingOccurrences(of: " ", with: "")
        let secondString = newString.replacingOccurrences(of: " ", with: "")
        
        let animationDuration = 0.4
        
        getMatchingCharacters(firstString: firstString, secondString: secondString, matchingCharacterAction: { index in
            let firstStringLayer = firstStringLayers.glyphLayers[index.0]
            let newFirstStringLayerPosition = secondStringLayers.positions[index.1]
            
            let layerAnimation = CABasicAnimation(keyPath: "position")
            layerAnimation.beginTime = CACurrentMediaTime() + 1
            layerAnimation.duration = animationDuration
            layerAnimation.fromValue = firstStringLayer.position
            layerAnimation.toValue = newFirstStringLayerPosition
            layerAnimation.fillMode = kCAFillModeForwards
            layerAnimation.isRemovedOnCompletion = false
            firstStringLayer.add(layerAnimation, forKey: layerAnimation.keyPath)
            
        }, nonMatchingSecondStringCharacterAction: { index in
            let secondStringLayer = secondStringLayers.1[index]
            
            let layerAnimation = CABasicAnimation(keyPath: "transform.scale")
            layerAnimation.beginTime = CACurrentMediaTime() + 1
            layerAnimation.duration = animationDuration
            layerAnimation.fromValue = 0
            layerAnimation.toValue = 1
            layerAnimation.fillMode = kCAFillModeForwards
            layerAnimation.isRemovedOnCompletion = false
            secondStringLayer.add(layerAnimation, forKey: layerAnimation.keyPath)
            
        }, nonMatchingFirstStringCharacterAction: { index in
            let firstStringLayer = firstStringLayers.glyphLayers[index]
            
            let layerAnimation = CABasicAnimation(keyPath: "transform.scale")
            layerAnimation.beginTime = CACurrentMediaTime() + 1
            layerAnimation.duration = animationDuration
            layerAnimation.fromValue = 1
            layerAnimation.toValue = 0
            layerAnimation.fillMode = kCAFillModeForwards
            layerAnimation.isRemovedOnCompletion = false
            layerAnimation.delegate = self
            layerAnimation.setValue(textAnimationLayer, forKey: UILabel.TextAnimationLayerKey)
            layerAnimation.setValue(originalColor, forKey: UILabel.OriginalColorKey)
            firstStringLayer.add(layerAnimation, forKey: layerAnimation.keyPath)
        })
    }
    
    func renderString(from text: String, shapeLayer :(CAShapeLayer) -> Void) -> (positions :[CGPoint], glyphLayers :[CAShapeLayer]) {
        var letterLayers :[CAShapeLayer] = []
        var letterPositions :[CGPoint] = []
        
        let runFont = CTFontCreateWithName(font.fontName as CFString?, font.pointSize, nil)
        var alignment = CTTextAlignment.center
        let alignmentSetting = [CTParagraphStyleSetting(spec: .alignment, valueSize: MemoryLayout.size(ofValue: alignment), value: &alignment)]
        let paragraphStyle = CTParagraphStyleCreate(alignmentSetting, alignmentSetting.count)

        let attributedString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0)
        CFAttributedStringReplaceString(attributedString, CFRangeMake(0, 0), text as CFString!)
        CFAttributedStringSetAttribute(attributedString, CFRangeMake(0, CFAttributedStringGetLength(attributedString)), kCTFontAttributeName, runFont)
        CFAttributedStringSetAttribute(attributedString, CFRangeMake(0, CFAttributedStringGetLength(attributedString)), kCTParagraphStyleAttributeName, paragraphStyle)
        CFAttributedStringSetAttribute(attributedString, CFRangeMake(0, CFAttributedStringGetLength(attributedString)), kCTKernAttributeName, 0.25 as CFTypeRef!)
        
        let framesetter = CTFramesetterCreateWithAttributedString(attributedString!)
        
        let textSuggestedHeight = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, CFAttributedStringGetLength(attributedString)), nil, CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), nil).height
        
        let textFrame = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.width, height: textSuggestedHeight)
        
        let path = UIBezierPath(rect: textFrame).cgPath
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)
        let lines = CTFrameGetLines(frame)
        
        for index in 0..<CFArrayGetCount(lines) {
            var line = unsafeBitCast(CFArrayGetValueAtIndex(lines, index), to: CTLine.self)
            
            line = CTLineCreateJustifiedLine(line, 0.0, Double(bounds.width))!
            
            var lineOrigin :CGPoint = CGPoint()
            CTFrameGetLineOrigins(frame, CFRangeMake(index, 1), &lineOrigin)
            
            var ascent :CGFloat = CGFloat()
            var descent :CGFloat = CGFloat()
            var leading :CGFloat = CGFloat()
            
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
            
            let runArray = CTLineGetGlyphRuns(line)
            
            for index in 0..<CFArrayGetCount(runArray) {
                let run = unsafeBitCast(CFArrayGetValueAtIndex(runArray, index), to: CTRun.self)
                
                var glyphs = [CGGlyph](repeating: CGGlyph(), count: text.characters.count)
                var positions = [CGPoint](repeating: CGPoint(), count: text.characters.count)
                let range = CFRangeMake(0, 0)
                CTRunGetGlyphs(run, range, &glyphs)
                CTRunGetPositions(run, range, &positions)
                
                var glyphBoundingRects = [CGRect](repeating: CGRect(), count: text.characters.count)
                CTFontGetBoundingRectsForGlyphs(runFont, .default, glyphs, &glyphBoundingRects, text.characters.count)
                
                for glyphIndex in 0..<glyphs.count {
                    let glyph = glyphs[glyphIndex]
                    let position = positions[glyphIndex]
                    let glyphBounds :CGRect = glyphBoundingRects[glyphIndex]
                    
                    if let letter = CTFontCreatePathForGlyph(runFont, glyph, nil) {
                        let letterLayer = CAShapeLayer()
                        letterLayer.path = letter

                        letterLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                        letterLayer.isGeometryFlipped = true
                        letterLayer.bounds = glyphBounds
                        let x = lineOrigin.x + position.x + glyphBounds.minX + glyphBounds.width / 2
                        let y = ascent + position.y - glyphBounds.height / 2 - glyphBounds.minY
                        letterLayer.position = CGPoint(x: x, y: y)
                        //letterLayer.backgroundColor = UIColor.red.cgColor
                        letterLayer.fillColor = UIColor.white.cgColor
                        
                        letterLayers.append(letterLayer)
                        letterPositions.append(CGPoint(x: x, y: y))
                        
                        shapeLayer(letterLayer)
                    } else {
                        print("Letter is nil.")
                    }
                }
            }
        }
        
        return (letterPositions, letterLayers)
    }

    
    func getMatchingCharacters(firstString: String, secondString: String, matchingCharacterAction :(_ firstStringIndex :Int, _ secondStringIndex :Int) -> Void, nonMatchingSecondStringCharacterAction :(Int) -> Void, nonMatchingFirstStringCharacterAction :(Int) -> Void) {
        var charactersFromFirstString = getCharacters(from: firstString)
        
        for (i, character) in secondString.characters.enumerated() {
            if charactersFromFirstString[character] != nil {
                var indexes = charactersFromFirstString[character]
                if let firstStringIndex = indexes?.first {
                    indexes?.remove(at: 0)
                    charactersFromFirstString[character] = indexes
                    
                    let secondStringIndex = i
                    
                    matchingCharacterAction(firstStringIndex, secondStringIndex)
                } else {
                    nonMatchingSecondStringCharacterAction(i)
                }
            } else {
                nonMatchingSecondStringCharacterAction(i)
            }
        }
        
        for character in charactersFromFirstString {
            for index in character.value {
                nonMatchingFirstStringCharacterAction(index)
            }
        }
    }
    
    func getCharacters(from text: String) -> [Character : [Int]] {
        var characters :[Character : [Int]] = [:]
        
        for (i, character) in text.characters.enumerated() {
            if characters[character] == nil {
                characters[character] = [i]
            } else {
                var indexes = characters[character]
                indexes?.append(i)
                characters[character] = indexes
            }
        }
        
        return characters
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let textAnimationLayer = anim.value(forKey: UILabel.TextAnimationLayerKey) as? CALayer,
            let originalColor = anim.value(forKey: UILabel.OriginalColorKey) as? UIColor
            else {
                return
        }
        
        textAnimationLayer.removeFromSuperlayer()
        textColor = originalColor
    }
}
