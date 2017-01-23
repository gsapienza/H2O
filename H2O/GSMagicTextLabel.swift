//
//  GSMagicTextMove.swift
//  H2O
//
//  Created by Gregory Sapienza on 11/18/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit
import CoreText

class GSMagicTextLabel :UIView, CAAnimationDelegate {
    
    //MARK: - Public iVars
    
    /// Text to display with label.
    var text :String? {
        set {
            if text != newValue {
                _text = newValue
                needsTextRender = true
                layoutIfNeeded()
            }
        }
        
        get {
            return self._text
        }
    }
    
    /// Label text color.
    var textColor = UIColor.black {
        didSet {
            needsTextRender = true
            layoutIfNeeded()
        }
    }

    /// Label font.
    var font = UIFont.systemFont(ofSize: 17) {
        didSet {
            needsTextRender = true
            layoutIfNeeded()
        }
    }
    
    /// Label text alignment.
    var textAlignment = NSTextAlignment.left {
        didSet {
            needsTextRender = true
            layoutIfNeeded()
        }
    }
    
    //MARK: - Private iVars
    
    /// Backing text string.
    private var _text: String?
    
    /// Array of CAShapeLayers to store glyph path layers that are displayed as sublayers.
    private var glyphLayers :[CAShapeLayer] = []
    
    /// Array of rects to use for glyph layers displayed as sublayers.
    private var glyphRects :[CGRect] = []
    
    /// Does a call to layoutSubviews need to reset the text displayed in view.
    private var needsTextRender = true
    
    //MARK: - Public
    
    /// Glyph layers must be added here because in order to render the glyphs. The text frame is needed and it is only set by this point.
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard needsTextRender == true else { //If the text needs to be redisplayed.
            return
        }
        
        guard let text = self.text else {
            print("Text is nil.")
            return
        }
        
        for glyphLayer in glyphLayers { //Remove all glyph layers on screen.
            glyphLayer.removeFromSuperlayer()
        }
        
        glyphLayers.removeAll() //Clear the array.
        
        guard let glyphLayers = getGlyphLayers(text: text, color: textColor) else { //New glyphs.
            print("Glyph layers are nil.")
            return
        }
        
        self.glyphLayers = glyphLayers

        for glyphLayer in glyphLayers { //Add the glyph layers to layer.
            layer.addSublayer(glyphLayer)
        }
        
       //backgroundColor = UIColor.red
       
        glyphRects.removeAll() //Clear the previous rects from the array.
        
        guard let glyphRects = getGlyphRects(text: text) else { //New rects.
            print("Glyph rects are nil.")
            return
        }
        
        self.glyphRects = glyphRects
        
        for (i, rect) in glyphRects.enumerated() {
            glyphLayers[i].position = CGPoint(x: rect.origin.x, y: rect.origin.y) //Set the position for the layers on screen.
        }
        
