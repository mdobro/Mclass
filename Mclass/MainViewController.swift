//
//  ViewController.swift
//  Mclass
//
//  Created by Mike Dobrowolski on 5/22/15.
//  Copyright (c) 2015 CAENiOS. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, PTChannelDelegate, SettingsViewControllerDelegate {
    
    weak var serverChannel_:PTChannel!
    weak var peerChannel_:PTChannel!
    
    @IBOutlet weak var settingsBarButton: UIBarButtonItem!
    @IBOutlet weak var problemBarButton: UIBarButtonItem!
    
    var SettingsHDCPon = false
    
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
        let loopback:in_addr_t = 2130706433
        channel.listenOnPort(2345, IPv4Address: loopback, callback: { (error:NSError!) -> Void in
            if error != nil {
                println("Failed to listen on 127.0.0.1")
            }
            else {
                println("Listening on 127.0.0.1")
                self.serverChannel_ = channel
            }
        })
    }
    
    //Functions for com with Mac
    /*
    (void)appendOutputMessage:(NSString*)message {
    NSLog(@">> %@", message);
    NSString *text = self.outputTextView.text;
    if (text.length == 0) {
    self.outputTextView.text = [text stringByAppendingString:message];
    } else {
    self.outputTextView.text = [text stringByAppendingFormat:@"\n%@", message];
    [self.outputTextView scrollRangeToVisible:NSMakeRange(self.outputTextView.text.length, 0)];
    }
    }
    
    - (void)sendMessage:(NSString*)message {
    if (peerChannel_) {
    dispatch_data_t payload = PTExampleTextDispatchDataWithString(message);
    [peerChannel_ sendFrameOfType:PTExampleFrameTypeTextMessage tag:PTFrameNoTag withPayload:payload callback:^(NSError *error) {
    if (error) {
    NSLog(@"Failed to send message: %@", error);
    }
    }];
    [self appendOutputMessage:[NSString stringWithFormat:@"[you]: %@", message]];
    } else {
    [self appendOutputMessage:@"Can not send message — not connected"];
    }
    }
    */
    
    func sendMessage(data: (String?,Bool?)){
        
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
        let info: [String: NSObject] = ["localizedModel": device.localizedModel, "multitasking supported":]
        //let info: [NSObject: String] = [device.localizedModel: "localizedModel", device.multitaskingSupported: "multitaskingSupported", device.name: "name", (UIDeviceOrientationIsLandscape(device.orientation) ? "landscape" : "portrait"): "orientation", device.systemName: "systemName", device.systemVersion: "systemVersion", screenSizeDict: "screenSize", screen.scale: "screenScale"]
        let info2 = info as NSDictionary
        let payload = info2.createReferencingDispatchData()
        peerChannel_.sendFrameOfType(100, tag: 0, withPayload: payload) { (error) -> Void in
            if error != nil {
                print("Failed to send Device Info")
                println(error)
            }
        }
    }
    
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
    
    func ioFrameChannel(channel: PTChannel!, didReceiveFrameOfType type: UInt32, tag: UInt32, payload: PTData!) {
        //NSLog(@"didReceiveFrameOfType: %u, %u, %@", type, tag, payload);
        if (type == 101) {
            let payloadData = UnsafePointer<PTExampleTextFrame>(payload.data)
            
            //seg fault here
            //var textFrame:PTExampleTextFrame! = payloadData.memory
            
            //textFrame.length = textFrame.length.bigEndian;
            //let bytes = UnsafePointer<Void>(nilLiteral: textFrame.utf8text)
            //let message = NSString(bytes: bytes, length: Int(textFrame.length), encoding: NSUTF8StringEncoding)
            //println(message)
        } else if (type == 102) && (peerChannel_ != nil) {
            peerChannel_.sendFrameOfType(103, tag: tag, withPayload: nil, callback: nil)
        }
    }
    
    func ioFrameChannel(channel: PTChannel!, didEndWithError error: NSError!) {
        return
    }
    
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
    }
    //end
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "settingsPopover" {
            let dest = segue.destinationViewController as! SettingsViewController
            dest.delegate = self
        }
    }

    //passes slider button status from settingsViewController to mainViewController
    func HDCPDidChange(controller: SettingsViewController, on: Bool) {
        SettingsHDCPon = on
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */

        
}

