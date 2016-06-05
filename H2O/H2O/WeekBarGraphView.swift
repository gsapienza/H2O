//
//  WeekBarGraphView.swift
//  H2O
//
//  Created by Gregory Sapienza on 6/1/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

class WeekBarGraphView: UIView {
    /// Colors to use in the gradient background
    var gradientColors = NSMutableArray()
    
    /// Range of values to draw on the yAxis. Start is drawn starting at the bottom while the end is at the top
    var yAxisRange = (start: 0.0, end: 10.0)
    
    /// Drawing view to place on top of gradient view
    private let drawingView = WeekBarGraphDrawingView()
    
    /**
     Basic setup for view
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        
        clipsToBounds = true
        layer.cornerRadius = 10
        layer.backgroundColor = UIColor.blueColor().CGColor
        
        //View setup
        setupGradientLayer()
        setupDrawingView()
    }
    
    /**
     Places background gradient layer on top of view to create a gradient effect. Gradient colors must be set by view controller
     */
    private func setupGradientLayer() {
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = CGRectMake(0, -bounds.height / 6, bounds.width, bounds.height + bounds.height / 6)
        gradientLayer.locations = [0, 0.9]
        gradientLayer.colors = gradientColors as [AnyObject]
        layer.addSublayer(gradientLayer)
    }
    
    /**
     Sets up new view where all drawing will take place for graphs and labels
     */
    private func setupDrawingView() {
        addSubview(drawingView)
        
        drawingView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: drawingView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: drawingView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: drawingView, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: drawingView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0))
        

        drawingView.delegate = self
        drawingView.backgroundColor = UIColor.clearColor() //So the gradient background shows
    }
}

// MARK: - WeekBarGraphDrawingViewProtocol
extension WeekBarGraphView :WeekBarGraphDrawingViewProtocol {
    /**
     Get the yAxisRangeFromGraph
     
     - returns: Starting and ending ranges to draw on y axis of graph
     */
    func yAxisRangeValues() -> (start :Double, end :Double) {
        return yAxisRange
    }
}

/**
 *  Protocol to communicate with WeekBarGraphView
 */
protocol WeekBarGraphDrawingViewProtocol {
    /**
     Get the yAxisRangeFromGraph
     
     - returns: Starting and ending ranges to draw on y axis of graph
     */
    func yAxisRangeValues() -> (start :Double, end :Double)
}

class WeekBarGraphDrawingView :UIView {
    
    /// Color to draw labels and lines with
    private let drawingColor = UIColor.whiteColor()
    
    /// Delegate to communicate with WeeklyBarGraphView
    var delegate :WeekBarGraphDrawingViewProtocol?
    
    let numberOfValuesToFitOnYAxis = 5
    
    /**
     Draws x and y axis for bar graph
     */
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let startingXPoint = bounds.width / 8 //Left side beginning of line for X Axis
        let startingYPoint = bounds.height / 1.2 //Bottom side beginning of line for Y Axis for Core graphics or Top side beginning of line for Y Axis for normal UIKit 
        
        drawingColor.set() //Set the color of drawings to be the standard drawing color

        drawXAxis(startingXPoint, startingYPoint: startingYPoint) //Draw the x axis
        drawYAxis(startingXPoint, startingYPoint: startingYPoint) //Draw the y axis
        
