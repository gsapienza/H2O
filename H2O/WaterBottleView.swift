//
//  WaterBottleView.swift
//  H2O
//
//  Created by Gregory Sapienza on 11/27/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

class WaterBottleView: UIView {
    
    /// White bottle used as background where it looks as if water is displayed in.
    private lazy var bottleLayer :CAShapeLayer = self.generateWaterBottleLayer(fillColor: UIColor.white)
    
    /// Mask layer of bottle to use for water view.
    private lazy var bottleMaskLayer :CAShapeLayer = self.generateWaterBottleLayer(fillColor: UIColor.white)
    
    /// Water view inside of bottle.
    private lazy var waterView :GSFluidView = self.generateLiquidView(color: StandardColors.waterColor)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = UIColor.clear
        
        //---Bottle Layer---//

        let bottleLayerPath = generateBottlePath(frame: bounds)
        bottleLayer.path = bottleLayerPath.cgPath
        
        //---Bottle Mask---//
        
        let bottleMaskWidth = bounds.width * 0.92 //Width for bottle mask is defined as a smaller value than that of the bottleLayer so that the bottleLayer shows in the back as a sort of border 0.92 is used because it looked best to me.
        let bottleMaskWidthDifference = bounds.width - bottleMaskWidth //Difference in width between the main bottle and that of the bottle layer mask.
        let bottleMaskFrame = CGRect(x: bounds.width / 2 - bottleMaskWidth / 2, y: 0, width: bottleMaskWidth, height: bounds.height - bottleMaskWidthDifference / 2) //Final frame for the bottle mask. X value places the mask in the middle of the bottle layer and the height takes the half the width difference and subtracts it from the height to show the same amount of distance from the bottleLayer vertically as horizontally.
        
        let bottleMaskPath = generateBottlePath(frame: bottleMaskFrame)
        bottleMaskLayer.path = bottleMaskPath.cgPath
        
        //---Water View---//

        waterView.frame = bounds
        waterView.fluidLayout = GSFluidLayout(frame: frame, fluidWidth: bounds.width * 2.5, fillDuration: 3, amplitudeIncrement: 1, maxAmplitude: 8, minAmplitude: 2, numberOfWaves: 2)
        waterView.layer.mask = bottleMaskLayer
        
        var fillValue :Float = 0.4
        waterView.fillTo(&fillValue)
    }
    
    private func addSubviews() {
        layer.addSublayer(bottleLayer)
        addSubview(waterView)
    }
}

// MARK: - Private Generators
private extension WaterBottleView {
    
    /// Generates a view for liquid.
    ///
    /// - Parameter color: Color of liquid.
    /// - Returns: Liquid view with a fill value of 0.
    func generateLiquidView(color :UIColor) -> GSFluidView {
        let liquidView = GSFluidView()
        liquidView.liquidFillColor = color
        liquidView.clipsToBounds = true
        
        return liquidView
    }
    
    /// Generates a water bottle layer.
    ///
    /// - Parameters:
    ///   - fillColor: Color of the bottle.
    /// - Returns: Water bottle layer.
    func generateWaterBottleLayer(fillColor :UIColor) -> CAShapeLayer {
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = fillColor.cgColor
        
        return shapeLayer
    }
    
