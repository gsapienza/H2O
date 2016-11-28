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
      
        animate(to: "Set your daily")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = UIColor.black

    }
}

protocol GSMagicTextMoveProtocol {
    func animate(to secondString :String)
    func getMatchingCharacters(firstString: String, secondString: String, matchingCharacterAction :(Int, Int) -> Void, nonMatchingSecondStringCharacterAction :(Int) -> Void, nonMatchingFirstStringCharacterAction :(Int) -> Void)
    func renderString(from text :String, shapeLayer :(CAShapeLayer) -> Void) -> ([CGPoint], [CAShapeLayer])
    func testCoreText(text :String)
}

extension UILabel :GSMagicTextMoveProtocol {
    func testCoreText(text :String) {
        let letters = CGMutablePath()
        
        let runFont = CTFontCreateWithName("Helvetica-Bold" as CFString?, 40.0, nil)//unsafeBitCast(CFDictionaryGetValue(CTRunGetAttributes(run), Unmanaged.passUnretained(kCTFontAttributeName).toOpaque()), to: CTFont.self)
        let attributedString = NSAttributedString(string: text, attributes: [kCTFontAttributeName as String : runFont])

        let line = CTLineCreateWithAttributedString(attributedString)
        let runArray = CTLineGetGlyphRuns(line)
        
        for index in 0..<CFArrayGetCount(runArray) {
            let run = unsafeBitCast(CFArrayGetValueAtIndex(runArray, index), to: CTRun.self)
            for glyphIndex in 0..<CTRunGetGlyphCount(run) {
                var glyph :CGGlyph = CGGlyph()
                var position :CGPoint = CGPoint()
                let range = CFRangeMake(glyphIndex, 1)
                CTRunGetGlyphs(run, range, &glyph)
                CTRunGetPositions(run, range, &position)
                
                if let letter = CTFontCreatePathForGlyph(runFont, glyph, nil) {
                    print(position)
                    
                    let position = CGAffineTransform(translationX: position.x, y: position.y)
                    
                    letters.addPath(letter, transform: position)
                } else {
                    print("Letter is nil.")
                }
            }
        }
        
        let layer = CAShapeLayer()
        
        let path = UIBezierPath()
        path.move(to: CGPoint.zero)
        path.append(UIBezierPath(cgPath: letters))
        layer.path = path.cgPath
        
        layer.isGeometryFlipped = true
        layer.lineWidth = 2
        layer.strokeColor = UIColor.white.cgColor
        layer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(layer)
        
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = 5
        pathAnimation.fromValue = 0.0
        pathAnimation.toValue = 1
        layer.add(pathAnimation, forKey: "strokeEnd")
    }
    
    func animate(to secondString: String) {
        guard let text = self.text else {
            print("Text is empty.")
            return
        }
        
        let firstStringLayers = renderString(from: text, shapeLayer: { letterLayer in
            layer.addSublayer(letterLayer)
        })
        
       /* let secondStringLayers = renderString(from: secondString, shapeLayer: { letterLayer in
            letterLayer.transform = CATransform3DMakeScale(0, 0, 0)
            layer.addSublayer(letterLayer)
        })*/
        
        let firstString = text.replacingOccurrences(of: " ", with: "")
        let secondString = secondString.replacingOccurrences(of: " ", with: "")
        
        getMatchingCharacters(firstString: firstString, secondString: secondString, matchingCharacterAction: { index in
            let firstStringLayer = firstStringLayers.1[index.0]
          //  let newFirstStringLayerPosition = secondStringLayers.0[index.1]
            
            let layerAnimation = CABasicAnimation(keyPath: "position")
            layerAnimation.beginTime = CACurrentMediaTime() + 1
            layerAnimation.duration = 0.7
            layerAnimation.fromValue = firstStringLayer.position
            //layerAnimation.toValue = newFirstStringLayerPosition
            layerAnimation.fillMode = kCAFillModeForwards
            layerAnimation.isRemovedOnCompletion = false
            //firstStringLayer.add(layerAnimation, forKey: "position")
            
            // firstStringLayer.position = newFirstStringLayerPosition
        }, nonMatchingSecondStringCharacterAction: { index in
            //let secondStringLayer = secondStringLayers.1[index]
            
            let layerAnimation = CABasicAnimation(keyPath: "transform.scale")
            layerAnimation.beginTime = CACurrentMediaTime() + 1
            layerAnimation.duration = 0.5
            layerAnimation.fromValue = 0
            layerAnimation.toValue = 1
            layerAnimation.fillMode = kCAFillModeForwards
            layerAnimation.isRemovedOnCompletion = false
            //secondStringLayer.add(layerAnimation, forKey: "transform.scale")
        }, nonMatchingFirstStringCharacterAction: { index in
            let firstStringLayer = firstStringLayers.1[index]
            
            let layerAnimation = CABasicAnimation(keyPath: "transform.scale")
            layerAnimation.beginTime = CACurrentMediaTime() + 1
            layerAnimation.duration = 0.5
            layerAnimation.fromValue = 1
            layerAnimation.toValue = 0
            layerAnimation.fillMode = kCAFillModeForwards
            layerAnimation.isRemovedOnCompletion = false
           // firstStringLayer.add(layerAnimation, forKey: "transform.scale")
        })
        
        
        self.text = secondString
    }
    
