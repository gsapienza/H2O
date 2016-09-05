//
//  WeekBarGraphView.swift
//  H2O
//
//  Created by Gregory Sapienza on 6/1/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

//MARK: - WeekValues Struct
struct WeekValues {
    var sunday :CGFloat
    var monday :CGFloat
    var tuesday :CGFloat
    var wednesday :CGFloat
    var thursday :CGFloat
    var friday :CGFloat
    var saturday :CGFloat
    
    /// Get a day of the week from using a raw value
    ///
    /// - parameter index: Index of day of the week
    ///
    /// - returns: Day of the week value
    func valueForIndex(index :Int) -> CGFloat {
        switch index {
        case 0: return sunday
        case 1: return monday
        case 2: return tuesday
        case 3: return wednesday
        case 4: return thursday
        case 5: return friday
        case 6: return saturday
        default: return 0
        }
    }
}

protocol WeekBarGraphViewProtocol {
    ///Goal to show as dotted line in graph. Keep at zero if you don't want it to appear.
    func weekBarGraphViewGoal() -> Float
    
    /// Values represented by the bars in graph
    func weekBarGraphViewWeekValues() -> WeekValues
}

//MARK: - WeekBarGraphView Class
class WeekBarGraphView: UIView {
    //MARK: - Public iVars
    
    /// Colors to use in the gradient background
    var gradientColors = NSMutableArray()
    
    /// Range of values to use on the yAxis. Start is drawn starting at the bottom while the end is at the top
    var yAxisRange = (start: 0.0, end: 10.0)
    
    var delegate :WeekBarGraphViewProtocol?
    
    //MARK: - Private iVars
    
    ///Gradient layer to use as background
    private var gradientLayer :CAGradientLayer!
    
    /// Drawing view to place on top of gradient view
    private var drawingView :WeekBarGraphDrawingView!
    
    //MARK: - View Setup

    override func layoutSubviews() {
        super.layoutSubviews()
        
        clipsToBounds = true
        layer.cornerRadius = 10
        layer.backgroundColor = UIColor.blue.cgColor
        
        gradientLayer = generateGradientLayer()
        drawingView = generateDrawingView()
        
        layout()
    }
    
    ///View placement
    private func layout() {
        //---Gradient Background---
        
        gradientLayer.frame = CGRect(x: 0, y: -10, width: bounds.width, height: bounds.height + 10) //Gradient needs to be fixed for ios 10 so its set up weird
        
        layer.addSublayer(gradientLayer)
        
        //---Drawing View---
        addSubview(drawingView)
        
        drawingView.translatesAutoresizingMaskIntoConstraints = false
        
        let margin :CGFloat = 20 //Margins on all sides of graph drawing view
        
        addConstraint(NSLayoutConstraint(item: drawingView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: margin))
        addConstraint(NSLayoutConstraint(item: drawingView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: margin))
        addConstraint(NSLayoutConstraint(item: drawingView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -margin))
        addConstraint(NSLayoutConstraint(item: drawingView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -margin))
    }
    
    //MARK: - Public
    func refreshBarGraph() {
        drawingView.setNeedsDisplay()
    }
}

//MARK: - Private Generators
internal extension WeekBarGraphView {
    
    /// Generates a layer that displays a customizable gradient
    ///
    /// - returns: A Gradient layer
    func generateGradientLayer() -> CAGradientLayer {
        let layer = CAGradientLayer()
        
        layer.locations = [0, 0]
        layer.colors = gradientColors as [AnyObject]
        
        return layer
    }
    
    
    /// Generates new view where all drawing will take place for graphs and labels

    ///
    /// - returns: The contents of the bar graph
    func generateDrawingView() -> WeekBarGraphDrawingView {
        let view = WeekBarGraphDrawingView()
        
        view.delegate = self
        view.backgroundColor = UIColor.clear //So the gradient background shows
        
        return view
    }
}

// MARK: - WeekBarGraphDrawingViewProtocol
extension WeekBarGraphView :WeekBarGraphDrawingViewProtocol {
    func getYAxisRangeValues() -> (start :Double, end :Double) {
        return yAxisRange
    }
    
    func getGoalValue() -> Float {
        return (delegate?.weekBarGraphViewGoal())!
    }
    
    func getWeekValues() -> WeekValues {
        return (delegate?.weekBarGraphViewWeekValues())!
    }
}

//MARK: - WeekBarGraphDrawingView Class

/// Protocol to communicate with WeekBarGraphView
protocol WeekBarGraphDrawingViewProtocol {
    /// Get the yAxisRangeFromGraph
    ///
    /// - returns: Starting and ending ranges to draw on y axis of graph
    func getYAxisRangeValues() -> (start :Double, end :Double)
    
    
    /// Gets the goal value to display dotted goal line
    ///
    /// - returns: Goal to reach
    func getGoalValue() -> Float
    
    /// Get the day values to be represented in graph
    ///
    /// - returns: Value for each day of the week
    func getWeekValues() -> WeekValues
}

class WeekBarGraphDrawingView :UIView {
    //MARK: - Public iVars
    
