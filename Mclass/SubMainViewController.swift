//
//  SubMainViewController.swift
//  Mclass
//
//  Created by Mike Dobrowolski on 5/26/15.
//  Copyright (c) 2015 CAENiOS. All rights reserved.
//

import UIKit

class SubMainViewController: UIViewController {

    @IBOutlet weak var recordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.recordButton.frame = CGRectMake(100, 100, 100, 50)
        self.recordButton.backgroundColor = UIColor.redColor()
        //self.recordButton.layer.borderColor = CGColor[UIColor.blueColor()]
        self.recordButton.layer.cornerRadius = 15
        self.recordButton.setTitle("Recording Off", forState: UIControlState.Normal)
    }
    
    @IBAction func recordButtonTap(sender: UIButton) {
            let storyboard = UIStoryboard(name: "CamView", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("CamViewSB") as! CamView
            self.addChildViewController(controller)
            self.view.addSubview(controller.view)
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
