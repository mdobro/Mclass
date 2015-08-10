//
//  SubMainViewController.swift
//  Mclass
//
//  Created by Mike Dobrowolski on 5/26/15.
//  Copyright (c) 2015 CAENiOS. All rights reserved.
//

import UIKit

protocol SubMainDelegate {
    
    var camViewSettings:(paused:Bool!, timeElapsed: Int!, timeRemaining: Int!) {get set}
    
    func camViewDidChange(sender: CamView, settings: (paused:Bool!, timeElapsed: Int!, timeRemaining: Int!))
    func subMainDidChange(sender: SubMainViewController, volume: Int!)
    
}

class SubMainViewController: UIViewController {
    var delegate:SubMainDelegate!

    @IBOutlet weak var recordSettingsButton: UIButton!
    @IBOutlet weak var DisplayTime: UILabel!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var volLabel: UILabel!
    @IBOutlet weak var MinusVol: UIButton!
    @IBOutlet weak var PlusVol: UIButton!
    @IBOutlet weak var VOL_DSP: UIProgressView!
    
    var VOLUME: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.recordSettingsButton.layer.cornerRadius = 15
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("RefreshTime"), userInfo: nil, repeats: true)
        
        let barVal = Float((VOLUME+40))/52
        VOL_DSP.setProgress(barVal, animated: true)
    }

    @IBAction func Inc(sender: UIButton) {
        if (VOLUME < 12) {
            VOLUME = VOLUME + 3
            let barVal = Float((VOLUME+40))/52
            VOL_DSP.setProgress(barVal, animated: true)
        }
        delegate.subMainDidChange(self, volume: VOLUME)
    }
        
    @IBAction func Dec(sender: UIButton) {
        if (VOLUME > -39) {
            VOLUME = VOLUME - 3
            let barVal = Float((VOLUME+40))/52
            VOL_DSP.setProgress(barVal, animated: true)
        }
        delegate.subMainDidChange(self, volume: VOLUME)
    }

    
    func RefreshTime() {
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        self.DisplayTime.text = timestamp;
    }
    
    func makeAllClear(task:Bool) {
        //func to fade out buttons and object on sub screen when switching to cam view
        if task {
            self.view.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0)
            self.recordSettingsButton.alpha = 0
            self.DisplayTime.alpha = 0
            self.muteButton.alpha = 0
            self.volLabel.alpha = 0
            self.MinusVol.alpha = 0
            self.PlusVol.alpha = 0
        }
        else {
            self.view.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.75)
            self.recordSettingsButton.alpha = 1
            self.DisplayTime.alpha = 1
            self.muteButton.alpha = 1
            self.volLabel.alpha = 1
            self.MinusVol.alpha = 1
            self.PlusVol.alpha = 1
        }
    }
    
    @IBAction func recordSettingsButtonTap(sender: UIButton) {
        self.makeAllClear(true)
        let storyboard = UIStoryboard(name: "CamView", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("CamViewSB") as! CamView
        controller.delegate = delegate
        self.addChildViewController(controller)
        UIView.transitionWithView(self.view, duration: 1.0, options: UIViewAnimationOptions.TransitionFlipFromRight, animations: {
            self.view.addSubview(controller.view)
            }, completion: nil)
        controller.didMoveToParentViewController(self)
    }
    
    @IBAction func muteButtonTap(sender: UIButton) {
        if sender.titleLabel!.text == "Mute" {
            sender.setTitle("Unmute", forState: .Normal)
            delegate.subMainDidChange(self, volume: -10000)
        } else {
            sender.setTitle("Mute", forState: .Normal)
            delegate.subMainDidChange(self, volume: 10000)
        }
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