    /// Generates a water bottle path.
    ///
    /// - Parameters:
    ///   - frame: Frame where path will be contained.
    /// - Returns: Water bottle shaped bezier path.
    func generateBottlePath(frame :CGRect) -> UIBezierPath {
        //// WaterBottleLayer
        //// Bottle Drawing
        let bottlePath = UIBezierPath()
        bottlePath.move(to: CGPoint(x: frame.minX + 0.07268 * frame.width, y: frame.minY + 0.99810 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.02234 * frame.width, y: frame.minY + 0.97996 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.05682 * frame.width, y: frame.minY + 0.99592 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.03119 * frame.width, y: frame.minY + 0.98674 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.01532 * frame.width, y: frame.minY + 0.87640 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.01654 * frame.width, y: frame.minY + 0.97548 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.01624 * frame.width, y: frame.minY + 0.97215 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.01471 * frame.width, y: frame.minY + 0.77731 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.02570 * frame.width, y: frame.minY + 0.76870 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.03119 * frame.width, y: frame.minY + 0.74482 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.03821 * frame.width, y: frame.minY + 0.75894 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.04004 * frame.width, y: frame.minY + 0.75113 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.01471 * frame.width, y: frame.minY + 0.71072 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.01380 * frame.width, y: frame.minY + 0.73242 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.01471 * frame.width, y: frame.minY + 0.73402 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.01471 * frame.width, y: frame.minY + 0.68879 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.02570 * frame.width, y: frame.minY + 0.68086 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.02570 * frame.width, y: frame.minY + 0.65342 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.04034 * frame.width, y: frame.minY + 0.67007 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.04065 * frame.width, y: frame.minY + 0.66410 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.01471 * frame.width, y: frame.minY + 0.64539 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.01471 * frame.width, y: frame.minY + 0.62288 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.01471 * frame.width, y: frame.minY + 0.60038 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.02570 * frame.width, y: frame.minY + 0.59268 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.03210 * frame.width, y: frame.minY + 0.56984 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.03760 * frame.width, y: frame.minY + 0.58384 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.04004 * frame.width, y: frame.minY + 0.57546 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.02112 * frame.width, y: frame.minY + 0.56203 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.02966 * frame.width, y: frame.minY + 0.56811 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.02478 * frame.width, y: frame.minY + 0.56455 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.01471 * frame.width, y: frame.minY + 0.53516 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.01532 * frame.width, y: frame.minY + 0.55790 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.01471 * frame.width, y: frame.minY + 0.55571 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.01471 * frame.width, y: frame.minY + 0.51277 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.02570 * frame.width, y: frame.minY + 0.50451 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.02570 * frame.width, y: frame.minY + 0.47729 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.04065 * frame.width, y: frame.minY + 0.49314 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.04034 * frame.width, y: frame.minY + 0.48728 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.01471 * frame.width, y: frame.minY + 0.46995 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.01471 * frame.width, y: frame.minY + 0.44733 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.01471 * frame.width, y: frame.minY + 0.42482 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.02570 * frame.width, y: frame.minY + 0.41621 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.02570 * frame.width, y: frame.minY + 0.38923 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.04034 * frame.width, y: frame.minY + 0.40484 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.04034 * frame.width, y: frame.minY + 0.39979 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.01471 * frame.width, y: frame.minY + 0.38131 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.01471 * frame.width, y: frame.minY + 0.33102 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.02082 * frame.width, y: frame.minY + 0.27235 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.01471 * frame.width, y: frame.minY + 0.28394 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.01502 * frame.width, y: frame.minY + 0.28015 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.16451 * frame.width, y: frame.minY + 0.19611 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.03638 * frame.width, y: frame.minY + 0.25110 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.06871 * frame.width, y: frame.minY + 0.23388 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.28258 * frame.width, y: frame.minY + 0.14214 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.23895 * frame.width, y: frame.minY + 0.16660 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.26214 * frame.width, y: frame.minY + 0.15604 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.30149 * frame.width, y: frame.minY + 0.11631 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.29356 * frame.width, y: frame.minY + 0.13480 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.30149 * frame.width, y: frame.minY + 0.12400 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.30149 * frame.width, y: frame.minY + 0.10908 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.28502 * frame.width, y: frame.minY + 0.10908 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.25268 * frame.width, y: frame.minY + 0.09989 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.26305 * frame.width, y: frame.minY + 0.10908 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.25268 * frame.width, y: frame.minY + 0.10609 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.26153 * frame.width, y: frame.minY + 0.09266 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.25268 * frame.width, y: frame.minY + 0.09645 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.25451 * frame.width, y: frame.minY + 0.09495 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.27159 * frame.width, y: frame.minY + 0.08370 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.26915 * frame.width, y: frame.minY + 0.09025 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.27068 * frame.width, y: frame.minY + 0.08887 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.27251 * frame.width, y: frame.minY + 0.07750 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.49980 * frame.width, y: frame.minY + 0.07750 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.72708 * frame.width, y: frame.minY + 0.07750 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.72800 * frame.width, y: frame.minY + 0.08416 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.73197 * frame.width, y: frame.minY + 0.09071 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.72861 * frame.width, y: frame.minY + 0.08772 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.73013 * frame.width, y: frame.minY + 0.09071 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.74234 * frame.width, y: frame.minY + 0.09358 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.73349 * frame.width, y: frame.minY + 0.09071 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.73837 * frame.width, y: frame.minY + 0.09197 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.71610 * frame.width, y: frame.minY + 0.10908 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.76003 * frame.width, y: frame.minY + 0.10012 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.74478 * frame.width, y: frame.minY + 0.10908 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.70115 * frame.width, y: frame.minY + 0.10908 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.70115 * frame.width, y: frame.minY + 0.11631 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.71946 * frame.width, y: frame.minY + 0.14180 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.70115 * frame.width, y: frame.minY + 0.12389 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.70908 * frame.width, y: frame.minY + 0.13480 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.83081 * frame.width, y: frame.minY + 0.19301 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.74020 * frame.width, y: frame.minY + 0.15581 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.75820 * frame.width, y: frame.minY + 0.16407 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.96596 * frame.width, y: frame.minY + 0.25685 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.91654 * frame.width, y: frame.minY + 0.22722 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.94308 * frame.width, y: frame.minY + 0.23974 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.98793 * frame.width, y: frame.minY + 0.33102 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.98732 * frame.width, y: frame.minY + 0.27258 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.98793 * frame.width, y: frame.minY + 0.27510 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.98793 * frame.width, y: frame.minY + 0.38131 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.97695 * frame.width, y: frame.minY + 0.38923 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.97695 * frame.width, y: frame.minY + 0.41621 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.96230 * frame.width, y: frame.minY + 0.39979 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.96230 * frame.width, y: frame.minY + 0.40484 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.98793 * frame.width, y: frame.minY + 0.42482 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.98793 * frame.width, y: frame.minY + 0.44733 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.98793 * frame.width, y: frame.minY + 0.46995 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.97725 * frame.width, y: frame.minY + 0.47718 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.97756 * frame.width, y: frame.minY + 0.50485 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.96261 * frame.width, y: frame.minY + 0.48705 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.96261 * frame.width, y: frame.minY + 0.49348 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.98824 * frame.width, y: frame.minY + 0.51312 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.98732 * frame.width, y: frame.minY + 0.53654 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.98640 * frame.width, y: frame.minY + 0.55996 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.97725 * frame.width, y: frame.minY + 0.56501 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.96718 * frame.width, y: frame.minY + 0.57730 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.97054 * frame.width, y: frame.minY + 0.56892 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.96810 * frame.width, y: frame.minY + 0.57167 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.97695 * frame.width, y: frame.minY + 0.59246 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.96596 * frame.width, y: frame.minY + 0.58384 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.96688 * frame.width, y: frame.minY + 0.58534 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.98793 * frame.width, y: frame.minY + 0.60038 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.98793 * frame.width, y: frame.minY + 0.62288 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.98793 * frame.width, y: frame.minY + 0.64539 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.97725 * frame.width, y: frame.minY + 0.65319 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.97725 * frame.width, y: frame.minY + 0.68086 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.96261 * frame.width, y: frame.minY + 0.66376 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.96261 * frame.width, y: frame.minY + 0.66996 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.98793 * frame.width, y: frame.minY + 0.68890 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.98793 * frame.width, y: frame.minY + 0.71072 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.97146 * frame.width, y: frame.minY + 0.74459 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.98793 * frame.width, y: frame.minY + 0.73391 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.98824 * frame.width, y: frame.minY + 0.73299 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.97725 * frame.width, y: frame.minY + 0.76904 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.96291 * frame.width, y: frame.minY + 0.75056 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.96505 * frame.width, y: frame.minY + 0.75951 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.98793 * frame.width, y: frame.minY + 0.77731 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.98732 * frame.width, y: frame.minY + 0.87640 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.95895 * frame.width, y: frame.minY + 0.99041 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.98640 * frame.width, y: frame.minY + 0.98903 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.98885 * frame.width, y: frame.minY + 0.97916 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.50010 * frame.width, y: frame.minY + 0.99994 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.93118 * frame.width, y: frame.minY + 1.00086 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.96993 * frame.width, y: frame.minY + 1.00006 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.07268 * frame.width, y: frame.minY + 0.99810 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.13126 * frame.width, y: frame.minY + 0.99994 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.08488 * frame.width, y: frame.minY + 0.99971 * frame.height))
        bottlePath.close()
        bottlePath.move(to: CGPoint(x: frame.minX + 0.27312 * frame.width, y: frame.minY + 0.07038 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.27098 * frame.width, y: frame.minY + 0.04202 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.27190 * frame.width, y: frame.minY + 0.07004 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.27098 * frame.width, y: frame.minY + 0.05718 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.29295 * frame.width, y: frame.minY + 0.00230 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.27098 * frame.width, y: frame.minY + 0.01079 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.27342 * frame.width, y: frame.minY + 0.00677 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.50010 * frame.width, y: frame.minY + 0.00000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.30271 * frame.width, y: frame.minY + 0.00011 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.30790 * frame.width, y: frame.minY + 0.00000 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.69719 * frame.width, y: frame.minY + 0.00000 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.70756 * frame.width, y: frame.minY + 0.00264 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.72800 * frame.width, y: frame.minY + 0.04191 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.72769 * frame.width, y: frame.minY + 0.00769 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.72861 * frame.width, y: frame.minY + 0.00976 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.72708 * frame.width, y: frame.minY + 0.07061 * frame.height))
        bottlePath.addLine(to: CGPoint(x: frame.minX + 0.50102 * frame.width, y: frame.minY + 0.07096 * frame.height))
        bottlePath.addCurve(to: CGPoint(x: frame.minX + 0.27312 * frame.width, y: frame.minY + 0.07038 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.37685 * frame.width, y: frame.minY + 0.07107 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.27404 * frame.width, y: frame.minY + 0.07084 * frame.height))
        
        return bottlePath
    }
}
