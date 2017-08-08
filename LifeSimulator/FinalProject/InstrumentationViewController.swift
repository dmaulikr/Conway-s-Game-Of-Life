//
//  InstrumentationViewController.swift
//
//  Created by Bruce S. Chen on 7/15/17.
//  Copyright © 2017 Harvard University. All rights reserved.
//

import UIKit

class InstrumentationRootViewController: UIViewController {
    
    @IBOutlet weak var sliderValue: UILabel!
    @IBOutlet weak var stepperValue: UILabel!
    @IBOutlet weak var switchValue: UILabel!
    
    var plainTableView: TableViewController?
    
    @IBAction func sliderDidChange(_ sender: UISlider) {
        let value = (Double(sender.value)*10).rounded()/10
        sliderValue.text = "\(value)"
        StandardEngine.sharedInstance.refreshRate = Double(sender.value)
    }
    
    @IBAction func stepperDidChange(_ sender: UIStepper) {
        stepperValue.text = "\(Int(sender.value))"
        StandardEngine.sharedInstance.rows = Int(sender.value)
    }
    
    @IBAction func switchDidChange(_ sender: UISwitch) {
        switchValue.text = sender.isOn ? "On" : "Off"
        if sender.isOn {
            StandardEngine.sharedInstance.startTimer()
        } else {
            StandardEngine.sharedInstance.stopTimer()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationController?.setNavigationBarHidden(true, animated: false)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func addRow(_ sender: UIBarButtonItem) {
        plainTableView?.addRow("New Item", Int(stepperValue.text!)!)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? TableViewController {
            plainTableView = destination
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}
