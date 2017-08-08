//
//  GridView.swift
//
//  Created by Bruce S. Chen on 7/9/17.
//

import UIKit

protocol GridViewDataSource {
    var cols: Int { get }
    var rows: Int { get }
    func state(_ row: Int, _ col: Int) -> CellState
}

protocol GridViewDelegate {
    func toggle(_ row: Int, _ col: Int) -> Void
}

class GridView: UIView {

    var livingColor: UIColor = UIColor.green
    var emptyColor: UIColor = UIColor.darkGray
    var bornColor: UIColor = UIColor.green.withAlphaComponent(0.6)
    var diedColor: UIColor = UIColor.darkGray.withAlphaComponent(0.6)
    var gridColor: UIColor = UIColor.black
    var gridWidth: CGFloat = 0.5
    
    var colorBundles: [UIColor] = [UIColor.yellow, UIColor.green, UIColor.cyan, UIColor.red, UIColor.orange, UIColor.magenta]
    
    var dataSource: GridViewDataSource?
    var delegate: GridViewDelegate?

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Make sure that grid has a value or return
//        let size = grid.size.cols
        //draw grid
        
        guard let dataSource = dataSource,
            dataSource.cols != 0, dataSource.rows != 0 else {
            return
        }
        let size = dataSource.cols
        
        let origin = rect.origin
        let width = rect.width
        let height = rect.height
        let verticalGap = height/CGFloat(size)
        let horizontalGap = width/CGFloat(size)
        drawFrame(origin, verticalGap, horizontalGap, width, height)
        
        //draw cells
        let midX = origin.x + horizontalGap/2
        let midY = origin.y + verticalGap/2
        let radius = verticalGap/2
        drawCircle(midX, midY, radius)
    }
    
    var lastTouchedPosition: GridPosition?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = process(touches: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = process(touches: touches)
    }
    
    /* this method is to handle touch event
     */
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = nil
    }
    
    func process(touches: Set<UITouch>) -> GridPosition? {
        StandardEngine.sharedInstance.stopTimer()
        //let size = grid.size.cols
        guard let dataSource = dataSource,
            dataSource.cols != 0, dataSource.rows != 0 else {
                return nil
        }
        let size = dataSource.cols
        if let firstTouch = touches.first {
            let pointInView = firstTouch.location(in: self)
            let gridPosition = getPosition(pointInView, self.frame.width/CGFloat(size))
            //Now directly use sharedInstance to modify the grid
            //StandardEngine.sharedInstance[gridPosition.0, gridPosition.1] = grid[gridPosition.0, gridPosition.1].toggle(value: grid[gridPosition.0, gridPosition.1])
            delegate?.toggle(gridPosition.0, gridPosition.1)
            self.setNeedsDisplay()
            return gridPosition
        } else {
            print("No touch")
            return nil
        }
    }
    
    /* helper method for draw part, to perform frame drawing
       param: rect.origin, rect.width, rect.hright, arbitrary vars to determine the size of each cell
       return: none
    */
    func drawFrame(_ origin: CGPoint, _ verGap: CGFloat, _ horGap: CGFloat, _ width: CGFloat, _ height: CGFloat) {
        // Make sure have a grid
        guard let dataSource = dataSource,
            dataSource.cols != 0, dataSource.rows != 0 else {
                return
        }
        let size = dataSource.cols
        
        let edgePath = UIBezierPath()
        
        edgePath.lineWidth = CGFloat(gridWidth)
        
        for i in 0...size {
            edgePath.move(to: CGPoint(x: origin.x, y: origin.y + verGap * CGFloat(i)))
            edgePath.addLine(to: CGPoint(x: origin.x + width, y: origin.y + verGap * CGFloat(i)))
            gridColor.setStroke()
            edgePath.stroke()
        }
        
        for i in 0...size {
            edgePath.move(to: CGPoint(x: origin.x + horGap * CGFloat(i), y: origin.y))
            edgePath.addLine(to: CGPoint(x: origin.x + horGap * CGFloat(i), y: origin.y + height))
            gridColor.setStroke()
            edgePath.stroke()
        }
    }
    
    /* helper method for draw part, to perform circles drawing
       param: coordinates of the top left center, radius
       return: none
    */
    func drawCircle(_ startX: CGFloat, _ startY: CGFloat, _ rad: CGFloat) {
        // Make sure you have a grid
        
        guard let dataSource = dataSource,
            dataSource.cols != 0, dataSource.rows != 0 else {
                return
        }
        let size = dataSource.cols
        
        for i in 0..<size {
            let midX = startX + CGFloat(i) * rad * 2
            for j in 0..<size {
                let midY = startY + CGFloat(j) * rad * 2
                let center = CGPoint(x: midX, y: midY)
                let arcPath = UIBezierPath(arcCenter: center, radius: rad - gridWidth, startAngle: 0.0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
                
                arcPath.lineWidth = CGFloat(1.0)
                //the subscript is directly fetching the cellstate
                let cellstate = dataSource.state(i, j)
                //let color = randomColor()
                switch cellstate {
                case .empty:
                    emptyColor.setStroke()
                    emptyColor.setFill()
                case .alive:
                    livingColor.setStroke()
                    livingColor.setFill()
                case .born:
                    bornColor.setStroke()
                    bornColor.withAlphaComponent(0.6).setFill()
                case .died:
                    diedColor.setStroke()
                    diedColor.setFill()
                }
                arcPath.stroke()
                arcPath.fill()
            }
        }
    }
    
    /* this helper method is to get the position in the grid when a specific cell is touched
       param: the actual point in the frame that is touched, the diameter of each cell, simple math
       return: a tuple that holds the position information of the cell in the grid
     */
    func getPosition(_ point: CGPoint, _ diameter: CGFloat) -> GridPosition {
        let xPoint = point.x
        let yPoint = point.y
        return GridPosition(row: Int(xPoint/diameter), col: Int(yPoint/diameter))
    }
    
    func randomColor() -> UIColor {
        let index = Int(arc4random_uniform(6))
        return colorBundles[index]
    }
}
