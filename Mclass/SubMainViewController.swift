//
//  SubMainViewController.swift
//  Mclass
//
//  Created by Mike Dobrowolski on 5/26/15.
//  Copyright (c) 2015 CAENiOS. All rights reserved.
//

import UIKit

class SubMainViewController: UIViewController,CamViewDelegate {

    @IBOutlet weak var advancedButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    var camViewPauseButton:String = "Resume Recording" //will change to pause in camView viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.recordButton.layer.cornerRadius = 15
        //self.recordButton.frame = CGRectMake(0, 0, 50, 25)
        //self.recordButton.backgroundColor = UIColor.blackColor()
        //self.recordButton.layer.borderColor = CGColor[UIColor.blueColor()]
        //self.recordButton.setTitle("Recording Options", forState: UIControlState.Normal)
        //self.recordButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
    func pauseButtonDidChange(sender: CamView, paused: String) {
        camViewPauseButton = paused
    }
    
    @IBAction func recordButtonTap(sender: UIButton) {
        let storyboard = UIStoryboard(name: "CamView", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("CamViewSB") as! CamView
        controller.delegate = self
        controller.pauseButtonTemp = camViewPauseButton
        self.addChildViewController(controller)
        self.view.addSubview(controller.view)
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
