//
//  ViewController.swift
//  Mac Helper
//
//  Created by Mike Dobrowolski on 6/10/15.
//  Copyright (c) 2015 CAENiOS. All rights reserved.
//

import Cocoa

enum EPSONINPUTS {
    case Computer, BNC, Video, SVideo, HDMI, DisplayPort, LAN, HDBaseT
}

@objc class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    let USBHelper = USBhelper()
    
    var PROJ1:PJProjector!
    let PROJ1IP = "10.160.10.242"
    let PJLINKPORT = 4352
    var inputDict:[String: EPSONINPUTS]!
    var equivalentQueue = false;
    
    let buttons = ["Connection Status", "Projector 1 Source", "Projector 2 Source", "HDCP Status", "Problem Status", "Problem Message", "Source Volume", "Projector 1 Connection Status", "Projector 1 Power", "Projector 1 Input Input"]
    //Proj1 connection at Statuses[7]
    var Statuses:[String]!
    
    @IBOutlet weak var table: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.table.gridStyleMask = NSTableViewGridLineStyle.SolidVerticalGridLineMask
        
        NSURLProtocol.registerClass(PJURLProtocolRunLoop)
        PROJ1 = PJProjector(host: PROJ1IP, port: PJLINKPORT)
        Statuses = ["Not Connected", "", "", "", "", "", "", "", "", ""]
        self.subToNotifications()
        PROJ1.refreshAllQueriesForReason(PJRefreshReason.ProjectorCreation)
        inputDict = ["Laptop" : EPSONINPUTS.Computer, "Document Camera" : EPSONINPUTS.DisplayPort, "Apple TV" : EPSONINPUTS.HDMI, "Blank Screen" : EPSONINPUTS.LAN]
        NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "refreshProjStatus", userInfo: nil, repeats: true)
        
        USBHelper.startInit(self)
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func refreshProjStatus() {
        PROJ1.refreshAllQueriesForReason(PJRefreshReason.Timed)
    }
    
    func makeEquivalent() {
        equivalentQueue = false
        if let input = inputDict[Statuses[1]]?.hashValue {
            PROJ1.requestInputChangeToInputIndex(UInt(input))
            equivalentQueue = true
        } else {
            PROJ1.requestPowerStateChange(false)
            //this hasnt failed on first run yet, setting equivalent to true may cause problems here
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
    
    //USB Channel
    @objc func connected(connectionOn:Bool){
        if connectionOn {
            Statuses[0] = "Connected"
        }
        else {
            let projStatus = Statuses[7..<(Statuses.count)]
            Statuses = ["Not Connected", "", "", "", "", "", ""]
            Statuses! += Array(projStatus)
        }
        table.reloadData()
    }
    
    @objc func recievedP1source(source:String){
        //make enum with proj inputs from epson and hp and request change
        Statuses[1] = source
        if PROJ1.powerStatus != PJPowerStatus.PJPowerStatusLampOn {
            equivalentQueue = true
        }
        if (source == "OFF") {
            PROJ1.requestPowerStateChange(false)
        }
        else {
            PROJ1.requestPowerStateChange(true)
            let inputDict = ["Laptop" : EPSONINPUTS.Computer, "Document Camera" : EPSONINPUTS.DisplayPort, "Apple TV" : EPSONINPUTS.HDMI, "Blank Screen" : EPSONINPUTS.LAN]
            PROJ1.requestInputChangeToInputIndex(UInt(inputDict[source]!.hashValue))
        }
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
        Statuses[9] = "\(PROJ1.activeInputIndex)" //need to find out what numbers correspond to inputs on different projs
        table.reloadData()
        
        if equivalentQueue {
            makeEquivalent()
        }
    }
    
    func projConnectionChange(notification:NSNotification) {
        //reload tabledata that deals with connection
        Statuses[7] = PJProjector.stringForConnectionState(PROJ1.connectionState)
        table.reloadData()
    }

}