    func renderString(from text: String, shapeLayer :(CAShapeLayer) -> Void) -> ([CGPoint], [CAShapeLayer]) {
        var letterLayers :[CAShapeLayer] = []
        var letterPositions :[CGPoint] = []
        
        let runFont = CTFontCreateWithName(font.fontName as CFString?, font.pointSize, nil)//unsafeBitCast(CFDictionaryGetValue(CTRunGetAttributes(run), Unmanaged.passUnretained(kCTFontAttributeName).toOpaque()), to: CTFont.self)
        var alignment = CTTextAlignment.left
        let alignmentSetting = [CTParagraphStyleSetting(spec: .alignment, valueSize: MemoryLayout.size(ofValue: alignment), value: &alignment)]
        let paragraphStyle = CTParagraphStyleCreate(alignmentSetting, alignmentSetting.count)

        let attributedString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0)
        CFAttributedStringReplaceString(attributedString, CFRangeMake(0, 0), text as CFString!)
        CFAttributedStringSetAttribute(attributedString, CFRangeMake(0, CFAttributedStringGetLength(attributedString)), kCTFontAttributeName, runFont)
        CFAttributedStringSetAttribute(attributedString, CFRangeMake(0, CFAttributedStringGetLength(attributedString)), kCTParagraphStyleAttributeName, paragraphStyle)
        
        let framesetter = CTFramesetterCreateWithAttributedString(attributedString!)
        let path = UIBezierPath(rect: bounds).cgPath
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
            
            let lineHeight = ascent + descent + leading

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
                   // let offset = CTLineGetOffsetForStringIndex(line, glyphIndex, nil)
                    
                    if let letter = CTFontCreatePathForGlyph(runFont, glyph, nil) {
                        let letterLayer = CAShapeLayer()
                        letterLayer.path = letter

                        letterLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                        letterLayer.isGeometryFlipped = true
                        letterLayer.bounds = glyphBounds
                        let x = lineOrigin.x + position.x + glyphBounds.minX + glyphBounds.width / 2
                        let y = position.y + lineHeight - lineOrigin.y - letterLayer.bounds.height / 2
                        
                        letterLayer.position = CGPoint(x: x, y: y)
                       // letterLayer.backgroundColor = UIColor.red.cgColor
                        letterLayer.fillColor = UIColor.green.cgColor
                        
                        letterLayers.append(letterLayer)
                        letterPositions.append(position)
                        
                        shapeLayer(letterLayer)
                    } else {
                        print("Letter is nil.")
                    }
                }
            }
        }
        
        return (letterPositions, letterLayers)
    }

    
    func getMatchingCharacters(firstString: String, secondString: String, matchingCharacterAction :(Int, Int) -> Void, nonMatchingSecondStringCharacterAction :(Int) -> Void, nonMatchingFirstStringCharacterAction :(Int) -> Void) {
        var charactersFromFirstString = getCharacters(from: firstString)
        
        for (i, character) in secondString.characters.enumerated() {
            if charactersFromFirstString[character] != nil {
                var indexes = charactersFromFirstString[character]
                if let firstStringIndex = indexes?.first {
                    indexes?.remove(at: 0)
                    charactersFromFirstString[character] = indexes
                    
                    let secondStringIndex = i
                    
                    matchingCharacterAction(firstStringIndex, secondStringIndex)
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
}
