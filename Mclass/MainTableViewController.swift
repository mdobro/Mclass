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
    var rooms = [String]?()
    var projs = [String]?()

    @IBOutlet var sourceTable: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: selectedModeIndex![selectedProj] as Int, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.Bottom)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var projectors: String = "0"
        
        /* FILE INPUT STUFF */
        if let aStreamReader = StreamReader(path: NSBundle.mainBundle().pathForResource("CAENView-Classrooms", ofType: "txt")! ) {
            while let line = aStreamReader.nextLine() {
                let fullNameArr = line.componentsSeparatedByString(",")
                if (rooms?.append(fullNameArr[0]) == nil) {
                    rooms = [fullNameArr[0]]
                }
                if (projs?.append(fullNameArr[1]) == nil) {
                    projs = [fullNameArr[1]]
                }
            }
            // You can close the underlying file explicitly. Otherwise it will be
            // closed when the reader is deallocated.
            aStreamReader.close()
        }
        
        
        selectedMode = ["OFF", "OFF", "OFF", "OFF"]
        selectedModeIndex = [4, 4, 4, 4]
        
        let name = "BEYSTER1670"
        for var i = 0; i < rooms!.count; i++ {
            if rooms?[i] == name {
                projectors = projs![i]
            }
        }

        if projectors == "2" {
            let items = ["Projector 1", "Projector 2"]
            customSC = UISegmentedControl(items: items)
            customSC!.selectedSegmentIndex = 0
            
            let frame = UIScreen.mainScreen().bounds
            customSC!.frame = CGRectMake(frame.minX, frame.minY + 620,
                frame.width - 710, frame.height*0.1)
            
            UISegmentedControl.appearance().setTitleTextAttributes(NSDictionary(objects: [UIFont.systemFontOfSize(25.0)], forKeys: [NSFontAttributeName]) as [NSObject : AnyObject], forState: UIControlState.Normal)
            
            customSC?.addTarget(self, action: "didselectsegment:", forControlEvents: .ValueChanged)
            
            delegate.projDidChange(2, source: "OFF")
            
            self.view.addSubview(customSC!)
            
        }
        
        if projectors == "3" {
            let items = ["Proj 1", "Proj 2", "Proj 3"]
            customSC = UISegmentedControl(items: items)
            customSC!.selectedSegmentIndex = 0
            
            let frame = UIScreen.mainScreen().bounds
            customSC!.frame = CGRectMake(frame.minX, frame.minY + 620,
                frame.width - 710, frame.height*0.1)
            
            UISegmentedControl.appearance().setTitleTextAttributes(NSDictionary(objects: [UIFont.systemFontOfSize(25.0)], forKeys: [NSFontAttributeName]) as [NSObject : AnyObject], forState: UIControlState.Normal)
            
            customSC?.addTarget(self, action: "didselectsegment:", forControlEvents: .ValueChanged)
            
            delegate.projDidChange(2, source: "OFF")
            
            self.view.addSubview(customSC!)
            
        }
        
        if projectors == "4" {
            let items = ["Proj 1", "Proj 2", "Proj 3", "Proj 4"]
            customSC = UISegmentedControl(items: items)
            customSC!.selectedSegmentIndex = 0
            
            let frame = UIScreen.mainScreen().bounds
            customSC!.frame = CGRectMake(frame.minX, frame.minY + 620,
                frame.width - 710, frame.height*0.1)
            
            UISegmentedControl.appearance().setTitleTextAttributes(NSDictionary(objects: [UIFont.systemFontOfSize(25.0)], forKeys: [NSFontAttributeName]) as [NSObject : AnyObject], forState: UIControlState.Normal)
            
            customSC?.addTarget(self, action: "didselectsegment:", forControlEvents: .ValueChanged)
            
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
        case 2:
            selectedProj = 2
            self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: selectedModeIndex![selectedProj] as Int, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.Bottom)
        case 3:
            selectedProj = 3
            self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: selectedModeIndex![selectedProj] as Int, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.Bottom)
        default:
            print("Error", true)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("ModeCell", forIndexPath: indexPath) as UITableViewCell
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
    
    func selectionHelper(indexPath:NSIndexPath) {
        selectedModeIndex?[selectedProj] = indexPath.row
        selectedMode?[selectedProj] = modes[indexPath.row]
        delegate.projDidChange(selectedProj+1, source: modes[indexPath.row])
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        if indexPath.row == 4 {
        //show alert if turning off projector
        let turnOffAlert = UIAlertController(title: "Are you sure you'd like to turn off the projector?", message: "The projector will take a minute to turn on again after being turned off.", preferredStyle: UIAlertControllerStyle.Alert)
            turnOffAlert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) in
                self.selectionHelper(indexPath)
            }))
            turnOffAlert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: { (UIAlertAction) in
                let index = NSIndexPath(forRow: (self.selectedModeIndex?[self.selectedProj])!, inSection: 0)
                self.sourceTable.selectRowAtIndexPath(index, animated: false, scrollPosition: UITableViewScrollPosition.None)
            }))
            self.presentViewController(turnOffAlert, animated: true, completion: nil)
        } else {
            selectionHelper(indexPath)
        }
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
