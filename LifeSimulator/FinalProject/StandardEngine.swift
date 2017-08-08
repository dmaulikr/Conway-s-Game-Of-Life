//
//  StandardEngine.swift
//
//  Created by Bruce S. Chen on 7/15/17.
//  Copyright © 2017 Harvard University. All rights reserved.
//

import Foundation

protocol EngineProtocol {
    var delegate: EngineDelegate? { get set }
    var grid: GridProtocol { get }
    var refreshRate: Double { get set }
    var refreshTime: Timer? { get set }
    var rows: Int { get set }
    var cols: Int { get set }
    init(_ rows: Int, _ cols: Int)
    func step() -> GridProtocol
}

class StandardEngine: EngineProtocol {
    var delegate: EngineDelegate?
    var grid: GridProtocol {
        didSet {
            delegate?.engineDidUpdate(engine: self)
            sendNotification()
        }
    }
    var refreshRate: Double = 0.0 {
        didSet {
            stopTimer()
        }
    }
    var refreshTime: Timer?
    var rows: Int {
        didSet {
            // Resize the grid
            grid = Grid(rows, rows)
            stopTimer()
        }
    }
    var cols: Int
    
    var dataHolder: Dictionary<String, Int>
    
    static var sharedInstance: StandardEngine = StandardEngine.init(10, 10)
    
    internal required init(_ rows: Int, _ cols: Int) {
        self.refreshTime = Timer()
        self.rows = rows
        self.cols = cols
        grid = Grid(rows, cols)
        dataHolder = ["empty": rows*rows, "born": 0, "living": 0, "dead": 0]
    }
    
    func step() -> GridProtocol {
        return grid.next()
    }
}

extension StandardEngine {
    subscript(_ rows: Int, _ cols: Int) -> CellState{
        get { return grid[rows, cols] }
        set { grid[rows, cols] = newValue }
    }
    
    func startTimer() {
        refreshTime = Timer.scheduledTimer(withTimeInterval: refreshRate, repeats: true) { timer in
            self.refreshTime = timer
            self.grid = self.step()
        }
    }
    
    func stopTimer() {
        refreshTime?.invalidate()
        refreshTime = nil
    }
}

extension StandardEngine {
    func sendNotification() {
        let notificationName = Notification.Name("ChangeHappens")
        NotificationCenter.default.post(name: notificationName,
                                        object: grid,
                                        userInfo: nil)
    }
}
