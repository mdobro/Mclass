//
//  CamView.swift
//  Mclass
//
//  Created by Neal Parikh on 5/22/15.
//  Copyright (c) 2015 CAENiOS. All rights reserved.
//

import UIKit

protocol CamViewDelegate{
    var camViewPauseButton:String {get set}
    func pauseButtonDidChange(sender:CamView, paused:String)
}

class CamView: UIViewController {

    @IBOutlet weak var PauseButton: UIButton!
    
    var delegate:CamViewDelegate!
    var pauseButtonTemp:String!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.PauseButton.setTitle(pauseButtonTemp, forState: .Normal)
         setPauseButton()
        // Do any additional setup after loading the view.
    }
   
    @IBAction func PauseButtonTouch(sender: UIButton) {
        setPauseButton()
    }
    
    func setPauseButton(){
        if self.PauseButton.titleForState(UIControlState.Normal) == "Pause Recording" {
            self.PauseButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            self.PauseButton.backgroundColor = UIColor.greenColor()
            self.PauseButton.layer.cornerRadius = 15
            self.PauseButton.setTitle("Resume Recording", forState: UIControlState.Normal)
            delegate!.pauseButtonDidChange(self, paused: "Pause Recording")
        }
        else {
            self.PauseButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
            self.PauseButton.backgroundColor = UIColor.redColor()
            self.PauseButton.layer.cornerRadius = 15
            self.PauseButton.setTitle("Pause Recording", forState: UIControlState.Normal)
            self.PauseButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            
            delegate!.pauseButtonDidChange(self, paused: "Resume Recording")
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