        needsTextRender = false //We don't need a text rerender next time this function is called.
    }
    
    /// Animates string of label to a new string.
    ///
    /// - Parameter newString: String to show after animation.
    /// - Parameter completion: Animation completion block.
    func animate(to newString: String, completion :(Bool) -> Void) {
        guard let text = self.text else {
            print("Text is empty.")
            return
        }
        
        guard let secondStringGlyphLayers = getGlyphLayers(text: newString, color: textColor) else { //Second string glyph layers.
            print("Second string glyph layers are nil.")
            return
        }
        
        guard let secondStringGlyphRects = getGlyphRects(text: newString) else { //Second string glyph rects.
            print("Second string glyph rects are nil.")
            return
        }
        
        for (i, glyphLayer) in secondStringGlyphLayers.enumerated() { //For each glyph layer, set properties and add as a subblayer.
            let rect = secondStringGlyphRects[i]
            glyphLayer.position = CGPoint(x: rect.origin.x, y: rect.origin.y)
            glyphLayer.bounds = CGRect(x: glyphLayer.bounds.origin.x, y: glyphLayer.bounds.origin.y, width: rect.width, height: rect.height)
            glyphLayer.transform = CATransform3DMakeScale(0, 0, 0) //Sets the scale to 0. When animating the layers in, the nonmatching glyph layers will animate their scale to 1.
            layer.addSublayer(glyphLayer) //Adds sublayer every time a new shape layer has been created for a glyph in the second string.
        }
        
        
        //Removes spaces for first and second string.
        let firstString = text.replacingOccurrences(of: " ", with: "")
        let secondString = newString.replacingOccurrences(of: " ", with: "")
        
        let animationDuration = 0.4 //Duration for all animations involved.
        
        getMatchingCharacters(firstString: firstString, secondString: secondString, matchingCharacterAction: { index in
            let firstStringLayer = self.glyphLayers[index.0] //Layer for matching character.
            let newFirstStringLayerPosition = secondStringGlyphRects[index.1] //New position of glyph coming from first string but now animating to second string.
            
            let layerAnimation = CABasicAnimation(keyPath: "position")
            layerAnimation.duration = animationDuration
            layerAnimation.fromValue = firstStringLayer.position //Position in first string.
            layerAnimation.toValue = newFirstStringLayerPosition.origin //Position in second string.
            layerAnimation.fillMode = kCAFillModeForwards
            layerAnimation.isRemovedOnCompletion = false
            firstStringLayer.add(layerAnimation, forKey: layerAnimation.keyPath)
            
        }, nonMatchingSecondStringCharacterAction: { index in
            let secondStringLayer = secondStringGlyphLayers[index] //Layer for glyphs not matching in the second string.
            
            let layerAnimation = CABasicAnimation(keyPath: "transform.scale") //Animates glyphs by scaling them to 1.
            layerAnimation.duration = animationDuration
            layerAnimation.fromValue = 0
            layerAnimation.toValue = 1
            layerAnimation.fillMode = kCAFillModeForwards
            layerAnimation.isRemovedOnCompletion = false
            secondStringLayer.add(layerAnimation, forKey: layerAnimation.keyPath)
            
        }, nonMatchingFirstStringCharacterAction: { index in
            let firstStringLayer = self.glyphLayers[index] //Layer for glyphs not matching in the first string.
            
            let layerAnimation = CABasicAnimation(keyPath: "transform.scale") //Animates glyphs by scaling them to 0.
            layerAnimation.duration = animationDuration
            layerAnimation.fromValue = 1
            layerAnimation.toValue = 0
            layerAnimation.fillMode = kCAFillModeForwards
            layerAnimation.isRemovedOnCompletion = false
            layerAnimation.delegate = self
            firstStringLayer.add(layerAnimation, forKey: layerAnimation.keyPath)
        })
    }
    
    //MARK: - Private
    
    /// Get glyph bound rects for a string.
    ///
    /// - Parameter text: String to get glyph rects for.
    /// - Returns: An optional array of CGRects, one for each glyph to display.
    private func getGlyphRects(text :String) -> [CGRect]? {
        var glyphRects :[CGRect] = [] //Array of glyph positions to return.

        guard let attributedString = getTextAttributes(text :text) else { //Create attributed string from label text.
            print("Attributed String is nil.")
            return nil
        }
        
        let linesInFrame = getLinesForAttributedString(attributedString: attributedString) //Get a frame of lines for the string as well as the lines themselves.
        
        for index in 0..<CFArrayGetCount(linesInFrame.lines) {
            let line = unsafeBitCast(CFArrayGetValueAtIndex(linesInFrame.lines, index), to: CTLine.self) //Line for index
            
            var lineOrigin :CGPoint = CGPoint()
            CTFrameGetLineOrigins(linesInFrame.frame, CFRangeMake(index, 1), &lineOrigin) //Get the origin of the line.
            
            var ascent :CGFloat = CGFloat()
            var descent :CGFloat = CGFloat()
            var leading :CGFloat = CGFloat()
            
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading) //Get the ascent, descent and leading values for the line.
            
            //let lineHeight = ascent + descent + leading

            let runArray = CTLineGetGlyphRuns(line) //Get runs from the line.
            
            for index in 0..<CFArrayGetCount(runArray) {
                let run = unsafeBitCast(CFArrayGetValueAtIndex(runArray, index), to: CTRun.self) //Run for index in line.
                
                var glyphs = [CGGlyph](repeating: CGGlyph(), count: text.characters.count) //Allocated space for array of glyphs.
                var positions = [CGPoint](repeating: CGPoint(), count: text.characters.count) //Allocated space for array of positions of glyphs.
                
                CTRunGetGlyphs(run, CFRangeMake(0, 0), &glyphs) //Get array of glyphs in run.
                CTRunGetPositions(run, CFRangeMake(0, 0), &positions) //Get array of positions of glyphs in run.
                
                guard let font = CFAttributedStringGetAttribute(attributedString, 0, kCTFontAttributeName, nil) as! CTFont? else { //Get the font from the attributed string.
                    print("Font is nil.")
                    return nil
                }
                
                var glyphBoundingRects = [CGRect](repeating: CGRect(), count: text.characters.count) //Allocated space for array of bounding boxes of glyphs.
                CTFontGetBoundingRectsForGlyphs(font, .default, glyphs, &glyphBoundingRects, text.characters.count) //Get array of bounding boxes of glyphs in run.
                
                for glyphIndex in 0..<glyphs.count { //For each glyph in run.
                    let position = positions[glyphIndex] //Position of glyph for index.
                    let glyphBounds :CGRect = glyphBoundingRects[glyphIndex] //Bounding box of glyph for index.
                    
                    let x = lineOrigin.x + position.x + glyphBounds.minX + glyphBounds.width / 2 //Sets the x origin to the line origin (text alignment) + the x position of the glyph + the glyphBounds x origin (addresses minor offsets) + half the width of the bounds since the anchor point is set in the middle of the layer.
                    
                    let y = bounds.height - glyphBounds.height / 2 - glyphBounds.minY //This displays the text at the bottom of the view. I want this in the middle 😡
                    
                    let rect = CGRect(x: x, y: y, width: glyphBounds.width, height: glyphBounds.height)
                    
                    if rect.width != 0 && rect.height != 0 { //If the rect has a width and height then add it to avoid spaces.
                        glyphRects.append(rect)
                    }
                }
            }
        }
        
        return glyphRects
    }
    
    /// Get CAShapeLayers with paths set a glyphs from a string.
    ///
    /// - Parameters:
    ///   - text: String to create layers from.
    ///   - color: Color of glyphs.
    /// - Returns:  An optional array of CAShapeLayers, one for each glyph to display.
    private func getGlyphLayers(text :String, color :UIColor) -> [CAShapeLayer]? {
        var glyphLayers :[CAShapeLayer] = [] //Array of glyph layers to return.
        
        guard let attributedString = getTextAttributes(text :text) else { //Create attributed string from label text.
            print("Attributed String is nil.")
            return nil
        }
        
        let linesInFrame = getLinesForAttributedString(attributedString: attributedString) //Get a frame of lines for the string as well as the lines themselves.
        
        for index in 0..<CFArrayGetCount(linesInFrame.lines) {
            let line = unsafeBitCast(CFArrayGetValueAtIndex(linesInFrame.lines, index), to: CTLine.self) //Line for index
            
            let runArray = CTLineGetGlyphRuns(line) //Get runs from the line.
            
            for index in 0..<CFArrayGetCount(runArray) {
                let run = unsafeBitCast(CFArrayGetValueAtIndex(runArray, index), to: CTRun.self) //Run for index in line.
                
                var glyphs = [CGGlyph](repeating: CGGlyph(), count: text.characters.count) //Allocated space for array of glyphs.
                
                CTRunGetGlyphs(run, CFRangeMake(0, 0), &glyphs) //Get array of glyphs in run.
                
                guard let font = CFAttributedStringGetAttribute(attributedString, 0, kCTFontAttributeName, nil) as! CTFont? else { //Get the font from the attributed string.
                    print("Font is nil.")
                    return nil
                }
                
                var glyphBoundingRects = [CGRect](repeating: CGRect(), count: text.characters.count) //Allocated space for array of bounding boxes of glyphs.
                CTFontGetBoundingRectsForGlyphs(font, .default, glyphs, &glyphBoundingRects, text.characters.count) //Get array of bounding boxes of glyphs in run.
                
                for glyphIndex in 0..<glyphs.count { //For each glyph in run.
                    let glyph = glyphs[glyphIndex] //Glyph for index.
                    
                    if let glyphPath = CTFontCreatePathForGlyph(font, glyph, nil) { //Creates a cgpath for glyph.
                        let glyphLayer = CAShapeLayer()
                        glyphLayer.path = glyphPath
                        
                        glyphLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                        glyphLayer.isGeometryFlipped = true //Glyph is normally displayed upside down.
                        glyphLayer.fillColor = color.cgColor
                        
                       // glyphLayer.backgroundColor = UIColor.blue.cgColor
                        
                        glyphLayer.bounds = glyphBoundingRects[glyphIndex]
                        
                        if Array(text.characters)[glyphIndex] != " " { //Avoid the spaces.
                            glyphLayers.append(glyphLayer)
                        }
                        
                    } else {
                        print("Glyph for index " + String(glyphIndex) + " is nil.")
                    }
                }
            }
        }
        
        return glyphLayers
    }
    
    /// Finds matching characters for two different strings and tracks their index.
    ///
    /// - Parameters:
    ///   - firstString: First string to compare.
    ///   - secondString: Second string to compare.
    ///   - matchingCharacterAction: Callback containing an index for first and second string when a match is found.
    ///   - nonMatchingSecondStringCharacterAction: Callback containing an index in the second string when a match is not found.
    ///   - nonMatchingFirstStringCharacterAction:  Callback containing an index in the first string when a match is not found.
    private func getMatchingCharacters(firstString: String, secondString: String, matchingCharacterAction :(_ firstStringIndex :Int, _ secondStringIndex :Int) -> Void, nonMatchingSecondStringCharacterAction :(Int) -> Void, nonMatchingFirstStringCharacterAction :(Int) -> Void) {
        var charactersFromFirstString = getCharacters(from: firstString) //Dictionary of characters and how many times they appear within the first string.
        
        for (i, character) in secondString.characters.enumerated() { //Look through each character of the second string to compare.
            if charactersFromFirstString[character] != nil { //If the character exists in the first string.
                var indexes = charactersFromFirstString[character] //Get a copy of the indexes where the character appears.
                if let firstStringIndex = indexes?.first { //Take the first index.
                    indexes?.remove(at: 0) //Remove it from the character indexes.
                    charactersFromFirstString[character] = indexes //And set the reference from the copy.
                    
                    let secondStringIndex = i //Index where the character appears in the second string.
                    
                    matchingCharacterAction(firstStringIndex, secondStringIndex)
                } else { //If the character was found in the second string but does not have any remaining indexes.
                    nonMatchingSecondStringCharacterAction(i)
                }
            } else { //If the character was not found at all in the second string.
                nonMatchingSecondStringCharacterAction(i)
            }
        }
        
        for character in charactersFromFirstString { //For all the remaining character indexes in the first string that were not matched.
            for index in character.value {
                nonMatchingFirstStringCharacterAction(index)
            }
        }
    }
    
    /// Creates an attributed string matching the display of the UILabel for the render method to use to draw text paths.
    ///
    /// - Parameter text: The returned attributed strings text.
    /// - Returns: Attributed string matching the UILabel text.
    private func getTextAttributes(text :String) -> CFAttributedString? {
        let attributedString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0)
        
        //Text.
        CFAttributedStringReplaceString(attributedString, CFRangeMake(0, 0), text as CFString!)
        
        //Font.
        let runFont = CTFontCreateWithName(font.fontName as CFString?, font.pointSize, nil)
        CFAttributedStringSetAttribute(attributedString, CFRangeMake(0, CFAttributedStringGetLength(attributedString)), kCTFontAttributeName, runFont)

        //Paragraph style.
        var alignment = NSTextAlignmentToCTTextAlignment(textAlignment)
        let alignmentSetting = [CTParagraphStyleSetting(spec: .alignment, valueSize: MemoryLayout.size(ofValue: alignment), value: &alignment)]
        let paragraphStyle = CTParagraphStyleCreate(alignmentSetting, alignmentSetting.count)
        CFAttributedStringSetAttribute(attributedString, CFRangeMake(0, CFAttributedStringGetLength(attributedString)), kCTParagraphStyleAttributeName, paragraphStyle)
        
        //Kerning
        CFAttributedStringSetAttribute(attributedString, CFRangeMake(0, CFAttributedStringGetLength(attributedString)), kCTKernAttributeName, 0.25 as CFTypeRef!)
        
        return attributedString
    }
    
    /// Calculates the lines needed and overall frame for this label.
    ///
    /// - Parameter attributedString: Attributed string to create lines for.
    /// - Returns: An array of lines and the frame around them.
    private func getLinesForAttributedString(attributedString :CFAttributedString) -> (lines :CFArray, frame :CTFrame) {
        let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
        
        let textSuggestedHeight = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, CFAttributedStringGetLength(attributedString)), nil, CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), nil).height //Height required to render this text with attributes provided.
        
        let textFrame = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.width, height: textSuggestedHeight) //Frame to use for this string.
        
        let path = UIBezierPath(rect: textFrame).cgPath
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil) //Creates the frame.
        let lines = CTFrameGetLines(frame) //Gers the lines that fit within the frame.
        
        return (lines, frame)
    }
    
    /// Gets characters and how many times they appear from a string.
    ///
    /// - Parameter text: String to find characters.
    /// - Returns: Dicionary whose keys are each character in the string and value containing how many times the character appears.
    private func getCharacters(from text: String) -> [Character : [Int]] {
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
    
    //MARK: - CAAnimation Protocol
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        //text = tempString //Text in label is set to new string.
        //tempString = nil
    }
}
