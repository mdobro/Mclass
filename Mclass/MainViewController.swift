//
//  ViewController.swift
//  Mclass
//
//  Created by Mike Dobrowolski on 5/22/15.
//  Copyright (c) 2015 CAENiOS. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var recordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.recordButton.frame = CGRectMake(100, 100, 100, 50)
        self.recordButton.backgroundColor = UIColor.redColor()
        self.recordButton.layer.cornerRadius = 15
        self.recordButton.setTitle("Recording Off", forState: UIControlState.Normal)
    }
    @IBAction func ProblemBarButtonTap(sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Help", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("HelpViewController") as! UIViewController
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    @IBAction func recordButtonTap(sender: UIButton) {
        if self.recordButton.titleForState(UIControlState.Normal) == "Recording Off" {
            self.recordButton.backgroundColor = UIColor.greenColor()
            self.recordButton.setTitle("Recording On", forState: UIControlState.Normal)
            
            let storyboard = UIStoryboard(name: "CamView", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("CamViewSB") as! UIViewController
            self.navigationController!.pushViewController(controller, animated: true)
        }
        else {
            self.recordButton.backgroundColor = UIColor.redColor()
            self.recordButton.setTitle("Recording Off", forState: UIControlState.Normal)        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

