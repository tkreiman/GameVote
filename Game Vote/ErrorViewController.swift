//
//  ErrorViewController.swift
//  Game Vote
//
//  Created by Tobias Kreiman on 7/17/16.
//  Copyright © 2016 Tobias Kreiman. All rights reserved.
//

import UIKit

class ErrorViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print("memory warning")
    }
    
    override func viewDidAppear(animated: Bool) {
        self.presentAlert()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func presentAlert() {
        let alert = UIAlertController(title: "Error", message: "It appears that your device is not connected to the internet!", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Retry Connection", style: .Default, handler: { (action) in
            
            if Connection.isConnectedToInternet() {
                self.navigationController?.navigationBar.hidden = false
                self.navigationController?.popToRootViewControllerAnimated(true)
                
            } else {
                self.presentAlert()
                
            }
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }

}