        setupYAxisValues(startingXPoint, startingYPoint: startingYPoint) //Set up values to go on the y axis
    }
    
    
    /**
     Draws x axis on bottom of graph
     
     - parameter startingXPoint: Where the x axis should begin drawing horizontally
     - parameter startingYPoint: Where the x axis should place its Y value
     */
    private func drawXAxis(startingXPoint :CGFloat, startingYPoint :CGFloat) {
        
        let startPoint = CGPointMake(startingXPoint, startingYPoint) //Establish where to begin drawing X axis
        let endPoint = CGPointMake(bounds.width - startingXPoint, startingYPoint) //Establish where to end drawing X axis
        
        let ctx = UIGraphicsGetCurrentContext()
        
        CGContextSetLineWidth(ctx, 1)
        
        CGContextMoveToPoint(ctx, startPoint.x, startPoint.y) //Move to start point
        CGContextAddLineToPoint(ctx, endPoint.x, endPoint.y) //Add end point
        
        CGContextStrokePath(ctx) //Draw X axis
    }
    
    /**
     Draws y axis on left side of graph
     
     - parameter startingXPoint: Where the y axis should begin drawing vertically
     - parameter startingYPoint: Where the y axis should place its Y value before drawing up
     */
    private func drawYAxis(startingXPoint :CGFloat, startingYPoint :CGFloat) {
        let startPoint = CGPointMake(startingXPoint, startingYPoint) //Establish where to begin drawing Y axis
        let endPoint = CGPointMake(startingXPoint, bounds.height - startingYPoint) //Establish where to end drawing Y axis
        
        let ctx = UIGraphicsGetCurrentContext()
        
        CGContextSetLineWidth(ctx, 1)
        
        CGContextMoveToPoint(ctx, startPoint.x, startPoint.y) //Move to start point
        CGContextAddLineToPoint(ctx, endPoint.x, endPoint.y) //Add end point
        
        CGContextStrokePath(ctx) //Draw X axis
    }
    
    /**
     Places y axis values vertically on the left side of the y axis. Values come from the yAxisRangeValues in the delegate
     
     - parameter startingXPoint: Where the y axis is placed on the x axis
     - parameter startingYPoint: Where the y axis is placed on the y axis
     */
    private func setupYAxisValues(startingXPoint :CGFloat, startingYPoint :CGFloat) {
        let labelWidth :CGFloat = 40 //Width of each number label

        let endingYPoint = bounds.height - startingYPoint //Where the y axis stop drawing at the bottom
        
        let yLineHeight = endingYPoint - startingYPoint //Height of the y axis line
        
        for i in 0 ... numberOfValuesToFitOnYAxis { //Iterates through the number of values you want placed on y axis and then places them
            let numberLabel = UILabel() //Label to place
            numberLabel.text = "" //Initial text so that the label can be measured later. Will crash without something being set
            
            let xMargin :CGFloat = 5 //Margin of label from right to the y axis
            
            let xPosition = startingXPoint - labelWidth - xMargin //X Position to place label
            let yPosition = startingYPoint + ((yLineHeight / CGFloat(numberOfValuesToFitOnYAxis)) * CGFloat(i)) //Y position to place label
            
            //Number label positioning

            let sizeOfNumber = numberLabel.text!.sizeWithAttributes([NSFontAttributeName : numberLabel.font]) //Gets size of text based on font and string
            
            numberLabel.frame = CGRectMake(xPosition, 0, labelWidth, sizeOfNumber.height) //Sets up frame and leaves the y value 0 so that we can center it
            numberLabel.center = CGPointMake(numberLabel.center.x, yPosition) //Places the y value determined above as the center of the number label
            
            //Label properties
            
            numberLabel.font = StandardFonts.boldFont(12)
            numberLabel.textAlignment = .Right
            numberLabel.textColor = drawingColor
            
            //Set the label value
            
            let yAxisRangeValues = (delegate?.yAxisRangeValues())! //Range values set for the y axis

            let numberRange = yAxisRangeValues.end - yAxisRangeValues.start //Computes the value between the start and end of Y axis values
            
            let number = yAxisRangeValues.start + ((numberRange / Double(numberOfValuesToFitOnYAxis)) * Double(i)) //Number calculated that fits between the yaxisrange values from the delegate
            
            var roundedNumberText = NSString(format: "%.1f", number) //Round to the first decimal point
            
            if roundedNumberText.hasSuffix(".0") { //If the number has a .0 after the decimal point, just cut it
                roundedNumberText = roundedNumberText.substringToIndex(roundedNumberText.length - 2) //Remove the .0
            }
            
            numberLabel.text = roundedNumberText as String + Constants.standardUnit.rawValue //Number with unit trailing
            
            
            addSubview(numberLabel)
        }
    }
}