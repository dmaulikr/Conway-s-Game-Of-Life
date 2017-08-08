//
//  TableViewController.swift
//  FinalProject
//
//  Created by Bruce S. Chen on 7/23/17.
//  Copyright © 2017 Harvard University. All rights reserved.
//

import UIKit

//this is where i need to set up the json parsing code I think

let source = "https://dl.dropboxusercontent.com/u/7544475/S65g.json"

class TableViewController: UITableViewController {
    var data = [String: [[Int]]]()
    var defaultSize = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        parseJSON()
    }

    override func viewWillAppear(_ animated: Bool) {
//        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data.count
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        cell.textLabel?.text = Array(self.data.keys)[indexPath.row]
        return cell
    }

    // Override to support conditional editing of the table view.
    
    /*
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    */
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Configuration"
    }

    // Override to support editing the table view.

    /*
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */
    
    
    /*
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var newData = data[indexPath.section]
            newData.remove(at: indexPath.row)
            data[indexPath.section] = newData
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    */
    
    
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? GridEditorViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                let theName = Array(self.data.keys)[indexPath.row]
                let theValue = self.data[theName]
                destination.theName = theName
                destination.grid = giveGrid(theValue!, defaultSize)
                destination.completionText = { (newText, newCoordinates) in
                    self.data.removeValue(forKey: theName)
                    self.data[newText] = newCoordinates
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension TableViewController {
    func parseJSON() {
        let fetcher = Fetcher()
        fetcher.fetchJSON(url: URL(string:source)!) { (json: Any?, message: String?) in
            //fetcher.fetchJSON(url: URL(string:weatherURL)!) { (json: Any?, message: String?) in
            guard message == nil else {
                print(message ?? "nil")
                return
            }
            guard let json = json else {
                print("no json")
                return
            }
            //print(json)
            //let resultString = (json as AnyObject).description
            let jsonArray = json as! NSArray
            for i in 0..<jsonArray.count {
                let jsonDictionary = jsonArray[i] as! NSDictionary
                let jsonTitle = jsonDictionary["title"] as! String
                let jsonContents = jsonDictionary["contents"] as! [[Int]]
                //print (jsonTitle, jsonContents)
                self.data[jsonTitle] = jsonContents
                /*
                OperationQueue.main.addOperation {
                    self.titles.append(resultString!)
                }
                */
            }
            self.tableView.reloadData()
        }
    }
    
    func giveGrid(_ positions: [[Int]], _ defaultSize: Int) -> GridProtocol {
        var max = 0
        for i in 0..<positions.count {
            for j in 0..<2 {
                if positions[i][j] > max {
                    max = positions[i][j]
                }
            }
        }
        if (max == 0) {
            max = defaultSize
        } else if (max < 40) {
            max = Int(Double(max) * 2.5)
        } else {
            max = Int(Double(max) * 1.5)
        }
        var grid = Grid(max, max)
        
        for i in 0..<positions.count {
            grid[positions[i][0], positions[i][1]] = grid[positions[i][0], positions[i][1]].toggle(value: grid[positions[i][0], positions[i][1]])
        }
        return grid
    }
}

extension TableViewController {
    func addRow(_ name: String, _ size: Int) {
        data[name] = [[Int]]()
        defaultSize = size
        tableView.reloadData()
    }
}
