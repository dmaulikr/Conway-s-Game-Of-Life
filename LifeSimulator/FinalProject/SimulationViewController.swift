//
//  SimulationViewController.swift
//
//  Created by Bruce S. Chen on 7/15/17.
//  Copyright © 2017 Harvard University. All rights reserved.
//

import UIKit

protocol EngineDelegate {
    func engineDidUpdate(engine: EngineProtocol)
}

class SimulationViewController: UIViewController, EngineDelegate {
    
    @IBOutlet weak var gridView: GridView!
    var grid: GridProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //gridView.grid = StandardEngine.sharedInstance.grid
        grid = StandardEngine.sharedInstance.grid
        gridView.dataSource = self
        gridView.delegate = self
        StandardEngine.sharedInstance.delegate = self
        //toListen()
    }
    
    @IBAction func buttonPressed(_ sender: UIButton!) {
        StandardEngine.sharedInstance.grid = StandardEngine.sharedInstance.step()
    }
    
    @IBAction func save(_ sender: UIButton!) {
        saveCurrGrid()
    }
    
    @IBAction func reset(_ sender: UIButton!) {
        StandardEngine.sharedInstance.rows = self.grid.size.rows
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func engineDidUpdate(engine: EngineProtocol) {
        //gridView.grid = engine.grid
        self.grid = engine.grid
        gridView.setNeedsDisplay()
    }
    
    /*
    @IBAction func switchDidChange(_ sender: UISwitch) {
        //switchValue.text = sender.isOn ? "On" : "Off"
        if sender.isOn {
            StandardEngine.sharedInstance.startTimer()
        } else {
            StandardEngine.sharedInstance.stopTimer()
        }
    }
    */
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SimulationViewController: GridViewDataSource, GridViewDelegate {
    var rows: Int { return grid.size.rows }
    var cols: Int { return grid.size.cols }
    
    func state(_ row: Int, _ col: Int) -> CellState{
        return grid[row, col]
    }
    
    func toggle(_ row: Int, _ col: Int) -> Void {
        let currentState = state(row,col)
        let newValue = currentState.toggle(value: currentState)
        StandardEngine.sharedInstance.grid[row,col] = newValue
    }
}

extension SimulationViewController {
    func toListen() {
        let name = Notification.Name("NowRunMe")
        let notificationSelector = #selector(notified(notification:))
        NotificationCenter.default.addObserver(self,
                                               selector: notificationSelector,
                                               name: name,
                                               object: nil)
    }
    
    func notified(notification: Notification) {
        if let grid = notification.object as? Grid {
            self.grid = grid as GridProtocol
        } else {
            print("Not expected")
        }
    }
}

extension SimulationViewController {
    func saveCurrGrid() {
        var toJSON: Dictionary<String, Any> = Dictionary<String, Any>();
        toJSON["title"] = "ToSaveProgress"
        var arrayOfPositions = [[Int]]()
        arrayOfPositions = populateArray()
        toJSON["contents"] = arrayOfPositions
        //all above is to create the dictionary, and it will be treated as json object
        convertToJSON(toJSON)
    }
    
    func populateArray() -> [[Int]] {
        var array = [[Int]]()
        array.append([self.grid.size.cols, self.grid.size.rows])
        for i in 0..<grid.size.cols {
            for j in 0..<grid.size.cols {
                if self.grid[i, j] == .alive || self.grid[i, j] == .born {
                    let temp = [i, j]
                    array.append(temp)
                }
            }
        }
        return array
    }
    
    func convertToJSON(_ dic: Dictionary<String, Any>) -> Void {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
            let jsonString = String(data: jsonData, encoding: .utf8)
            //then save this string
            //print("\(String(describing: jsonString))")
            UserDefaults.standard.set(jsonString, forKey: "LastSavedGridState")
        } catch {
            print("The json is not legit")
        }
    }
}
