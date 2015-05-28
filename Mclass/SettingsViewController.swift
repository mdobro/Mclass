//
//  SettingsViewController.swift
//  Mclass
//
//  Created by Mike Dobrowolski on 5/28/15.
//  Copyright (c) 2015 CAENiOS. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    var HDCPon:Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //NEED DELEGATE TO PASS info between controllers
    @IBAction func HDCPchange(sender: UISwitch) {
        if sender.on {
            let alert = UIAlertController(title: "WARNING!", message: "Projector output cannot be properly recorded when this setting is enabled. Are you sure you want to continue?", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: {(UIAlertAction) -> Void in
                sender.setOn(true, animated: true)
            }))
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: {(UIAlertAction) -> Void in
                sender.setOn(false, animated: true)
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
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
