//
//  AddQuestionViewController.swift
//  Game Vote
//
//  Created by Tobias Kreiman on 2/3/16.
//  Copyright © 2016 Tobias Kreiman. All rights reserved.
//

import UIKit
import Parse

class AddQuestionViewController: UIViewController {
    
    
    @IBOutlet weak var optionBTextField: UITextField!
    @IBOutlet weak var questionTextField: UITextField!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var optionATextField: UITextField!
    @IBOutlet weak var optionBLabel: UILabel!
    @IBOutlet weak var optionALabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var fromGame: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        questionTextField.delegate = self
        optionATextField.delegate = self
        optionBTextField.delegate = self
        
        
       /* questionLabel.center.x += self.view.frame.width - 30
        optionALabel.center.x += self.view.frame.width - 30
        optionBLabel.center.x += self.view.frame.width - 30
        
        optionBTextField.center.x -= self.view.frame.width + 150
        optionATextField.center.x -= self.view.frame.width + 150
        questionTextField.center.x -= self.view.frame.width + 150
        
        UIView.animateWithDuration(1.55, delay: 0.2, usingSpringWithDamping: 2, initialSpringVelocity: 5, options: [], animations: { () -> Void in
            self.questionLabel.center.x = self.view.frame.width / 2
            }, completion: nil)
        UIView.animateWithDuration(1.55, delay: 0.2, usingSpringWithDamping: 2, initialSpringVelocity: 5, options: [], animations: { () -> Void in
            self.optionBLabel.center.x = self.view.frame.width / 2
            }, completion: nil)
        UIView.animateWithDuration(1.55, delay: 0.2, usingSpringWithDamping: 2, initialSpringVelocity: 5, options: [], animations: { () -> Void in
            self.optionALabel.center.x = self.view.frame.width / 2
            }, completion: nil)
        UIView.animateWithDuration(1.55, delay: 0.2, usingSpringWithDamping: 2, initialSpringVelocity: 5, options: [], animations: { () -> Void in
            self.optionATextField.center.x = self.view.frame.width / 2
            }, completion: nil)
        UIView.animateWithDuration(1.55, delay: 0.2, usingSpringWithDamping: 2, initialSpringVelocity: 5, options: [], animations: { () -> Void in
            self.optionBTextField.center.x = self.view.frame.width / 2
            }, completion: nil)
        UIView.animateWithDuration(1.55, delay: 0.2, usingSpringWithDamping: 2, initialSpringVelocity: 5, options: [], animations: { () -> Void in
            self.questionTextField.center.x = self.view.frame.width / 2
            }, completion: nil)
        */
        
        
        
        questionLabel.center.x -= self.view.frame.width + 30
        optionALabel.center.x -= self.view.frame.width + 30
        optionBLabel.center.x -= self.view.frame.width + 30
        
        optionBTextField.center.x -= self.view.frame.width + 150
        optionATextField.center.x -= self.view.frame.width + 150
        questionTextField.center.x -= self.view.frame.width + 150
        
        UIView.animateWithDuration(1.55, delay: 0.1, usingSpringWithDamping: 2, initialSpringVelocity: 5, options: [], animations: { () -> Void in
            self.questionLabel.center.x = self.view.frame.width / 2
            }, completion: nil)
        UIView.animateWithDuration(1.55, delay: 0.6, usingSpringWithDamping: 2, initialSpringVelocity: 5, options: [], animations: { () -> Void in
            self.optionBLabel.center.x = self.view.frame.width / 2
            }, completion: nil)
        UIView.animateWithDuration(1.55, delay: 0.3, usingSpringWithDamping: 2, initialSpringVelocity: 5, options: [], animations: { () -> Void in
            self.optionALabel.center.x = self.view.frame.width / 2
            }, completion: nil)
        UIView.animateWithDuration(1.55, delay: 0.45, usingSpringWithDamping: 2, initialSpringVelocity: 5, options: [], animations: { () -> Void in
            self.optionATextField.center.x = self.view.frame.width / 2
            }, completion: nil)
        UIView.animateWithDuration(1.55, delay: 0.75, usingSpringWithDamping: 2, initialSpringVelocity: 5, options: [], animations: { () -> Void in
            self.optionBTextField.center.x = self.view.frame.width / 2
            }, completion: nil)
        UIView.animateWithDuration(1.55, delay: 0.15, usingSpringWithDamping: 2, initialSpringVelocity: 5, options: [], animations: { () -> Void in
            self.questionTextField.center.x = self.view.frame.width / 2
            }, completion: nil)

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    //override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
       // print(segue.identifier)
    
    //}
    
    @IBAction func save(sender: AnyObject) {
        
        guard Connection.isConnectedToInternet() == true else {
            print("not connected")
            self.performSegueWithIdentifier("showErrorFromAddQuestion", sender: self)
            
            return
        }
        
        let whitespace = NSCharacterSet.whitespaceCharacterSet()
        
        if questionTextField.text?.stringByTrimmingCharactersInSet(whitespace) != "" && optionBTextField.text?.stringByTrimmingCharactersInSet(whitespace) != "" && optionATextField.text?.stringByTrimmingCharactersInSet(whitespace) != "" {
            let question = PFObject(className: "Question")
            question["question"] = questionTextField.text
            question["optionA"] = optionATextField.text
            question["optionB"] = optionBTextField.text
            question["fromGame"] = self.fromGame
            question["percentA"] = 0
            question["percentB"] = 0
            question["isFlagged"] = false
            question["flagVotes"] = 0
            //question["totalVotes"] = 0
            question.saveInBackgroundWithBlock({ (success, error) -> Void in
                if success {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            })
            
        } else {
            
            let alert = UIAlertController(title: "Could Not Save Question", message: "You did not input valid information", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)

            //self.navigationController?.popViewControllerAnimated(true)
        }
        
    }
    
    @IBAction func cancel(sender: AnyObject) {
        
        self.navigationController?.popViewControllerAnimated(true)
    }

}


extension AddQuestionViewController: UITextFieldDelegate {
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        //print("Return Press")
        
        
        //removes keyboard
        textField.resignFirstResponder()
        
        
        //assigns the text of the label to the text inputed by user
        if  questionTextField.text != "" {
            questionLabel.text = questionTextField.text
        } else {
            questionLabel.text = "Question:"
        }
        
        if optionATextField.text != "" {
            optionALabel.text = optionATextField.text
        } else {
            optionALabel.text = "Option A:"
        }
        
        if optionBTextField.text != "" {
            optionBLabel.text = optionBTextField.text
        } else {
            optionBLabel.text = "Option B:"
        }
        
        //We do this so that the keyboard does not follow its normal protocol. We do this manually
        return false
    }
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == self.optionBTextField {
            
            scrollView.setContentOffset(CGPointMake(0, 250), animated: true)
            
        } else if textField == self.optionATextField {
            scrollView.setContentOffset(CGPointMake(0, 125), animated: true)
        }
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
    }
    
}
