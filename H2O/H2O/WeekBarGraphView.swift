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
        
        gradientLayer.frame = bounds
        gradientLayer.locations = [0, 0.5]
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
    
    /**
     Draws x and y axis for bar graph
     */
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let startingXPoint = bounds.width / 8 //Right side beginning of line for X Axis
        let startingYPoint = bounds.height / 1.2 //Bottom side beginning of line for Y Axis
        
        drawingColor.set() //Set the color of drawings to be the standard drawing color

        drawXAxis(startingXPoint, startingYPoint: startingYPoint) //Draw the x axis
        drawYAxis(startingXPoint, startingYPoint: startingYPoint) //Draw the y axis
    }
    
    /**
     Draws x axis on bottom of graph
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
     Set up values for x and y axis
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        setupYAxisValues()
    }
    
    /**
     Places y axis values vertically on the left side of the y axis. Values come from the yAxisRangeValues in the delegate
     */
    private func setupYAxisValues() {
        let startingXPoint = bounds.width / 8 //Right side beginning of line for X Axis
        let startingYPoint = bounds.height / 1.2 //Bottom side beginning of line for Y Axis
        
        let endingYPoint = bounds.height - startingYPoint //Where the y axis stop drawing
        
        let marginBetweenValues :CGFloat = 40 //Spacing between numbers vertically
        
        let numberOfYValues :CGFloat = (startingYPoint - endingYPoint) / marginBetweenValues //Number of values that can fit on y axis accounting for spacing
        
        for i in 0 ... Int(numberOfYValues) { //Iterate through all the possible spaces that can fit on graph
            let labelSize :CGFloat = 40 //Width and height of number label
            let xMargin :CGFloat = 10 //Margin of label from right to the y axis
            let xPosition = startingXPoint - labelSize - xMargin //X Position to place label
            let yPosition = ((startingYPoint - endingYPoint) / numberOfYValues) * CGFloat(i) //Y position to place label
            
            let numberLabel = UILabel() //Label to place
            
            //Label properties
            numberLabel.font = StandardFonts.boldFont(12)
            numberLabel.textAlignment = .Right
            numberLabel.text = String((delegate?.yAxisRangeValues().end)! / Double(i))
            numberLabel.textColor = UIColor.whiteColor()
            
            numberLabel.frame = CGRectMake(xPosition, yPosition, labelSize, labelSize)
            
            addSubview(numberLabel)
        }
    }
}