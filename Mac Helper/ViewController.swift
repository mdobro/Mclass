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

    var socket: GCDAsyncSocket!
    var MUTESTATUS: Bool!
    let TESIRAPORT:UInt16 = 32
    
    var PROJ1:PJProjector!
    //let EPSONTESTIP = "10.160.10.242"
    var PROJ1IP = "127.0.0.1" //default IP; repetative with statuses[8], delete after testing period
    let PJLINKPORT = 4352
    var inputDict:[String: EPSONINPUTS]!
    var equivalentQueue = false;
    
    let buttons = ["iPad Connection Status", "Projector 1 Source on iPad", "Projector 2 Source on iPad", "HDCP Status on iPad", "Problem Status on iPad", "Problem Message on iPad", "Source Volume on iPad", "", "Projector 1 IP (`click to edit)", "Projector 1 Connection Status", "Projector 1 Name", "Projector 1 Manufacturer", "Projector 1 Product", "Projector 1 Power", "Projector 1 Input", "ERRORS [fan, lamp, temp, cover, filter, other]", "" /*end filler line*/]
    //Proj1 connection at Statuses[8]
    var Statuses:[String]!
    
    @IBOutlet weak var table: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.table.gridStyleMask = NSTableViewGridLineStyle.SolidVerticalGridLineMask
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cellWasEdited:", name: NSControlTextDidEndEditingNotification, object: nil)
        
        NSURLProtocol.registerClass(PJURLProtocolRunLoop)
        PROJ1 = PJProjector(host: PROJ1IP, port: PJLINKPORT)
        Statuses = ["Not Connected", "", "", "", "", "", "", "", "\(PROJ1IP)", "", "", "", "", "", "", "", ""/*end filler line*/]
        self.subToNotifications()
        PROJ1.refreshAllQueriesForReason(PJRefreshReason.ProjectorCreation)
        inputDict = ["Laptop" : EPSONINPUTS.Computer, "Document Camera" : EPSONINPUTS.DisplayPort, "Apple TV" : EPSONINPUTS.HDMI, "Blank Screen" : EPSONINPUTS.LAN]
        NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "refreshProjStatus", userInfo: nil, repeats: true)
        
        USBHelper.startInit(self)
        
        // Do any additional setup after loading the view.
        socket = GCDAsyncSocket(delegate: AppDelegate.self, delegateQueue: dispatch_get_main_queue())
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
            if row == 8 {
                cell.textField!.editable = true
            }
            return cell
        }
        return nil
    }
    
    func cellWasEdited(notification: NSNotification) {
        let p1celltext = (table.viewAtColumn(1, row: 8, makeIfNecessary: false) as! NSTableCellView).textField!.stringValue
        if p1celltext != Statuses[8] {
            Statuses[8] = p1celltext
            PROJ1IP = p1celltext
            PROJ1 = PJProjector(host: PROJ1IP, port: PJLINKPORT)
        }
        
    }
    
    //USB Channel
    @objc func connected(connectionOn:Bool){
        if connectionOn {
            Statuses[0] = "Connected"
        }
        else {
            let projStatus = Statuses[8..<(Statuses.count)]
            Statuses = ["Not Connected", "", "", "", "", "", "", ""]
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
        var revised: String!
        if (vol == "0.0") {
            MUTESTATUS = true
        }
        else {
            var finalstep: String!
            if (MUTESTATUS != nil) {
                if (MUTESTATUS == true) {
                    let unmute = "\"ProgramVolume\" set mute 1 false"
                    print(unmute)
                    socket.writeData(unmute.dataUsingEncoding(NSUTF8StringEncoding), withTimeout: -1.0, tag: 0)
                }
            }
            MUTESTATUS = false
            let stepone: Int = Int(round(Double(vol)!*52 + (-40)))
            if (stepone > -1 && stepone < 10) {
                finalstep = "0" + String(stepone)
            }
            else if (stepone > -10 && stepone < 0) {
                finalstep = "-0" + String(-stepone)
            }
            else {
                finalstep = String(stepone)
            }
            revised = "\"ProgramVolume\" set level 1 \(finalstep)"
            print(revised)
            
        }
        if (MUTESTATUS! == true) {
            revised = "\"ProgramVolume\" set mute 1 true"
            print(revised)
        }
        let data:NSData = revised.dataUsingEncoding(NSUTF8StringEncoding)!
        socket.writeData(data, withTimeout: -1.0, tag: 0)
        socket.readDataWithTimeout(-1.0, tag: 0)
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
        Statuses[10] = PROJ1.projectorName
        Statuses[11] = PROJ1.manufacturerName
        Statuses[12] = PROJ1.productName
        Statuses[13] = PJResponseInfoPowerStatusQuery.stringForPowerStatus(PROJ1.powerStatus)
        Statuses[14] = "\(PROJ1.activeInputIndex)"
        
        let Errors = [PJResponseInfoErrorStatusQuery.stringForErrorStatus(PROJ1.fanErrorStatus),
        PJResponseInfoErrorStatusQuery.stringForErrorStatus(PROJ1.lampErrorStatus),
        PJResponseInfoErrorStatusQuery.stringForErrorStatus(PROJ1.temperatureErrorStatus),
        PJResponseInfoErrorStatusQuery.stringForErrorStatus(PROJ1.coverOpenErrorStatus),
        PJResponseInfoErrorStatusQuery.stringForErrorStatus(PROJ1.filterErrorStatus),
            PJResponseInfoErrorStatusQuery.stringForErrorStatus(PROJ1.otherErrorStatus)]
        Statuses[15] = ""
        for (index,error) in Errors.enumerate() {
            Statuses[15] += error
            if index != Errors.count - 1 {
                Statuses[15] += ","
            }
        }
        
        table.reloadDataForRowIndexes(NSIndexSet(indexesInRange: NSRange(10..<(Statuses.count))), columnIndexes: NSIndexSet(index: 1))
        
        if equivalentQueue {
            makeEquivalent()
        }
    }
    
    func projConnectionChange(notification:NSNotification) {
        //reload tabledata that deals with connection
        Statuses[9] = PJProjector.stringForConnectionState(PROJ1.connectionState)
        if Statuses[9] == "Connecting" || Statuses[9] == "Connection Error"{
            for var i = 10; i < Statuses.count; ++i {
                Statuses[i] = ""
            }
        }
        table.reloadDataForRowIndexes(NSIndexSet(indexesInRange: NSRange(9..<(Statuses.count))), columnIndexes: NSIndexSet(index: 1))
        
        if Statuses[9] == "Connected" {
            NSNotificationCenter.defaultCenter().postNotificationName(PJProjectorDidChangeNotification, object: nil)
            PROJ1.refreshAllQueriesForReason(PJRefreshReason.ProjectorCreation)
        }
    }

}

