//
//  CamView.swift
//  Mclass
//
//  Created by Neal Parikh on 5/22/15.
//  Copyright (c) 2015 CAENiOS. All rights reserved.
//

import UIKit

class CamView: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
         self.PauseButton.backgroundColor = UIColor.redColor()
        self.PauseButton.layer.cornerRadius = 15
        self.PauseButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var PauseButton: UIButton!
   
    @IBAction func PauseButtonTouch(sender: UIButton) {
            if self.PauseButton.titleForState(UIControlState.Normal) == "Pause Recording" {
                self.PauseButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                self.PauseButton.backgroundColor = UIColor.greenColor()
                 self.PauseButton.layer.cornerRadius = 15
                self.PauseButton.setTitle("Resume Recording", forState: UIControlState.Normal)
            }
            else {
                self.PauseButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
                self.PauseButton.backgroundColor = UIColor.redColor()
                 self.PauseButton.layer.cornerRadius = 15
                self.PauseButton.setTitle("Pause Recording", forState: UIControlState.Normal)
                self.PauseButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func BackButton(sender: UIButton) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
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
