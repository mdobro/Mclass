//
//  ViewController.swift
//  Mclass
//
//  Created by Mike Dobrowolski on 5/22/15.
//  Copyright (c) 2015 CAENiOS. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, PTChannelDelegate, SettingsViewControllerDelegate, SubMainDelegate, MainTableViewDelegate {
    
    var queuedMessages:[(String, Int)] = []
    weak var serverChannel_:PTChannel!
    weak var peerChannel_:PTChannel!
    
    @IBOutlet weak var settingsBarButton: UIBarButtonItem!
    @IBOutlet weak var problemBarButton: UIBarButtonItem!
    @IBOutlet weak var subMainContainer: UIView!
    
    var SettingsHDCPon = false
    var subMainSettings:(projector:Bool!, volume: Int!) = (false,0)
    var camViewSettings:(paused:Bool!, timeElapsed: Int!, timeRemaining: Int!) = (false,0,0)

    override func viewDidLoad() {

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "Bar"), forBarMetrics:.Default)
        self.navigationController?.navigationBar.tintColor = UIColor.yellowColor()
        
        let buttonDict = [NSFontAttributeName: UIFont(name: "Arial", size: 30)!]
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes(buttonDict, forState: UIControlState.Normal)
        
        let negSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        negSpace.width = -15
        self.navigationItem.leftBarButtonItems?.insert(negSpace, atIndex: 0)
        
        //peertalk
        let channel:PTChannel! = PTChannel(delegate: self)
        let loopback:in_addr_t = 2130706433 //int representation of 127.0.0.1
        channel.listenOnPort(2345, IPv4Address: loopback, callback: { (error:NSError!) -> Void in
            if error != nil {
                println("Failed to listen on 127.0.0.1")
            }
            else {
                println("Listening on 127.0.0.1")
                self.serverChannel_ = channel
            }
        })
        lockScreen(true)
    }
    
    @IBAction func ProblemBarButtonTap(sender: UIBarButtonItem) {
        //Sets back button size and title for HelpViewController scene
        let backBarButton = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: nil)
        let buttonDict = [NSFontAttributeName: UIFont(name: "Arial", size: 30)!]
        backBarButton.setTitleTextAttributes(buttonDict, forState: UIControlState.Normal)
        self.navigationItem.backBarButtonItem = backBarButton
        
        //presents HelpViewController
        let storyboard = UIStoryboard(name: "Help", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("HelpViewController") as! UIViewController
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
        }
        else if segue.identifier == "mainTableLoad" {
            let dest = segue.destinationViewController as! MainTableViewController
            dest.delegate = self
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func lockScreen(connected: Bool){
        if connected {
            let alert = UIAlertController(title: "CONNECTION LOST!", message: "For help please contact CAEN:\n\nPhone: (734)-764-CAEN\nEmail: caen@umich.edu", preferredStyle: UIAlertControllerStyle.Alert)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }

    }
    
//MainTableViewDelegate Functions
    func projDidChange(projector:Int, source: String) {
        if projector == 1 {
            if peerChannel_ != nil {
                sendMessage(source, type: UInt32(Projector1))
            } else {
                let message = (source, Projector1)
                queuedMessages.append(message)
            }
        }
        if projector == 2 {
            if peerChannel_ != nil {
                sendMessage(source, type: UInt32(Projector2))
            } else {
                let message = (source, Projector2)
                queuedMessages.append(message)
            }
        }
    }
    
//SubMainDelegate functions
    func camViewDidChange(sender: CamView, settings: (paused: Bool!, timeElapsed: Int!, timeRemaining: Int!)) {
        camViewSettings = settings
    }
    func subMainDidChange(sender: SubMainViewController, settings: (projector: Bool!, volume: Int!)) {
        subMainSettings = settings
        if settings.projector! {
            //sendMessage("Projector On")
        }
        else {
            //sendMessage("Projector Off")
        }
    }
    
//SettingsViewControllerDelegate functions
    func HDCPDidChange(controller: SettingsViewController, on: Bool) {
        SettingsHDCPon = on
    }
    
//Functions for commuication with Mac
    func sendMessage(message: String!, type:UInt32){
        if peerChannel_ != nil {
            let payload = DispatchDataWithString(message)
            peerChannel_.sendFrameOfType(type, tag: 0, withPayload: payload, callback: { (error:NSError!) -> Void in
                if error != nil {
                    println("Failed to send message. Error: \(error)")
                }
                else {
                    println("iPad sent message: \(message)")
                }
            })
        }
        else {
            println("Mac is not connected - Unable to send message: \(message)")
        }
    }
    
    func sendDeviceInfo() {
        if (peerChannel_ == nil) {
            return;
        }
    
        print("Sending device info over ")
        println(peerChannel_)
        
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
                println(error)
            }
        }
    }
    
    func sendQueuedMessages(messages:[(String, Int)]){
        for item in messages {
            sendMessage(item.0, type: UInt32(item.1))
        }
    }
    
//PTChannelDelegate functions
    func ioFrameChannel(channel: PTChannel!, shouldAcceptFrameOfType type: UInt32, tag: UInt32, payloadSize: UInt32) -> Bool {
        if (channel != peerChannel_) {
            // A previous channel that has been canceled but not yet ended. Ignore.
            return false
        } else if (type != 101) {
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
        //println("Recieved frame of type", type, "with tag", tag, "with payload", payload)
        if type == 101 {
            let help:objChelper = objChelper()
            let message = help.helpioFrameChannel(channel, didReceiveFrameOfType: type, tag: tag, payload: payload, peerChannel: peerChannel_)
            println("iPad recieved message: \(message)")
        }
    }
    
    func ioFrameChannel(channel: PTChannel!, didEndWithError error: NSError!) {
        let help = objChelper()
        help.helpioFrameChannel(channel, didEndWithError: error)
        lockScreen(true)
        
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
        println(address)
        // Send some information about ourselves to the other end
        sendDeviceInfo()
        sendQueuedMessages(queuedMessages)
        lockScreen(false)
    }
}

