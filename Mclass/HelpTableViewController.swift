//
//  HelpViewController.swift
//  Mclass
//
//  Created by Samuel Irish on 5/22/15.
//  Copyright (c) 2015 CAENiOS. All rights reserved.
//

import UIKit

protocol HelpTableDelegate {
    var helpMessage:String! {get}
    var nowOrLater:String! {get}
    func whenToSendHelp(nowOrLater:String)
    func sendProblem(igotaproblem:String)
}

class HelpTableViewController: UITableViewController {
    var delegate:HelpTableDelegate!
    
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
                delegate.whenToSendHelp("Now")
            }
            else {
                help = "Help will arrive after class."
                delegate.whenToSendHelp("Later")
            }
            let alert = UIAlertController(title: help, message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
            alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction)in
                self.navigationController!.popToRootViewControllerAnimated(true)
            }))
            
            delegate.sendProblem(selectedProb!)
            
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
    
    
    func Custom (table:UITableView) {
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
            self.problems[10] = "Other - \"\(self.selectedProb!)\""
            table.reloadData()
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buttonDict = [NSFontAttributeName: UIFont(name: "Arial", size: 30)!]
        
        let cancelBarButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelButtonTap:")
        cancelBarButton.setTitleTextAttributes(buttonDict, forState: UIControlState.Normal)
        self.navigationItem.leftBarButtonItem = cancelBarButton
        
        let doneBarButton = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: "doneButtonTap:")
        doneBarButton.setTitleTextAttributes(buttonDict, forState: UIControlState.Normal)
        self.navigationItem.rightBarButtonItem = doneBarButton
        
        //changes button and title color to yellow, changes font size
        let titleDict = [NSForegroundColorAttributeName: UIColor.yellowColor(), NSFontAttributeName: UIFont(name: "Arial", size: 25)!]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict
        self.navigationController?.navigationBar.tintColor = UIColor.yellowColor()
        //
        
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
        cell.textLabel?.font = UIFont.systemFontOfSize(25.0)
        cell.textLabel?.textColor = UIColor(red:14/255, green:122/255, blue:254/255, alpha:1.0)
        
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
        
        if (selectedProb == self.problems[10]) {
            Custom(tableView)
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