    /// Delegate to communicate with WeeklyBarGraphView
    var delegate :WeekBarGraphDrawingViewProtocol?
    
    /// How many values are allowed to go on the Y Axis. Will scale accordingly
    var numberOfValuesToFitOnYAxis = 5
    
    //MARK: - Private iVars
    
    /// Color to draw labels and lines with
    private let drawingColor = UIColor(white: 1, alpha: 0.8)
    
    /// Bottom x and y intersection points. The leftmost X coordinate and Bottom most Y coordinate
    private var xyStartingPoint = CGPoint(x: 45, y: 15)
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        drawingColor.set() //Set the color of drawings to be the standard drawing color

        drawXAxis() //Draw the x axis
        drawYAxis() //Draw the y axis
        
        setupXAxisValues() //Set up values to go on the x axis
        setupYAxisValues() //Set up values to go on the y axis
        
        drawGoalLine()
    }
    
    //MARK: - Axis Line Drawings
    
    ///Draws x axis on bottom of graph
    private func drawXAxis() {
        let startPoint = CGPoint(x: xyStartingPoint.x, y: bounds.height - xyStartingPoint.y) //Establish where to begin drawing X axis
        let endPoint = CGPoint(x: bounds.width, y: bounds.height - xyStartingPoint.y) //Establish where to end drawing X axis
        
        let ctx = UIGraphicsGetCurrentContext()
        
        ctx?.setLineWidth(1)
        
        ctx?.move(to: startPoint) //Move to start point
        ctx?.addLine(to: endPoint) //Add end point
        
        ctx?.strokePath() //Draw X axis
    }
    
    ///Draws y axis on left side of graph
    private func drawYAxis() {
        let startPoint = CGPoint(x: xyStartingPoint.x, y: 0) //Establish where to begin drawing Y axis
        let endPoint = CGPoint(x: xyStartingPoint.x, y: bounds.height - xyStartingPoint.y) //Establish where to end drawing Y axis
        
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setLineWidth(1)
        ctx?.move(to: startPoint)  //Move to start point
        ctx?.addLine(to: endPoint) //Add end point
        ctx?.strokePath() //Draw Y axis
    }
    
    //MARK: - Axis Values Placement
    
    ///Places x axis values horizontally on the bottom side of the x axis. Values come from the a set array with days of the week
    private func setupXAxisValues() {
        
        let xAxisValues = ["Sun", "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat"] //Values to be places as label under x axis
        
        for i in 0 ... xAxisValues.count - 1 { //Goes through xAxisValues and places labels on screen
            let xLabel = UILabel() //Label to place
            
            xLabel.text = xAxisValues[i] //Get text from array
            
            //Label properties
            
            xLabel.font = StandardFonts.boldFont(size: 12)
            xLabel.textAlignment = .center
            xLabel.textColor = drawingColor
            
            //X Label positioning
            
            let sizeOfValue = xLabel.text!.size(attributes: [NSFontAttributeName : xLabel.font]) //Gets size of text based on font and string
            
            let sizeOfXAxis = bounds.width - xyStartingPoint.x //Size of x axis line

            let xPosition : CGFloat = (xyStartingPoint.x + ((sizeOfXAxis / CGFloat(xAxisValues.count - 1)) * CGFloat(i))) - ((xyStartingPoint.x / CGFloat(xAxisValues.count - 1) * CGFloat(i))) //X position must ensure that the first and last item are both fully within the scope of the x axis. So the first item must have an x origin that is the same as the x line origin. And the last item must have a origin.x plus width that is equal to the line x origin plus the line width
            
            let yPosition = bounds.height - sizeOfValue.height //Y position is just the height of superview and subtracts the height of the label to meet with the x line
            
            let xLabelWidth :CGFloat = 40 //Width of xValue label
            
            xLabel.frame = CGRect(x: xPosition, y: yPosition, width: xLabelWidth, height: sizeOfValue.height) //Sets up frame and leaves the y value 0 so that we can center it
            
            addSubview(xLabel)
            
            let value = delegate?.getWeekValues().valueForIndex(index: i)
            
            addBarForDayOfWeek(xPosition: xPosition + xLabelWidth / 2, value: value!) //Add the bar for the day of the week label being positioned
        }
    }
    
    ///Places y axis values vertically on the left side of the y axis. Values come from the yAxisRangeValues in the delegate
    private func setupYAxisValues() {
        let labelWidth :CGFloat = 40 //Width of each number label
        
        for i in 0 ... numberOfValuesToFitOnYAxis { //Iterates through the number of values you want placed on y axis and then places them
            let numberLabel = UILabel() //Label to place
            numberLabel.text = "" //Initial text so that the label can be measured later. Will crash without something being set
            
            //Label properties
            
            numberLabel.font = StandardFonts.boldFont(size: 12)
            numberLabel.textAlignment = .right
            numberLabel.textColor = drawingColor
            
            let sizeOfYAxis = bounds.height - xyStartingPoint.y
            
            let xPosition :CGFloat = 0 //X Position to place label
            let yPosition = sizeOfYAxis - ((sizeOfYAxis / CGFloat(numberOfValuesToFitOnYAxis)) * CGFloat(i)) //Y position to place each label. First in goes at bottom. Last is on top. Later it will be set so this value is used for the labels y center
            
            //Number label positioning
            
            let sizeOfNumber = numberLabel.text!.size(attributes: [NSFontAttributeName : numberLabel.font]) //Gets size of text based on font and string
            
            numberLabel.frame = CGRect(x: xPosition, y: 0, width: labelWidth, height: sizeOfNumber.height) //Sets up frame and leaves the y value 0 so that we can center it
            numberLabel.center = CGPoint(x: numberLabel.center.x, y: yPosition) //Places the y value determined above as the center of the number label
            //Set the label value
            
            let yAxisRangeValues = (delegate?.getYAxisRangeValues())! //Range values set for the y axis
            
            let numberRange = yAxisRangeValues.end - yAxisRangeValues.start //Computes the value between the start and end of Y axis values
            
            let number = yAxisRangeValues.start + ((numberRange / Double(numberOfValuesToFitOnYAxis)) * Double(i)) //Number calculated that fits between the yaxisrange values from the delegate
            
            var roundedNumberText = NSString(format: "%.1f", number) //Round to the first decimal point
            
            if roundedNumberText.hasSuffix(".0") { //If the number has a .0 after the decimal point, just cut it
                roundedNumberText = (roundedNumberText.substring(to: roundedNumberText.length - 2) as NSString) //Remove the .0
            }
            
            numberLabel.text = roundedNumberText as String + standardUnit.rawValue //Number with unit trailing
            
            
            addSubview(numberLabel)
        }
    }
    
    //MARK: - Graph Values
    
    /// Adds a bar in the bar graph for a day of the week
    ///
    /// - parameter xPosition: Position where the day of the weeks rests on the x axis
    /// - parameter value:     Value representing that day of the week
    private func addBarForDayOfWeek(xPosition :CGFloat, value :CGFloat) {
        let lineCapGuessedHeight :CGFloat = 10 //This is the height of the line cap which I guessed and checked
        let bottomMargin :CGFloat = 8 //Margin between the bottom of the bar and the x axis for aesthetic effect

        let yLineHeight = bounds.height - xyStartingPoint.y - lineCapGuessedHeight - bottomMargin //Height of the y axis line taking into account the margin between the bottom of the bar and the x axis and the rounded line cap which adds some height
        
        let highestValueOnYAxis = CGFloat((delegate?.getYAxisRangeValues().end)!) //The top y label value
        let barStartingYValue = yLineHeight - ((yLineHeight / highestValueOnYAxis) * value) + lineCapGuessedHeight + bottomMargin //The y location where to place the top of the bar taking into account the margin between the bottom of the bar and the x axis and the rounded line cap which adds some height
        
        var startPoint = CGPoint(x: xPosition, y: barStartingYValue) //Establish where to begin drawing on Y axis
        let endPoint = CGPoint(x: xPosition, y: bounds.height - xyStartingPoint.y - bottomMargin) //Establish where to end drawing on Y axis
        
        if startPoint.y > endPoint.y { //If the start point ever makes it to the point where it is lower in the graph, then set it to the endpoint so it is not showing at all. This especially can be noticed with a zero value, since there is a little margin between the bottom of the graph and the x axis line
            startPoint.y = endPoint.y
        }
        
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setLineWidth(10)
        if value != 0 { //Sets the line cap to round for all values except for 0. Even a 0 value with a round cap will show something on the graph. Since we dont want anything showing for a 0 value, the line cap is butt
            ctx?.setLineCap(.round)
        } else {
            ctx?.setLineCap(.butt)
        }
        ctx?.setAlpha(0.75)
        ctx?.move(to: startPoint) //Move to start point
        ctx?.addLine(to: endPoint) //Add end point
        ctx?.strokePath() //Draw bar
    }
    
    ///Draws dotted line to indicate where goal is, if any
    private func drawGoalLine() {
        let goalValue = delegate?.getGoalValue()
        
        if goalValue != 0 {
            let endingXPoint = bounds.width //Where the X axis stop drawing at the right
            
            let xLineWidth = endingXPoint //Width of the x axis line
            
            let yLineHeight = bounds.height - xyStartingPoint.y //Height of the y axis line
            
            let highestValueOnYAxis = CGFloat((delegate?.getYAxisRangeValues().end)!) //The top y label value
            
            let goalYValue = yLineHeight - ((yLineHeight / highestValueOnYAxis) * CGFloat(goalValue!)) //The y location where to place the goal line
            
            let startPoint = CGPoint(x: xyStartingPoint.x, y: goalYValue) //Establish where to begin drawing Y axis. The beginning of the x axis line
            let endPoint = CGPoint(x: xLineWidth, y: goalYValue) //Establish where to end drawing Y axis. Basically the end of the x axis line
            
            let ctx = UIGraphicsGetCurrentContext()
            
            ctx?.setLineWidth(1)
            ctx?.setLineDash(phase: 0, lengths: [5, 5])
            ctx?.move(to: startPoint) //Move to start point
            ctx?.addLine(to: endPoint) //Add end point
            
            ctx?.strokePath() //Draw X axis
        }
    }
}
