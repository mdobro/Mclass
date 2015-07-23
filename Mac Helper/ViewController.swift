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

enum AVINPUTS:Int {
    //make cases return input number on av controller
    case blankScreen = -1
}

@objc class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    let USBHelper = USBhelper()

    //Audio DSP
    var dspSocket: GCDAsyncSocket!
    var MUTESTATUS: Bool = true
    let DSPPORT:UInt16 = 23
    let DSPIP = "10.160.10.184"
    
    //AV Controller
    var avSocket: GCDAsyncSocket!
    var BLANKSTATUS = false
    let HTTPPORT:UInt16 = 80
    var avIP = "*Insert IP here*"
    let avDefaultInput = 0
    var inputDict:[String: EPSONINPUTS]! //need to change EPSONINPUTS
    
    //PJLink
    var PROJ1:PJProjector!
    var PROJ2:PJProjector!
    let PJLINKPORT = 4352
    let projDefaultInput:UInt = 0
    var equivalentQueue = false;
    
    let buttons = ["iPad Connection Status", "Projector 1 Source on iPad", "Projector 2 Source on iPad", "HDCP Status on iPad", "Problem Status on iPad", "Problem Message on iPad", "Source Volume on iPad", "",
        //Proj1 IP at Statuses[8]
        "Projector 1 IP (click to edit)", "Projector 1 Connection Status", "Projector 1 Name", "Projector 1 Manufacturer", "Projector 1 Product", "Projector 1 Power", "Projector 1 Input", "ERRORS [fan, lamp, temp, cover, filter, other]", "",
        //Proj2 IP at Statuses[17]
        "Projector 2 IP (click to edit)", "Projector 2 Connection Status", "Projector 2 Name", "Projector 2 Manufacturer", "Projector 2 Product", "Projector 2 Power", "Projector 2 Input", "ERRORS [fan, lamp, temp, cover, filter, other]",
        //end filler at Statuses[25]
        "" /*end filler line*/]
    var Statuses:[String]!
    
    
    @IBOutlet weak var table: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.table.gridStyleMask = NSTableViewGridLineStyle.SolidVerticalGridLineMask
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cellWasEdited:", name: NSControlTextDidEndEditingNotification, object: nil)
        
        NSURLProtocol.registerClass(PJURLProtocolRunLoop)
        Statuses = ["Not Connected", "", "", "", "", "", "", "",
            ""/* 8 */, "", "", "", "", "", "", "", "",
            ""/* 17*/, "", "", "", "", "", "", "", ""/*end filler line*/]
        
        //delete after testing
        Statuses[8] = "127.0.0.1"
        Statuses[17] = "10.160.10.242"
        //
        PROJ1 = PJProjector(host: Statuses[8], port: PJLINKPORT)
        PROJ2 = PJProjector(host: Statuses[17], port: PJLINKPORT)
        self.subToNotifications()
        PROJ1.refreshAllQueriesForReason(PJRefreshReason.ProjectorCreation)
        PROJ2.refreshAllQueriesForReason(PJRefreshReason.ProjectorCreation)
        
        //set dicts up to be based off manufactuer name
        inputDict = ["Laptop" : EPSONINPUTS.Computer, "Document Camera" : EPSONINPUTS.DisplayPort, "Apple TV" : EPSONINPUTS.HDMI, "Blank Screen" : EPSONINPUTS.LAN]
        NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "refreshProjStatus", userInfo: nil, repeats: true)
        
        
        USBHelper.startInit(self)
        
        //socket connection to AUDIO DSP
        do {
            dspSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
            try dspSocket.connectToHost(DSPIP, onPort: DSPPORT)
        }
        catch {
            print("error with dspSocket")
        }
        
        let data = "RECALL 0 PRESET 1001\n"
        dspSocket.writeData(data.dataUsingEncoding(NSUTF8StringEncoding)!, withTimeout: -1.0, tag: 0)
        dspSocket.readDataWithTimeout(-1.0, tag: 0)
        
        //socket AVController
        changeAVInput(avDefaultInput)
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
            if row == 8 || row == 17 {
                cell.textField!.editable = true
            }
            return cell
        }
        return nil
    }
    
    func cellWasEdited(notification: NSNotification) {
        let p1CellString = (table.viewAtColumn(1, row: 8, makeIfNecessary: false) as! NSTableCellView).textField!.stringValue
        let p2CellString = (table.viewAtColumn(1, row: 17, makeIfNecessary: false) as! NSTableCellView).textField!.stringValue

        
        if p1CellString != Statuses[8] {
            Statuses[8] = p1CellString
            PROJ1 = PJProjector(host: p1CellString)
            
        } else if p2CellString != Statuses[17] {
            Statuses[17] = p2CellString
            PROJ2 = PJProjector(host: p2CellString)
        }
    }
    
    //Socket check
    func socket(socket : GCDAsyncSocket, didReadData data:NSData, withTag tag:UInt16)
    {
        print("Received Response")
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
        table.reloadDataForRowIndexes(NSIndexSet(index: 0), columnIndexes: NSIndexSet(index: 1))
    }
    
    @objc func recievedP1source(source:String){
        Statuses[1] = source
        if PROJ1.powerStatus != PJPowerStatus.PJPowerStatusLampOn {
            equivalentQueue = true
        }
        if (source == "OFF") {
            PROJ1.requestPowerStateChange(false)
        }
        else {
            PROJ1.requestPowerStateChange(true)
            //PROJ1.requestInputChangeToInputIndex(UInt(inputDict[source]!.hashValue))
            changeAVInput(inputDict[source]!.hashValue)
        }
        table.reloadDataForRowIndexes(NSIndexSet(index: 1), columnIndexes: NSIndexSet(index: 1))
    }
    
    @objc func recievedP2source(source:String){
        Statuses[2] = source
        if PROJ2.powerStatus != PJPowerStatus.PJPowerStatusLampOn {
            equivalentQueue = true
        }
        if (source == "OFF") {
            PROJ2.requestPowerStateChange(false)
        }
        else {
            PROJ2.requestPowerStateChange(true)
            //PROJ2.requestInputChangeToInputIndex(UInt(inputDict[source]!.hashValue))
            //change AV input on proj 2 somehow
        }
        table.reloadDataForRowIndexes(NSIndexSet(index: 2), columnIndexes: NSIndexSet(index: 1))
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
        if (vol == "10000") {
            revised = "SET 1 FDRMUTE \"Program volume\" 1 0\n"
        }
        else if (vol == "-10000") {
            revised = "SET 1 FDRMUTE \"Program volume\" 1 1\n"
        }
        else {
            print(vol)
            revised = "SET 1 FDRLVL \"Program volume\" 1 \(vol)\n"
        }
        let data:NSData = revised.dataUsingEncoding(NSUTF8StringEncoding)!
        dspSocket.writeData(data, withTimeout: -1.0, tag: 0)
        dspSocket.readDataWithTimeout(-1.0, tag: 0)
        table.reloadData()
        
    }
    
    //Proj Send/Recieve
    
    func refreshProjStatus() {
        PROJ1.refreshAllQueriesForReason(.Timed)
        PROJ2.refreshAllQueriesForReason(.Timed)
    }
    
    func makeEquivalent() {
        equivalentQueue = false
        
        //if input is not off for proj 1...
        if let _ = inputDict[Statuses[1]]?.hashValue {
            PROJ1.requestPowerStateChange(true)
            PROJ1.requestInputChangeToInputIndex(projDefaultInput)
            //changeAVInput(input) //might have a bug where blank screen gets called twice and gets canceled
            equivalentQueue = true
        } else {
            PROJ1.requestPowerStateChange(false)
            //this hasnt failed on first run yet, setting equivalent to true may cause problems here
        }
        
        //if input is not off for proj 2...
        if let _ = inputDict[Statuses[2]]?.hashValue {
            PROJ2.requestPowerStateChange(true)
            PROJ2.requestInputChangeToInputIndex(projDefaultInput)
            //not really sure how to change av input # 2 with this. need to experiment
            equivalentQueue = true
        } else {
            PROJ2.requestPowerStateChange(false)
        }
        
    }
    
    func subToNotifications() {
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "projRequestBegin:", name: PJProjectorRequestDidBeginNotification, object: nil)
        center.addObserver(self, selector: "projRequestEnd:", name: PJProjectorRequestDidEndNotification, object: nil)
        center.addObserver(self, selector: "projDidChange:", name: PJProjectorDidChangeNotification, object: nil)
        center.addObserver(self, selector: "projConnectionChange:", name: PJProjectorConnectionStateDidChangeNotification, object: nil)
    }
    
    func unsubFromNotifications() {
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(self)
    }
    
    func projRequestBegin(notification:NSNotification) {
        //they just started a loading animation here
    }
    
    func projRequestEnd(notification:NSNotification) {
        //ended animation
    }
    
    func projHasWarning(notification: NSNotification) {
        //send warning to CAEN
    }
    
    func projHasError(index:Int) -> String! {
        //send error to iPad to lock it
        let error:String!
        switch index {
        case 0: error = "Fan"
        case 1: error = "Lamp"
        case 2: error = "Temperature"
        case 3: error = "Cover Open"
        case 4: error = "Filter"
        case 5: error = "Other"
        default: error = ""
        }
        //send error to CAEN
        return error;
    }
    
    func changeHelper(proj:PJProjector, index:Int) {
        Statuses[index] = proj.projectorName
        Statuses[index + 1] = proj.manufacturerName
        Statuses[index + 2] = proj.productName
        Statuses[index + 3] = PJResponseInfoPowerStatusQuery.stringForPowerStatus(proj.powerStatus)
        Statuses[index + 4] = "\(proj.activeInputIndex)"
        
        let Errors = [PJResponseInfoErrorStatusQuery.stringForErrorStatus(proj.fanErrorStatus),
            PJResponseInfoErrorStatusQuery.stringForErrorStatus(proj.lampErrorStatus),
            PJResponseInfoErrorStatusQuery.stringForErrorStatus(proj.temperatureErrorStatus),
            PJResponseInfoErrorStatusQuery.stringForErrorStatus(proj.coverOpenErrorStatus),
            PJResponseInfoErrorStatusQuery.stringForErrorStatus(proj.filterErrorStatus),
            PJResponseInfoErrorStatusQuery.stringForErrorStatus(proj.otherErrorStatus)]
        Statuses[index + 5] = ""
        var hasError = false
        var errorsToSend = ""
        
        for (i,error) in Errors.enumerate() {
            if error == "Error" {
                errorsToSend += projHasError(i) + " "
                hasError = true
            }
            Statuses[index + 5] += error
            if i != Errors.count - 1 {
                Statuses[index + 5] += ","
            }
        }
        if !hasError {
            USBHelper.sendMessage("errorsClear")
        } else {
            USBHelper.sendMessage(errorsToSend)
        }
        table.reloadDataForRowIndexes(NSIndexSet(indexesInRange: NSRange(index...(index + 6))), columnIndexes: NSIndexSet(index: 1))
        
        if equivalentQueue {
            makeEquivalent()
        }
   
    }
    
    func projDidChange(notification:NSNotification) {
        //reload tabledata that deals with button status etc
        let currentProj = notification.object as! PJProjector
        if currentProj.host == Statuses[8] {
            changeHelper(currentProj, index: 10)
         } else {
            changeHelper(currentProj, index: 19)
        }
    }
    
    func connectionHelper(proj:PJProjector, index:Int) {
        Statuses[index] = PJProjector.stringForConnectionState(proj.connectionState)
        if Statuses[index] == "Connecting" || Statuses[index] == "Connection Error"{
            for var i = index + 1; i < index + 8; ++i {
                Statuses[i] = ""
            }
        }
        table.reloadDataForRowIndexes(NSIndexSet(indexesInRange: NSRange(index...(index + 7))), columnIndexes: NSIndexSet(index: 1))
        
        if Statuses[index] == "Connected" {
            NSNotificationCenter.defaultCenter().postNotificationName(PJProjectorDidChangeNotification, object: proj)
            proj.refreshAllQueriesForReason(PJRefreshReason.ProjectorCreation)
        }

    }
    
    func projConnectionChange(notification:NSNotification) {
        //reload tabledata that deals with connection
        let currentProj = notification.object as! PJProjector
        if currentProj.host == Statuses[8] {
            //9 for proj1
            connectionHelper(currentProj, index: 9)
        }
        else {
            //18 for proj2
            connectionHelper(currentProj, index: 18)
        }
    }
    
    
    //AV CONTROLLER
    
    func changeAVInput(input:Int) {
        //socket connection to AV Controller
        //might have to try a new connection for every command
        do {
            avSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
            try avSocket.connectToHost(avIP, onPort: HTTPPORT)
        }
        catch {
            print("error with avSocket")
            //lockipad and retry until connected
        }
        let data:String!
        if input != -1 {
            //change input
            data = "GET /aj.shtml?a=SCAFUN&i=0&f=0&v=\(input)&_=1437409735732 HTTP/1.1\n"
            
        } else {
            //blank screen
            if BLANKSTATUS {
                data = "GET /aj.shtml?a=SCAFUN&i=0&f=127&v=0&_=1437417334157 HTTP/1.1\n"
            } else {
                data = "GET /aj.shtml?a=SCAFUN&i=0&f=127&v=1&_=1437417262858 HTTP/1.1\n"
            }
        }
        avSocket.writeData(data.dataUsingEncoding(NSUTF8StringEncoding)!, withTimeout: -1.0, tag: 0)
        avSocket.readDataWithTimeout(-1.0, tag: 0)
    }
    
    func changeAVHDCP(action:Bool) {
        //need to find http commands for this depending on current input
    }
}