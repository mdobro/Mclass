//
//  ViewController.swift
//  Mclass
//
//  Created by Mike Dobrowolski on 5/22/15.
//  Copyright (c) 2015 CAENiOS. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, SettingsViewControllerDelegate, PTChannelDelegate {
    
    func ioFrameChannel(channel: PTChannel, didReceiveFrameOfType type: UInt32, tag: UInt32, payload: PTData) {
        
    }
    
    @IBOutlet weak var settingsBarButton: UIBarButtonItem!
    @IBOutlet weak var problemBarButton: UIBarButtonItem!
    weak var peerChannel: PTChannel!
    weak var serverChannel: PTChannel!
    
    var SettingsHDCPon = false
    
    override func viewDidLoad() {

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "Bar"), forBarMetrics:.Default)
        self.navigationController?.navigationBar.tintColor = UIColor.yellowColor()
        
        let buttonDict = [NSFontAttributeName: UIFont(name: "Arial", size: 30)!]
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes(buttonDict, forState: UIControlState.Normal)
        
        let negSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        negSpace.width = -15
        self.navigationItem.leftBarButtonItems?.insert(negSpace, atIndex: 0)
        
        let channel:PTChannel! = PTChannel(delegate: self)
        channel.listenOnPort(2345, IPv4Address: UInt32(2130706433), callback: nil)
        peerChannel = channel
        
    }
    
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

