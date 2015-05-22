//
//  ViewController.swift
//  Mclass
//
//  Created by Mike Dobrowolski on 5/22/15.
//  Copyright (c) 2015 CAENiOS. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func SwitchToCamView(sender: AnyObject) {
       

        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func ChangeScreens(sender: AnyObject) {
        
        let viewController:UIViewController = UIStoryboard(name: "CamView", bundle: nil).instantiateViewControllerWithIdentifier("CamViewSB") as! UIViewController
        // .instantiatViewControllerWithIdentifier() returns AnyObject! this must be downcast to utilize it
        
        self.presentViewController(viewController, animated: false, completion: nil)
        
    }

}

