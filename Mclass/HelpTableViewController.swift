//
//  HelpViewController.swift
//  Mclass
//
//  Created by Samuel Irish on 5/22/15.
//  Copyright (c) 2015 CAENiOS. All rights reserved.
//

import UIKit

class HelpTableViewController: UITableViewController {
    
    var helpNow:Bool!
    
    var problems: [String] = ["The projector won't turn on", "The projector isn't alligned correctly", "The view won't appear on screen", "The lectern isn't working", "The microphone isn't working", "The document camera isn't working", "Apple TV isn't working", "The microphone is missing", "The charging doc is missing", "Some cords are missing", "Other (Please specify)"]
    var selectedProb:String? = nil
    var selectedProbIndex:Int? = nil
    
    var tField: UITextField!
    
    @IBAction func cancelButtonTap(sender: UIButton) {
        self.navigationController!.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func doneButtonTap(sender: UIButton) {
        if self.selectedProb == nil{
            let alert = UIAlertController(title: "Please select an issue.", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil
            ))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        else {
            let help:String!
            if helpNow! {
                help = "Help is on the way!"
            }
            else {
                help = "Help will arrive after class."
            }
            let alert = UIAlertController(title: help, message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
            alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction)in
                self.navigationController!.popToRootViewControllerAnimated(true)
            }))
        
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func configurationTextField(textField: UITextField!)
    {
        textField.placeholder = "Enter an item"
        tField = textField
    }
    
    
    func Custom () {
        var tField: UITextField!
        
        func configurationTextField(textField: UITextField!)
        {
            textField.placeholder = "Briefly describe your problem."
            tField = textField
        }
        
        var alert = UIAlertController(title: "Enter Input", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler(configurationTextField)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction)in
            self.selectedProb = tField.text
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cancel = self.navigationItem.leftBarButtonItem
        var negSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        negSpace.width = -90
        self.navigationItem.leftBarButtonItems?.insert(negSpace, atIndex: 0)
        self.navigationItem.rightBarButtonItems?.insert(negSpace, atIndex: 0)
        
        let titleDict = [NSForegroundColorAttributeName: UIColor.yellowColor()]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict
        self.navigationController?.navigationBar.tintColor = UIColor.yellowColor()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return problems.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProblemCell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = problems[indexPath.row]
        
        // Configure the cell...
        if indexPath.row == selectedProbIndex {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        //Other row is selected - need to deselect it
        if let index = selectedProbIndex {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0))
            cell?.accessoryType = .None
        }
        
        selectedProbIndex = indexPath.row
        selectedProb = problems[indexPath.row]
        
        //update the checkmark for the current row
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = .Checkmark
        
        if (selectedProb == "Other (Please specify)") {
            Custom()
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
