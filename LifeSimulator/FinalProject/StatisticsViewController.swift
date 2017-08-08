//
//  StatisticsViewController.swift
//
//  Created by Bruce S. Chen on 7/15/17.
//  Copyright © 2017 Harvard University. All rights reserved.
//

import UIKit

//in here there has to be a listener that can listens to the change published to the
//notification center

class StatisticsViewController: UIViewController {
    var grid: GridProtocol? {
        willSet {
            checkValidity(grid, newValue)
            update(newValue)
            updateLabels()
        }
    }
    var dataHolder: [CellState: Int] = [.empty: 0, .born: 0, .alive: 0, .died: 0]
    
    @IBOutlet weak var numEmpty: UILabel!
    @IBOutlet weak var numBorn: UILabel!
    @IBOutlet weak var numLiving: UILabel!
    @IBOutlet weak var numDead: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        toListen()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func reset(_ sender: UIButton) {
        grid = nil
    }
    
    
    func toListen() {
        let name = Notification.Name("ChangeHappens")
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
    
    func checkValidity(_ old: GridProtocol?, _ new: GridProtocol?) {
        if let grid = old, let newGrid = new, grid.size == newGrid.size {
            return
        }
        dataHolder = [.empty: 0, .born: 0, .alive: 0, .died: 0]
    }
    
    func update(_ grid: GridProtocol?) {
        guard let grid = grid else {
            return
        }
        for i in 0..<grid.size.rows {
            for j in 0..<grid.size.cols {
                let state = grid[i, j]
                let currentCount = dataHolder[state] ?? 0
                dataHolder[state] = currentCount + 1
            }
        }
    }
    
    func updateLabels() {
        numEmpty.text = "\(dataHolder[.empty] ?? 0)"
        numBorn.text = "\(dataHolder[.born] ?? 0)"
        numLiving.text = "\(dataHolder[.alive] ?? 0)"
        numDead.text = "\(dataHolder[.died] ?? 0)"
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
