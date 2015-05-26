//
//  HelpViewController.swift
//  Mclass
//
//  Created by Mike Dobrowolski on 5/26/15.
//  Copyright (c) 2015 CAENiOS. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "help"){
            let button = sender as! UIButton
            let issuevc = segue.destinationViewController as! HelpTableViewController
            if (button.titleLabel?.text == "Get Help Now"){
                issuevc.helpNow = true
            }
            else{
                issuevc.helpNow = false
            }
        }
    }
        
    @IBAction func cancelButtonTap(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("MainViewController") as! UIViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
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
