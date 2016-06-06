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
    
    var goal :Float = 0
    
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
        
        gradientLayer.frame = CGRectMake(0, -bounds.height / 6, bounds.width, bounds.height + bounds.height / 6) //Gradient uses these weird magic numbers just because it looks better this way
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
        
        let margin :CGFloat = 20
        
        addConstraint(NSLayoutConstraint(item: drawingView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: margin))
        addConstraint(NSLayoutConstraint(item: drawingView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: margin))
        addConstraint(NSLayoutConstraint(item: drawingView, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: -margin))
        addConstraint(NSLayoutConstraint(item: drawingView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: -margin))
        

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
    
    /**
     Gets the goal value to display dotted goal line
     
     - returns: Goal of graph
     */
    func goalValue() -> Float {
        return goal
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
    func goalValue() -> Float
}

class WeekBarGraphDrawingView :UIView {
    /// Delegate to communicate with WeeklyBarGraphView
    var delegate :WeekBarGraphDrawingViewProtocol?
    
    /// How many values are allowed to go on the Y Axis. Will scale accordingly
    var numberOfValuesToFitOnYAxis = 5
    
    /// Color to draw labels and lines with
    private let drawingColor = UIColor(white: 1, alpha: 0.8)
    
    /// Bottom x and y intersection points. Basically how much of a margin each line hangs from the edge
    private var xyStartingPoint = CGPointMake(35, 15)
    
    /**
     Draws x and y axis for bar graph
     */
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        drawingColor.set() //Set the color of drawings to be the standard drawing color

        drawXAxis() //Draw the x axis
        drawYAxis() //Draw the y axis
        
        setupXAxisValues() //Set up values to go on the x axis
        setupYAxisValues() //Set up values to go on the y axis
        
