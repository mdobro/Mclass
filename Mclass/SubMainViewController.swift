//
//  SubMainViewController.swift
//  Mclass
//
//  Created by Mike Dobrowolski on 5/26/15.
//  Copyright (c) 2015 CAENiOS. All rights reserved.
//

import UIKit

protocol SubMainDelegate {
    var subMainSettings:(projector:Bool!, volume: Int!) {get set}
    var camViewSettings:(paused:Bool!, timeElapsed: Int!, timeRemaining: Int!) {get set}
    
    func camViewDidChange(sender: CamView, settings: (paused:Bool!, timeElapsed: Int!, timeRemaining: Int!))
    func subMainDidChange(sender: SubMainViewController, settings: (projector:Bool!, volume: Int!))
}

class SubMainViewController: UIViewController {
    var delegate:SubMainDelegate!

    @IBOutlet weak var advancedButton: UIButton!
    @IBOutlet weak var recordSettingsButton: UIButton!
    @IBOutlet weak var DisplayTime: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.recordSettingsButton.layer.cornerRadius = 15
         var timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("RefreshTime"), userInfo: nil, repeats: true)
        
    }
  func RefreshTime() {
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        self.DisplayTime.text = timestamp;
    }

    
    @IBAction func projectorPower(sender: UIButton) {
        if delegate!.subMainSettings.projector! {
            delegate!.subMainDidChange(self, settings: (false,0))
        }
        else {
            delegate!.subMainDidChange(self, settings: (true,0))
        }
    }
    
    @IBAction func recordSettingsButtonTap(sender: UIButton) {
        let storyboard = UIStoryboard(name: "CamView", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("CamViewSB") as! CamView
        controller.delegate = delegate
        self.addChildViewController(controller)
        UIView.transitionWithView(self.view, duration: 1.0, options: UIViewAnimationOptions.TransitionFlipFromRight, animations: {
            self.view.addSubview(controller.view)
        }, completion: nil)
        controller.didMoveToParentViewController(self)
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
