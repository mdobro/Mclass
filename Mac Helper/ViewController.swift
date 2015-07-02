//
//  ViewController.swift
//  Mac Helper
//
//  Created by Mike Dobrowolski on 6/10/15.
//  Copyright (c) 2015 CAENiOS. All rights reserved.
//

import Cocoa

@objc class ViewController: NSViewController {
    
    let USBHelper = USBhelper()
    let buttons = ["Connection Status", "Projector 1 Source", "Projector 2 Source", "HDCP Status", "Problem Status", "Problem Message","Source Volume"]
    var Statuses = ["Not Connected", "", "", "", "", "", ""] //initial status
    
    @IBOutlet weak var table: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.table.gridStyleMask = NSTableViewGridLineStyle.SolidVerticalGridLineMask
        
        USBHelper.startInit(self)
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return buttons.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn?.identifier == "Buttons" {
            let cell = tableView.makeViewWithIdentifier("Buttons", owner: self) as! NSTableCellView
            cell.textField?.stringValue = buttons[row]
            return cell
        }
        else if tableColumn?.identifier == "Statuses"{
            let cell = tableView.makeViewWithIdentifier("Statuses", owner: self) as! NSTableCellView
            cell.textField?.stringValue = Statuses[row]
            return cell
            
        }
        return nil
    }
    
    //Channel send/recieve
    @objc func connected(connectionOn:Bool){
        if connectionOn {
            Statuses[0] = "Connected"
        }
        else {
            Statuses = ["Not Connected", "", "", "", "", "", ""]
        }
        table.reloadData()
    }
    
    @objc func recievedP1source(source:String){
        Statuses[1] = source
        table.reloadData()
    }
    
    @objc func recievedP2source(source:String){
        Statuses[2] = source
        table.reloadData()
    }
    
    @objc func recievedHDCPchange(switchOn:String){
        Statuses[3] = switchOn
        table.reloadData()
    }
    
    @objc func recievedProblemRoom(nowOrLater:String) {
        Statuses[4] = nowOrLater
        table.reloadData()
    }
    
    @objc func recievedProblem(problem:String){
        Statuses[5] = problem
        table.reloadData()
    }
    
    @objc func recievedVolume(vol:String) {
        Statuses[6] = vol
        table.reloadData()
        
    }

}

