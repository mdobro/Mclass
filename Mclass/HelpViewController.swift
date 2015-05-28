//
//  HelpViewController.swift
//  Mclass
//
//  Created by Mike Dobrowolski on 5/26/15.
//  Copyright (c) 2015 CAENiOS. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    
    
    @IBOutlet weak var GetHelpNow: UIButton!
    
    @IBOutlet weak var GetHelpLater: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GetHelpNow.layer.borderWidth = 3
        GetHelpNow.layer.borderColor = GetHelpNow.titleLabel?.textColor.CGColor
        GetHelpNow.layer.cornerRadius = 10
        GetHelpLater.layer.borderWidth = 3
        GetHelpLater.layer.borderColor = GetHelpNow.titleLabel?.textColor.CGColor
        GetHelpLater.layer.cornerRadius = 10
        self.navigationController?.navigationBar.tintColor = UIColor.yellowColor()
       
        // Do any additional setup after loading the view.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "helpNow"){
            let button = sender as! UIButton
            let issuevc = segue.destinationViewController as! HelpTableViewController
            issuevc.helpNow = true
        }
        else if (segue.identifier == "helpLater"){
            let button = sender as! UIButton
            let issuevc = segue.destinationViewController as! HelpTableViewController
            issuevc.helpNow = false
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
