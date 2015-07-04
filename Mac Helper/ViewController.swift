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
    
    var PROJ1:PJProjector!
    let PROJ1IP = "127.0.0.1"
    let PJLINKPORT = 4352
    
    let buttons = ["Connection Status", "Projector 1 Source", "Projector 2 Source", "HDCP Status", "Problem Status", "Problem Message", "Source Volume", "Projector 1 Connection Status", "Projector 1 Power"]
    //Proj1 connection at Statuses[7]
    var Statuses:[String]!
    
    @IBOutlet weak var table: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.table.gridStyleMask = NSTableViewGridLineStyle.SolidVerticalGridLineMask
        
        NSURLProtocol.registerClass(PJURLProtocolRunLoop)
        PROJ1 = PJProjector(host: PROJ1IP, port: PJLINKPORT)
        Statuses = ["Not Connected", "", "", "", "", "", "", "Not Connected", ""]
        self.subToNotifications()
        PROJ1.refreshAllQueriesForReason(PJRefreshReason.ProjectorCreation)
        
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
    
    //USB Channel send/recieve
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
    
    //Proj Send/Recieve
    func subToNotifications() {
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "projRequestBegin:", name: PJProjectorRequestDidBeginNotification, object: nil)
        center.addObserver(self, selector: "projRequestEnd:", name: PJProjectorRequestDidEndNotification, object: nil)
        center.addObserver(self, selector: "projDidChange:", name: PJProjectorDidChangeNotification, object: nil)
        center.addObserver(self, selector: "projConnectionChange:", name: PJProjectorConnectionStateDidChangeNotification, object: nil)
    }
    
    func unsubFromNotifications() {
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(self, name: PJProjectorRequestDidBeginNotification, object: nil)
        center.removeObserver(self, name: PJProjectorRequestDidEndNotification, object: nil)
        center.removeObserver(self, name: PJProjectorDidChangeNotification, object: nil)
        center.removeObserver(self, name: PJProjectorConnectionStateDidChangeNotification, object: nil)
    }
    
    func projRequestBegin(notification:NSNotification) {
        //they just started a loading animation here
    }
    
    func projRequestEnd(notification:NSNotification) {
        //ended animation
    }
    
    func projDidChange(notification:NSNotification) {
        //reload tabledata that deals with button status etc
        Statuses[8] = PJResponseInfoPowerStatusQuery.stringForPowerStatus(PROJ1.powerStatus)
    }
    
    func projConnectionChange(notification:NSNotification) {
        //reload tabledata that deals with connection
        Statuses[7] = PJProjector.stringForConnectionState(PROJ1.connectionState)
        table.reloadData()
    }

}