        //drawGoalLine(startingXPoint, startingYPoint: startingYPoint)
    }
    
    
    /**
     Draws x axis on bottom of graph
     */
    private func drawXAxis() {
        let startPoint = CGPointMake(xyStartingPoint.x, bounds.height - xyStartingPoint.y) //Establish where to begin drawing X axis
        let endPoint = CGPointMake(bounds.width, bounds.height - xyStartingPoint.y) //Establish where to end drawing X axis
        
        let ctx = UIGraphicsGetCurrentContext()
        
        CGContextSetLineWidth(ctx, 1)
        
        CGContextMoveToPoint(ctx, startPoint.x, startPoint.y) //Move to start point
        CGContextAddLineToPoint(ctx, endPoint.x, endPoint.y) //Add end point
        
        CGContextStrokePath(ctx) //Draw X axis
    }
    
    /**
     Draws y axis on left side of graph
     */
    private func drawYAxis() {
        let startPoint = CGPointMake(xyStartingPoint.x, 0) //Establish where to begin drawing Y axis
        let endPoint = CGPointMake(xyStartingPoint.x, bounds.height - xyStartingPoint.y) //Establish where to end drawing Y axis
        
        let ctx = UIGraphicsGetCurrentContext()
        
        CGContextSetLineWidth(ctx, 1)
        
        CGContextMoveToPoint(ctx, startPoint.x, startPoint.y) //Move to start point
        CGContextAddLineToPoint(ctx, endPoint.x, endPoint.y) //Add end point
        
        CGContextStrokePath(ctx) //Draw X axis
    }
    
    /**
     Places x axis values horizontally on the bottom side of the x axis. Values come from the a set array with days of the week
     */
    private func setupXAxisValues() {
        
        let xAxisValues = ["Sun", "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat"] //Values to be places as label under x axis
        
        for i in 0 ... xAxisValues.count - 1 { //Goes through xAxisValues and places labels on screen
            let xLabel = UILabel() //Label to place
            
            xLabel.text = xAxisValues[i] //Get text from array
            
            //Label properties
            
            xLabel.font = StandardFonts.boldFont(12)
            xLabel.textAlignment = .Center
            xLabel.textColor = drawingColor
            
            //X Label positioning
            
            let sizeOfValue = xLabel.text!.sizeWithAttributes([NSFontAttributeName : xLabel.font]) //Gets size of text based on font and string
            
            let sizeOfXAxis = bounds.width - xyStartingPoint.x //Size of x axis line

            let xPosition : CGFloat = (xyStartingPoint.x + ((sizeOfXAxis / CGFloat(xAxisValues.count - 1)) * CGFloat(i))) - ((xyStartingPoint.x / CGFloat(xAxisValues.count - 1) * CGFloat(i))) //X position must ensure that the first and last item are both fully within the scope of the x axis. So the first item must have an x origin that is the same as the x line origin. And the last item must have a origin.x plus width that is equal to the line x origin plus the line width
            
            let yPosition = bounds.height - sizeOfValue.height //Y position is just the height of superview and subtracts the height of the label to meet with the x line
            
            
            let xLabelWidth :CGFloat = 30 //Width of xValue label
            
            xLabel.frame = CGRectMake(xPosition, yPosition, xLabelWidth, sizeOfValue.height) //Sets up frame and leaves the y value 0 so that we can center it
            
            addSubview(xLabel)
        }
        
        
    }
    
    /**
     Places y axis values vertically on the left side of the y axis. Values come from the yAxisRangeValues in the delegate
     */
    private func setupYAxisValues() {
        let labelWidth :CGFloat = 30 //Width of each number label

        for i in 0 ... numberOfValuesToFitOnYAxis { //Iterates through the number of values you want placed on y axis and then places them
            let numberLabel = UILabel() //Label to place
            numberLabel.text = "" //Initial text so that the label can be measured later. Will crash without something being set
            
            //Label properties
            
            numberLabel.font = StandardFonts.boldFont(12)
            numberLabel.textAlignment = .Right
            numberLabel.textColor = drawingColor
            
            let sizeOfYAxis = bounds.height - xyStartingPoint.y
            
            let xPosition :CGFloat = 0 //X Position to place label
            let yPosition = sizeOfYAxis - ((sizeOfYAxis / CGFloat(numberOfValuesToFitOnYAxis)) * CGFloat(i)) //Y position to place each label. First in goes at bottom. Last is on top. Later it will be set so this value is used for the labels y center
            
            //Number label positioning

            let sizeOfNumber = numberLabel.text!.sizeWithAttributes([NSFontAttributeName : numberLabel.font]) //Gets size of text based on font and string
            
            numberLabel.frame = CGRectMake(xPosition, 0, labelWidth, sizeOfNumber.height) //Sets up frame and leaves the y value 0 so that we can center it
            numberLabel.center = CGPointMake(numberLabel.center.x, yPosition) //Places the y value determined above as the center of the number label
            
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
    
    /**
     Draws dotted line to indicate where goal is, if any
     */
    private func drawGoalLine(startingXPoint :CGFloat, startingYPoint :CGFloat) {
        let goalValue = delegate?.goalValue()
        
        if goalValue != 0 {
            let endingXPoint = bounds.width - startingXPoint //Where the X axis stop drawing at the right
            
            let xLineWidth = endingXPoint - startingXPoint //Width of the x axis line
            
            let endingYPoint = bounds.height - startingYPoint //Where the y axis line is at the bottom
            
            let yLineHeight = endingYPoint - startingYPoint //Height of the y axis line
            
            let goalYValue = CGFloat(100)//(yLineHeight / CGFloat(goalValue!)) * yLineHeight
            
            let startPoint = CGPointMake(startingXPoint, goalYValue) //Establish where to begin drawing Y axis
            let endPoint = CGPointMake(xLineWidth, goalYValue) //Establish where to end drawing Y axis
            
            let ctx = UIGraphicsGetCurrentContext()
            
            CGContextSetLineWidth(ctx, 1)
            CGContextSetLineDash(ctx, 0, [5, 5], 2)
            CGContextMoveToPoint(ctx, startPoint.x, startPoint.y) //Move to start point
            CGContextAddLineToPoint(ctx, endPoint.x, endPoint.y) //Add end point
            
            CGContextStrokePath(ctx) //Draw X axis
        }
    }
}