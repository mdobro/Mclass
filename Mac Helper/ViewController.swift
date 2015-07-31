//
//  ViewController.swift
//  Mac Helper
//
//  Created by Mike Dobrowolski on 6/10/15.
//  Copyright (c) 2015 CAENiOS. All rights reserved.
//

import Cocoa

@objc class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    //classroomIP help
    var CLASSROOMNAME:String?
    var IPDictionary:[String: String]? = nil
    
    //USB
    let USBHelper = USBhelper()

    //Audio DSP
    var dspSocket: GCDAsyncSocket!
    var MUTESTATUS: Bool = true
    let DSPPORT:UInt16 = 23
    var DSPIP = "*"
    
    //AV Controller
    var avSocket: GCDAsyncUdpSocket!
    var BLANKSTATUS = false
    let AVPORT:UInt16 = 50000
    var avIP = "*"
    let avDefaultInput = 2
    var inputDict:[String: Int]!
    
    //PJLink
    var PROJ1:PJProjector!
    var PROJ2:PJProjector!
    var PROJ3:PJProjector!
    var PROJ4:PJProjector!
    let PJLINKPORT = 4352
    let projDefaultInput:UInt = 0
    var equivalentQueue = false;
    
    var buttons = ["iPad Connection Status", "Projector 1 Source on iPad", "Projector 2 Source on iPad", "Projector 3 Source on iPad", "Projector 4 Source on iPad", "HDCP Status on iPad", "Problem Status on iPad", "Problem Message on iPad", "Source Volume on iPad", ""]
    var Statuses:[String]!
    
    
    @IBOutlet weak var table: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.table.gridStyleMask = NSTableViewGridLineStyle.SolidVerticalGridLineMask
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cellWasEdited:", name: NSControlTextDidEndEditingNotification, object: nil)
        
        NSURLProtocol.registerClass(PJURLProtocolRunLoop)
        
        Statuses = ["Not Connected", "", "", "", "", "", "", "", "", "",
            "*"/* 10 */, "", "", "", "", "", "", "", "",
            "*"/* 19 */, "", "", "", "", "", "", "", "",
            "*"/* 28 */, "", "", "", "", "", "", "", "",
            "*"/* 37 */, "", "", "", "", "", "", "", ""/*end filler line*/]
        
        USBHelper.startInit(self)
        
        //uncomment to erase stored room value
        //NSUserDefaults.standardUserDefaults().removeObjectForKey("currentRoom")
    }
    
    func setupIPs() {
        self.USBHelper.sendMessage(CLASSROOMNAME, ofType: CInt(ClassName))
        self.subToNotifications()
        
        if (IPDictionary!.count - 2) == 1 {
            
            Statuses[10] = IPDictionary!["Projector1"]!
            
            PROJ1 = PJProjector(host: Statuses[10], port: PJLINKPORT)
            PROJ1.refreshAllQueriesForReason(PJRefreshReason.ProjectorCreation)
            PROJ1.refreshTimerOn = true
            
        }
        
        else if (IPDictionary!.count - 2) == 2 {
        
            Statuses[10] = IPDictionary!["Projector1"]!
            Statuses[19] = IPDictionary!["Projector2"]!
        
            PROJ1 = PJProjector(host: Statuses[10], port: PJLINKPORT)
            PROJ2 = PJProjector(host: Statuses[19], port: PJLINKPORT)
            PROJ1.refreshAllQueriesForReason(PJRefreshReason.ProjectorCreation)
            PROJ2.refreshAllQueriesForReason(PJRefreshReason.ProjectorCreation)
            PROJ1.refreshTimerOn = true
            PROJ2.refreshTimerOn = true
            
        }
        
        else if (IPDictionary!.count - 2) == 3 {
            
            Statuses[10] = IPDictionary!["Projector1"]!
            Statuses[19] = IPDictionary!["Projector2"]!
            Statuses[28] = IPDictionary!["Projector3"]!
            
            PROJ1 = PJProjector(host: Statuses[10], port: PJLINKPORT)
            PROJ2 = PJProjector(host: Statuses[19], port: PJLINKPORT)
            PROJ3 = PJProjector(host: Statuses[28], port: PJLINKPORT)
            PROJ1.refreshAllQueriesForReason(PJRefreshReason.ProjectorCreation)
            PROJ2.refreshAllQueriesForReason(PJRefreshReason.ProjectorCreation)
            PROJ3.refreshAllQueriesForReason(PJRefreshReason.ProjectorCreation)
            PROJ1.refreshTimerOn = true
            PROJ2.refreshTimerOn = true
            PROJ3.refreshTimerOn = true

            
        }
        
        else {
            
            Statuses[10] = IPDictionary!["Projector1"]!
            Statuses[19] = IPDictionary!["Projector2"]!
            Statuses[28] = IPDictionary!["Projector3"]!
            Statuses[37] = IPDictionary!["Projector4"]!
            
            PROJ1 = PJProjector(host: Statuses[10], port: PJLINKPORT)
            PROJ2 = PJProjector(host: Statuses[19], port: PJLINKPORT)
            PROJ3 = PJProjector(host: Statuses[28], port: PJLINKPORT)
            PROJ4 = PJProjector(host: Statuses[37], port: PJLINKPORT)
            PROJ1.refreshAllQueriesForReason(PJRefreshReason.ProjectorCreation)
            PROJ2.refreshAllQueriesForReason(PJRefreshReason.ProjectorCreation)
            PROJ3.refreshAllQueriesForReason(PJRefreshReason.ProjectorCreation)
            PROJ4.refreshAllQueriesForReason(PJRefreshReason.ProjectorCreation)
            PROJ1.refreshTimerOn = true
            PROJ2.refreshTimerOn = true
            PROJ3.refreshTimerOn = true
            PROJ4.refreshTimerOn = true

            
        }
        
        for i in 1...IPDictionary!.count-2 {
            buttons += ["Projector \(i) IP (click to edit)", "Projector \(i) Connection Status", "Projector \(i) Name", "Projector \(i) Manufacturer", "Projector \(i) Product", "Projector \(i) Power", "Projector \(i) Input", "ERRORS [fan, lamp, temp, cover, filter, other]", ""]
        }
        
        //set dicts up to be based off manufactuer name
        inputDict = ["Laptop" : 2, "Document Camera" : 3, "Apple TV" : 1, "Blank Screen" : -1]//hdmi inputs start at 0
        
        //socket connection to AUDIO DSP
        DSPIP = IPDictionary!["Audio"]!
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
        avSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        avIP = IPDictionary!["AV"]!
        changeAVInput(avDefaultInput)
    }
    
    func findRoomIPs(name:String) -> [String:String]? {
        if let classListPath =  NSBundle.mainBundle().pathForResource("CAENClassroomIPList", ofType: "txt") {
            let reader = StreamReader(path: classListPath)
            while let line = reader?.nextLine() {
                if Array(arrayLiteral: line)[0] == "#" {
                    continue
                } else if line == name {
                    var list:[String] = []
                    while let ips = reader?.nextLine() {
                        if ips == "#" {
                            break
                        } else if Array(arrayLiteral: ips)[0] == "*" {
                            list.append("*")
                        } else {
                            list.append(ips)
                        }
                    } // while
                    
                    //now make array into dictionary
                    var dictionary = ["AV" : list[0], "Audio" : list[1]]
                    for i in 2..<list.count {
                        let proj = "Projector\((i - 1))"
                        dictionary[proj] = list[i]
                    }
                    return dictionary
                } // else if
            } // while
        } else {
            print("Classroom file not found!")
        }
        return nil
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
    
    //Socket check
    func socket(socket : GCDAsyncSocket, didReadData data:NSData, withTag tag:UInt16)
    {
        print("Received Response")
    }
    
    //USB Channel
    
    
    @objc func connected(connectionOn:Bool){
        if connectionOn {
            Statuses[0] = "Connected"
            
            //gathers necessary IP addresses
            let defaults = NSUserDefaults.standardUserDefaults()
            if let name = defaults.stringForKey("currentRoom") {
                self.CLASSROOMNAME = name
                IPDictionary = self.findRoomIPs(name)
                self.setupIPs()
            } else {
                self.USBHelper.sendMessage("request", ofType: CInt(ClassName))
            }
            table.reloadDataForRowIndexes(NSIndexSet(indexesInRange: NSRange(0...9)), columnIndexes: NSIndexSet(index: 1))
        }
        else {
            buttons = ["iPad Connection Status", "Projector 1 Source on iPad", "Projector 2 Source on iPad", "Projector 3 Source on iPad", "Projector 4 Source on iPad", "HDCP Status on iPad", "Problem Status on iPad", "Problem Message on iPad", "Source Volume on iPad", ""]
            Statuses = ["Not Connected", "", "", "", "", "", "", "", "", "",
                "*"/* 10 */, "", "", "", "", "", "", "", "",
                "*"/* 19 */, "", "", "", "", "", "", "", "",
                "*"/* 28 */, "", "", "", "", "", "", "", "",
                "*"/* 37 */, "", "", "", "", "", "", "", ""/*end filler line*/]
            table.reloadData()
        }
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
            //PROJ1.requestInputChangeToInputIndex(UInt(inputDict[source]!))
            changeAVInput(inputDict[source]!)
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
            //change AV input on proj 2 somehow
        }
        table.reloadDataForRowIndexes(NSIndexSet(index: 2), columnIndexes: NSIndexSet(index: 1))
    }
    
    @objc func recievedP3source(source:String) {
        Statuses[3] = source
        if PROJ3.powerStatus != PJPowerStatus.PJPowerStatusLampOn {
            equivalentQueue = true
        }
        if (source == "OFF") {
            PROJ3.requestPowerStateChange(false)
        }
        else {
            PROJ3.requestPowerStateChange(true)
            //change AV input on proj 3 somehow
        }
        table.reloadDataForRowIndexes(NSIndexSet(index: 3), columnIndexes: NSIndexSet(index: 1))
    }
    
    @objc func recievedP4source(source:String) {
        Statuses[4] = source
        if PROJ4.powerStatus != PJPowerStatus.PJPowerStatusLampOn {
            equivalentQueue = true
        }
        if (source == "OFF") {
            PROJ4.requestPowerStateChange(false)
        }
        else {
            PROJ4.requestPowerStateChange(true)
            //change AV input on proj 4 somehow
        }
        table.reloadDataForRowIndexes(NSIndexSet(index: 4), columnIndexes: NSIndexSet(index: 1))
    }
    
    @objc func recievedHDCPchange(switchOn:String){
        Statuses[5] = switchOn
        
        table.reloadData()
    }
    
    @objc func recievedProblemRoom(nowOrLater:String) {
        Statuses[6] = nowOrLater
        table.reloadData()
    }
    
    @objc func recievedProblem(problem:String){
        Statuses[7] = problem
        table.reloadData()
    }
    
    @objc func recievedVolume(vol:String) {
        Statuses[8] = vol
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
    
    @objc func recievedClassName(name:String) {
        IPDictionary = findRoomIPs(name)
        if IPDictionary == nil {
            //ask proj for another name if we get a nil dictionary
            print("Room name not found in list!")
            self.USBHelper.sendMessage("request", ofType: CInt(ClassName))
        } else {
            //write this class name
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(name, forKey: "currentRoom")
            self.CLASSROOMNAME = name
            self.setupIPs()
        }
    }
    
    //Proj Send/Recieve
    func makeEquivalent() {
        equivalentQueue = false
        
        //if input is not off for proj 1...
        if let _ = inputDict[Statuses[1]] {
            PROJ1.requestPowerStateChange(true)
            PROJ1.requestInputChangeToInputIndex(projDefaultInput)
            equivalentQueue = true
        } else {
            PROJ1.requestPowerStateChange(false)
            //this hasnt failed on first run yet, setting equivalent to true may cause problems here
        }
        
        //if input is not off for proj 2...
        if let _ = inputDict[Statuses[2]] {
            PROJ2.requestPowerStateChange(true)
            PROJ2.requestInputChangeToInputIndex(projDefaultInput)
            //not really sure how to change av input # 2 with this. need to experiment
            equivalentQueue = true
        } else {
            PROJ2.requestPowerStateChange(false)
        }
        
        //if input is not off for proj 3...
        if let _ = inputDict[Statuses[3]] {
            PROJ3.requestPowerStateChange(true)
            PROJ3.requestInputChangeToInputIndex(projDefaultInput)
            equivalentQueue = true
        } else {
            PROJ3.requestPowerStateChange(false)
        }
        
        //if input is not off for proj 4...
        if let _ = inputDict[Statuses[4]] {
            PROJ4.requestPowerStateChange(true)
            PROJ4.requestInputChangeToInputIndex(projDefaultInput)
            equivalentQueue = true
        } else {
            PROJ4.requestPowerStateChange(false)
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
        //index is proj name of given projector
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
            if proj.PJProjectorHasErrors {
                self.USBHelper.sendMessage("errorsClear", ofType: CInt(Problem))
                proj.PJProjectorHasErrors = false
            }
        } else {
            self.USBHelper.sendMessage(errorsToSend, ofType: CInt(Problem))
            proj.PJProjectorHasErrors = true
        }
        table.reloadDataForRowIndexes(NSIndexSet(indexesInRange: NSRange(index...(index + 6))), columnIndexes: NSIndexSet(index: 1))
        
        if equivalentQueue {
            makeEquivalent()
        }
   
    }
    
    func projDidChange(notification:NSNotification) {
        //reload tabledata that deals with button status etc
        let currentProj = notification.object as! PJProjector
        if currentProj.host == Statuses[10] {
            changeHelper(currentProj, index: 12)
        } else if currentProj.host == Statuses[19] {
            changeHelper(currentProj, index: 21)
        } else if currentProj.host == Statuses[28] {
            changeHelper(currentProj, index: 30)
        } else {
            changeHelper(currentProj, index: 39)
        }
    }
    
    func connectionHelper(proj:PJProjector, index:Int) {
        //index is connection status of given proj
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
        if currentProj.host == Statuses[10] {
            connectionHelper(currentProj, index: 11)
        } else if currentProj.host == Statuses[19] {
            connectionHelper(currentProj, index: 20)
        }else if currentProj.host == Statuses[28] {
            connectionHelper(currentProj, index: 29)
        } else {
            connectionHelper(currentProj, index: 38)
        }
    }
    
    //AV CONTROLLER
    
    func changeAVInput(input:Int) {
        let data:String!
        if input != -1 {
            //change input
            if BLANKSTATUS {
                //unblank screen if muted
                BLANKSTATUS = false
                let subdata = "#VMUTE 1,0\r"
                avSocket.sendData(subdata.dataUsingEncoding(NSUTF8StringEncoding)!, toHost: avIP, port: AVPORT, withTimeout: 2, tag: 0)
            }
            data = "#ROUTE 12,1,\(input)\r"
            
        } else {
            //blank screen
            data = "#VMUTE 1,1\r"
            BLANKSTATUS = true
        }
        avSocket.sendData(data.dataUsingEncoding(NSUTF8StringEncoding)!, toHost: avIP, port: AVPORT, withTimeout: 2, tag: 0)
    }
    
    func changeAVHDCP(action:Bool) {
        var data:String!
        if action {
            //turns HDCP ON
            data = "HDCP-MOD 0,2,1" //only turns on laptop input
        } else {
            //turns HDCP OFF
            data = "HDCP-MOD 0,2,0"
        }
        avSocket.sendData(data.dataUsingEncoding(NSUTF8StringEncoding)!, toHost: avIP, port: AVPORT, withTimeout: 2, tag: 0)

    }
}