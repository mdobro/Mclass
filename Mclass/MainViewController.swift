//
//  ViewController.swift
//  Mclass
//
//  Created by Mike Dobrowolski on 5/22/15.
//  Copyright (c) 2015 CAENiOS. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    override func viewDidLoad() {
        let logo = UIImage(named: "CAEN Logo")
        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIImageView(image: logo))
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "Bar"), forBarMetrics:.Default)
        self.navigationController!.navigationBar.tintColor = UIColor.yellowColor()
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func ProblemBarButtonTap(sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Help", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("HelpViewController") as! UIViewController
        self.navigationController!.pushViewController(controller, animated: true)
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

