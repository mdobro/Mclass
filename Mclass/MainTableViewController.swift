//
//  TableViewController.swift
//  Mclass
//
//  Created by Mike Dobrowolski on 5/22/15.
//  Copyright (c) 2015 CAENiOS. All rights reserved.
//

import UIKit

protocol MainTableViewDelegate {
    var proj1source:String! {get}
    var proj2source:String! {get}
    func projDidChange(projector: Int, source:String)
}

class MainTableViewController: UITableViewController {
    var delegate:MainTableViewDelegate!
    
    var modes: [String] = ["Laptop", "Document Camera", "Apple TV", "Blank Screen", "OFF"]
    var selectedMode = [String]?()
    var selectedModeIndex = [Int]?()
    var selectedProj = 0
    var customSC:UISegmentedControl? = nil
    var rowToSelect: NSIndexPath? = nil

    @IBOutlet var sourceTable: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: selectedModeIndex![selectedProj] as Int, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.Bottom)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = NSURL(string: "CAENViewClassTest.csv") {
            var error: NSErrorPointer = nil
            
            if let csv = CSV(contentsOfURL: url, error: error) {
                // Rows
                let rows = csv.rows
                /*let headers = csv.headers  //=> ["id", "name", "age"]
                let alice = csv.rows[0]    //=> ["id": "1", "name": "Alice", "age": "18"]
                let bob = csv.rows[1]      //=> ["id": "2", "name": "Bob", "age": "19"]
                
                
                // Columns
                let columns = csv.columns
                let names = csv.columns["name"]  //=> ["Alice", "Bob", "Charlie"]
                let ages = csv.columns["age"]    //=> ["18", "19", "20"]*/
            }
            
        }
        // CSV Code for getting number of projectors based on room name will be above/here
        
        let projectors: Int = 2
        if projectors == 2 {
            let items = ["Projector 1", "Projector 2"]
            customSC = UISegmentedControl(items: items)
            customSC!.selectedSegmentIndex = 0
            
            let frame = UIScreen.mainScreen().bounds
            customSC!.frame = CGRectMake(frame.minX, frame.minY + 620,
                frame.width - 710, frame.height*0.1)
            
            UISegmentedControl.appearance().setTitleTextAttributes(NSDictionary(objects: [UIFont.systemFontOfSize(25.0)], forKeys: [NSFontAttributeName]) as [NSObject : AnyObject], forState: UIControlState.Normal)
            
            customSC?.addTarget(self, action: "didselectsegment:", forControlEvents: .ValueChanged)
            
            selectedMode = ["OFF", "OFF"]
            selectedModeIndex = [4, 4]
            
            delegate.projDidChange(2, source: "OFF")
            
            self.view.addSubview(customSC!)
            
        }
        
        delegate.projDidChange(1, source: "OFF")
        
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    @IBAction func didselectsegment (sender: UISegmentedControl ) {
        switch customSC!.selectedSegmentIndex
        {
        case 0:
            selectedProj = 0
            self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: selectedModeIndex![selectedProj] as Int, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.Bottom)
        case 1:
            selectedProj = 1
            self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: selectedModeIndex![selectedProj] as Int, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.Bottom)
        default:
            println("Error")
        }
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
        return modes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ModeCell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = modes[indexPath.row]
        
        // Configure the cell...
        /*if indexPath.row == selectedModeIndex {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }*/
        cell.textLabel?.font = UIFont.systemFontOfSize(30.0)
        cell.textLabel?.textColor = UIColor(red:14/255, green:122/255, blue:254/255, alpha:1.0)
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        //Other row is selected - need to deselect it
        if let index = selectedModeIndex?[selectedProj] {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0))
            cell?.backgroundColor = UIColor.clearColor()
        }
        
        selectedModeIndex?[selectedProj] = indexPath.row
        selectedMode?[selectedProj] = modes[indexPath.row]
        
        delegate.projDidChange(selectedProj+1, source: modes[indexPath.row])

        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        //cell?.accessoryType = .Checkmark
        
        //cell?.backgroundColor = UIColor(red:14/255, green:50/255, blue:100/255, alpha:0.4)
    }
    
    

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

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
