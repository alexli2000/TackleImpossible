//
//  SettingsTableViewController.swift
//  TackleImpossible
//
//  Created by Alexander Li on 2016-01-31.
//  Copyright © 2016 Alexander Li. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
        
    @IBOutlet weak var weightStepper: UIStepper!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var weightButton: UIButton!
    
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureInitialValues()
    }
    
    func configureInitialValues() {
        
        if NSUserDefaults.standardUserDefaults().floatForKey("userWeight") < 30 {
            NSUserDefaults.standardUserDefaults().setFloat(50, forKey: "userWeight")
        }
        
        weightStepper.value = Double(NSUserDefaults.standardUserDefaults().floatForKey("userWeight"))
        weightLabel.text = Int(weightStepper.value).description
        
        if NSUserDefaults.standardUserDefaults().boolForKey("userGender") == true {
            genderSegmentedControl.selectedSegmentIndex = 0
        } else {
            genderSegmentedControl.selectedSegmentIndex = 1
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }

    @IBAction func weightStepperChanged(sender: AnyObject) {
        weightLabel.text = Int(weightStepper.value).description
    }
    
    @IBAction func weightUnitButtonTapped(sender: AnyObject) {
        switch weightButton.titleLabel!.text! {
        case "kg":
            weightButton.setTitle("lb", forState: .Normal)
        case "lb":
            weightButton.setTitle("st", forState: .Normal)
        case "st":
            weightButton.setTitle("lb", forState: .Normal)
        default:
            break
        }
    }

    @IBAction func genderSegmentedControlChanged(sender: AnyObject) {
        
        
    }
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setFloat(Float(weightStepper.value), forKey: "userWeight")
        NSUserDefaults.standardUserDefaults().setBool(genderSegmentedControl.selectedSegmentIndex == 0, forKey: "userGender")
        NSUserDefaults.standardUserDefaults().setObject(weightButton.titleLabel!.text!, forKey: "weightUnits")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}
