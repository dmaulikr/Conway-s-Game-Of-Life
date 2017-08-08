//
//  GridEditorViewController.swift
//  FinalProject
//
//  Created by Bruce S. Chen on 7/23/17.
//  Copyright © 2017 Harvard University. All rights reserved.
//

import UIKit

//this is the controller that controls the view that shows the grid the user manually picks

class GridEditorViewController: UIViewController {
    
    var grid: GridProtocol!
    var theName: String?
    
    var completionText: ((String, [[Int]]) -> Void)?
    @IBOutlet weak var gridView: GridView!
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        // Do any additional setup after loading the view.
        textField.text = theName
        gridView.dataSource = self
        gridView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func save(_ sender: Any) {
        //sendNotification(grid);
        StandardEngine.sharedInstance.grid = self.grid
        if let text = textField.text, let coordinates = reportCells(), let completion = completionText {
            completion(text, coordinates)
        }
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func cancel(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension GridEditorViewController: GridViewDataSource, GridViewDelegate {
    var rows: Int { return grid.size.rows }
    var cols: Int { return grid.size.cols }
    
    func state(_ row: Int, _ col: Int) -> CellState{
        return grid[row, col]
    }
    
    func toggle(_ row: Int, _ col: Int) -> Void {
        let currentState = state(row,col)
        let newValue = currentState.toggle(value: currentState)
        self.grid[row,col] = newValue
    }
}

extension GridEditorViewController {
    func reportCells() -> [[Int]]? {
        var result = [[Int]]()
        for i in 0..<grid.size.rows {
            for j in 0..<grid.size.cols {
                if grid[i, j] == .alive {
                    let temp = [i, j]
                    result.append(temp)
                }
            }
        }
        return result
    }
}
