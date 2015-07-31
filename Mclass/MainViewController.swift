//
//  ViewController.swift
//  Mclass
//
//  Created by Mike Dobrowolski on 5/22/15.
//  Copyright (c) 2015 CAENiOS. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, PTChannelDelegate, SettingsViewControllerDelegate, SubMainDelegate, MainTableViewDelegate, HelpTableDelegate {
    var CLASSNAME:String!
    var tableViewController:MainTableViewController!
    
    weak var serverChannel_:PTChannel!
    weak var peerChannel_:PTChannel!
    
    @IBOutlet weak var settingsBarButton: UIBarButtonItem!
    @IBOutlet weak var problemBarButton: UIBarButtonItem!
    @IBOutlet weak var subMainContainer: UIView!
    
    var SettingsHDCPon = false
    var camViewSettings:(paused:Bool!, timeElapsed: Int!, timeRemaining: Int!) = (false,0,0)
    var proj1source:String! = "Something went wrong"
    var proj2source:String?
    var proj3source:String?
    var proj4source:String?
    var helpMessage:String! = ""
    var nowOrLater:String! = ""
    var sourceVol:String! = "0.0"
    

    override func viewDidLoad() {
        let background = UIImage(named: "background.jpg")
        self.view.backgroundColor = UIColor(patternImage: background!)

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "Bar"), forBarMetrics:.Default)
        self.navigationController?.navigationBar.tintColor = UIColor.yellowColor()
        
        let buttonDict = [NSFontAttributeName: UIFont(name: "Arial", size: 30)!]
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes(buttonDict, forState: UIControlState.Normal)
        
        let negSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        negSpace.width = -15
        self.navigationItem.leftBarButtonItems?.insert(negSpace, atIndex: 0)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appWillBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil)
        appWillBecomeActive(nil)
        
    }
    
    func appWillBecomeActive(notification: NSNotification?) {
        //peertalk
        let channel:PTChannel! = PTChannel(delegate: self)
        let loopback:in_addr_t = 2130706433 //int representation of 127.0.0.1
        channel.listenOnPort(in_port_t(PTProtocolIPv4PortNumber), IPv4Address: loopback, callback: { (error:NSError!) -> Void in
            if error != nil {
                print("Failed to listen on 127.0.0.1", true)
            }
            else {
                print("Listening on 127.0.0.1", true)
                self.serverChannel_ = channel
            }
        })
        lockScreen("present-Connection")
    }
    
    @IBAction func ProblemBarButtonTap(sender: UIBarButtonItem) {
        //Sets back button size and title for HelpViewController scene
        let backBarButton = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: nil)
        let buttonDict = [NSFontAttributeName: UIFont(name: "Arial", size: 30)!]
        backBarButton.setTitleTextAttributes(buttonDict, forState: UIControlState.Normal)
        self.navigationItem.backBarButtonItem = backBarButton
        
        //presents HelpViewController
        let storyboard = UIStoryboard(name: "Help", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("HelpViewController") as! HelpViewController
        controller.delegate = self
        self.navigationController!.pushViewController(controller, animated: true)
    }

   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "settingsPopover" {
            let dest = segue.destinationViewController as! SettingsViewController
            dest.delegate = self
        }
        else if segue.identifier == "subMainLoad" {
            let dest = segue.destinationViewController as! SubMainViewController
            dest.delegate = self
            dest.view.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.75) // only set background alpha to allow camView to be solid
        }
        else if segue.identifier == "mainTableLoad" {
            let dest = segue.destinationViewController as! MainTableViewController
            dest.delegate = self
            tableViewController = dest
            dest.view.alpha = 0.75 // set entire view's alpha because we want the cells and all to be opaque

        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func lockScreen(action: String){
        if action == "present-Connection" {
            let alert = UIAlertController(title: "CONNECTION LOST!", message: "For help please contact CAEN:\n\nPhone: (734)-764-CAEN\nEmail: caen@umich.edu", preferredStyle: UIAlertControllerStyle.Alert)
            self.presentViewController(alert, animated: true, completion: nil)
        } else if action == "dismiss" || action == "errorsClear"{
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            self.dismissViewControllerAnimated(false, completion: { _ in
                let alert = UIAlertController(title: "PROJECTOR \(action)ERROR!", message: "For help please contact CAEN:\n\nPhone: (734)-764-CAEN\nEmail: caen@umich.edu", preferredStyle: UIAlertControllerStyle.Alert)
                self.presentViewController(alert, animated: true, completion: nil)
            })
            let alert = UIAlertController(title: "PROJECTOR \(action)ERROR!", message: "For help please contact CAEN:\n\nPhone: (734)-764-CAEN\nEmail: caen@umich.edu", preferredStyle: UIAlertControllerStyle.Alert)
            self.presentViewController(alert, animated: true, completion: nil)
        }

    }
    
    func promptUserForClassRoomName() {
        let alert = UIAlertController(title: "Please enter a classroom name", message: "This should be entered by CAEN staff only!\nFor help please contact CAEN:\n\nPhone: (734)-764-CAEN\nEmail: caen@umich.edu", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) in
            textField.text = "For use by CAEN staff only!"
        })
        alert.addAction(UIAlertAction(title: "Enter", style: .Default, handler: { _ in
            //when enter is pressed the textField is sent to mac to try to find room ips
            let textField = alert.textFields![0] as UITextField
            self.sendMessage(textField.text!.uppercaseString, type: UInt32(ClassName))
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
//HelpTableDelegate
    func sendProblem(igotaproblem: String) {
        if peerChannel_ != nil {
            sendMessage(igotaproblem, type: UInt32(Problem))
        }
        self.helpMessage = igotaproblem
    }
    
    func whenToSendHelp(when: String) {
        if peerChannel_ != nil {
            sendMessage(when, type: UInt32(ProblemRoom))
        }
        self.nowOrLater = when
    }
    
    
    
//MainTableViewDelegate Functions
    func projDidChange(projector:Int, source: String) {
        if projector == 1 {
            if peerChannel_ != nil {
                sendMessage(source, type: UInt32(Projector1))
            }
            self.proj1source = source
        }
        if projector == 2 {
            if peerChannel_ != nil {
                sendMessage(source, type: UInt32(Projector2))
            }
            self.proj2source = source
        }
        if projector == 3 {
            if peerChannel_ != nil {
                //need to create proj 3 tag
                sendMessage(source, type: UInt32(Projector3))
            }
            self.proj3source = source
        }
        if projector == 4 {
            if peerChannel_ != nil {
                //need to create proj 4 tag
                sendMessage(source, type: UInt32(Projector4))
            }
            self.proj4source = source
        }
    }
    
//SubMainDelegate functions
    func camViewDidChange(sender: CamView, settings: (paused: Bool!, timeElapsed: Int!, timeRemaining: Int!)) {
        self.camViewSettings = settings
    }
    func subMainDidChange(sender: SubMainViewController, volume: Int!) {
        sourceVol = String(stringInterpolationSegment: volume)
        sendMessage("\(sourceVol)", type: UInt32(SourceVolume))
        //possibly time / time remaining
    }
    
//SettingsViewControllerDelegate functions
    func HDCPDidChange(controller: SettingsViewController, on: Bool) {
        self.SettingsHDCPon = on
        if SettingsHDCPon {
            sendMessage("ON", type: UInt32(HDCP))
        }
        else {
            sendMessage("OFF", type: UInt32(HDCP))
        }
    }
    
//Functions for commuication with Mac
    func sendMessage(message: String!, type:UInt32){
        if peerChannel_ != nil {
            let payload = DispatchDataWithString(message)
            peerChannel_.sendFrameOfType(type, tag: 0, withPayload: payload, callback: { (error:NSError!) -> Void in
                if error != nil {
                    print("Failed to send message. Error: \(error)", true)
                }
                else {
                    print("iPad sent message: \(message) as frame type \(type)", true)
                }
            })
        }
        else {
            print("Mac is not connected - Unable to send message: \(message)", true)
        }
    }
    
    //this will be called when mac app starts to correctly populate table
    func macRequestedStatus() {
        sendMessage(proj1source, type: UInt32(Projector1))
        if proj2source != nil {
            sendMessage(proj2source, type: UInt32(Projector2))
        }
        if proj3source != nil {
            sendMessage(proj3source, type: UInt32(Projector3))
        }
        if proj4source != nil {
            sendMessage(proj4source, type: UInt32(Projector4))
        }
        sendMessage(nowOrLater, type: UInt32(ProblemRoom))
        sendMessage(helpMessage, type: UInt32(Problem))
        sendMessage(sourceVol, type: UInt32(SourceVolume))
        if SettingsHDCPon {
            sendMessage("ON", type: UInt32(HDCP))
        } else {
            sendMessage("OFF", type: UInt32(HDCP))
        }
    }
    
    func sendDeviceInfo() {
        if (peerChannel_ == nil) {
            return;
        }
    
        print("Sending device info over ")
        print(peerChannel_, appendNewline: true)
        
        let screen = UIScreen.mainScreen()
        let screenSize = screen.bounds.size;
        let screenSizeDict = CGSizeCreateDictionaryRepresentation(screenSize);
        let device = UIDevice.currentDevice()
        let info: [String: NSObject] = ["localizedModel": device.localizedModel, "multitasking supported": device.multitaskingSupported, "name": device.name, "orientation": (UIDeviceOrientationIsLandscape(device.orientation) ? "landscape" : "protrait"), "system name": device.systemName, "system version": device.systemVersion, "screen size": screenSizeDict, "screen scale": screen.scale]
        
        let info2 = info as NSDictionary
        let payload = info2.createReferencingDispatchData()
        peerChannel_.sendFrameOfType(100, tag: 0, withPayload: payload) { (error) -> Void in
            if error != nil {
                print("Failed to send Device Info")
                print(error, true)
            }
        }
    }
    
//PTChannelDelegate functions
    func ioFrameChannel(channel: PTChannel!, shouldAcceptFrameOfType type: UInt32, tag: UInt32, payloadSize: UInt32) -> Bool {
        if (channel != peerChannel_) {
            // A previous channel that has been canceled but not yet ended. Ignore.
            return false
        } else if (type != 101 && type != UInt32(ClassName)) {
            if(type != 102) {
                NSLog("Unexpected frame of type %u", type);
                channel.close()
                return false;
            }
        }
        return true;
    }
    
    //iPad recieves a message from Mac
    func ioFrameChannel(channel: PTChannel!, didReceiveFrameOfType type: UInt32, tag: UInt32, payload: PTData!) {
        //print("Recieved frame of \(type)", true)
        if type == 101 {
            let message = objChelper().helpioFrameChannel(channel, didReceiveFrameOfType: type, tag: tag, payload: payload, peerChannel: peerChannel_)
            print("iPad recieved projector error message: \(message)", true)
            lockScreen(message)
        } else if type == 109 {
            let message = objChelper().helpioFrameChannel(channel, didReceiveFrameOfType: type, tag: tag, payload: payload, peerChannel: peerChannel_)
            if message == "request" {
                print("iPad recieved request for classroom name")
                promptUserForClassRoomName()
            } else {
                tableViewController.tableSetup(message)
                macRequestedStatus()
            }
        }
    }
    
    func ioFrameChannel(channel: PTChannel!, didEndWithError error: NSError!) {
        let help = objChelper()
        help.helpioFrameChannel(channel, didEndWithError: error)
        lockScreen("present-Connection")
        
    }
    
    //invoked when a new connection is possible
    func ioFrameChannel(channel: PTChannel!, didAcceptConnection otherChannel: PTChannel!, fromAddress address: PTAddress!) {
        // Cancel any other connection. We are FIFO, so the last connection
        // established will cancel any previous connection and "take its place".
        if peerChannel_ != nil {
            peerChannel_.cancel()
        }
        
        // Weak pointer to current connection. Connection objects live by themselves
        // (owned by its parent dispatch queue) until they are closed.
        peerChannel_ = otherChannel;
        peerChannel_.userInfo = address;
        print("Connected to ")
        print(address, true)
        sendDeviceInfo()
        lockScreen("dismiss")
    }
}

