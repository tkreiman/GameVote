//
//  AddGameViewController.swift
//  Game Vote
//
//  Created by Tobias Kreiman on 1/21/16.
//  Copyright © 2016 Tobias Kreiman. All rights reserved.
//

import UIKit
import Parse


class AddGameViewController: UIViewController {
    
    @IBOutlet weak var nameOfGame: UILabel!
    @IBOutlet weak var enterNameTextField: UITextField!
    @IBOutlet weak var topLabel: UILabel!
    
    var currentNewGame: String?
    
    
    override func viewDidLoad() {
        enterNameTextField.delegate = self
        
        
        topLabel.center.x -= self.view.frame.width + 60
        nameOfGame.center.x -= self.view.frame.width + 30
        enterNameTextField.center.x -= self.view.frame.width + 30
        //print(self.view.frame.width)
        
        UIView.animateWithDuration(1.55, delay: 0.35, usingSpringWithDamping: 2, initialSpringVelocity: 5, options: [], animations: { () -> Void in
            self.nameOfGame.center.x = self.view.frame.width / 2
            }, completion: nil)
        
        UIView.animateWithDuration(1.55, delay: 0.5, usingSpringWithDamping: 2, initialSpringVelocity: 5, options: [], animations: { () -> Void in
            self.enterNameTextField.center.x = self.view.frame.width / 2
            }, completion: nil)
        
        UIView.animateWithDuration(1.55, delay: 0.1, usingSpringWithDamping: 2, initialSpringVelocity: 5, options: [], animations: { () -> Void in
            self.topLabel.center.x = self.view.frame.width / 2
            }, completion: nil)
        
        let nbaGame = ScoreHelper.getNBAScore { (games) in
            let scoreView = self.view.viewWithTag(1) as! ScoreView
            if games.count == 1 {
                let game = games[0]
                scoreView.textLabel1 = game.team1
                scoreView.textLabel2 = game.team2
                scoreView.timeText = game.time
            }
        }
        
        let mlbGames = ScoreHelper.getMLBScore { (games) in
            for game in games {
                print("\(game.team1) and \(game.team2) and \(game.time)")
            }
        }
        
        
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if enterNameTextField.text != nil {
            currentNewGame = enterNameTextField.text
        }
        
        
    
    }
}


extension AddGameViewController: UITextFieldDelegate {
    
    
    //This gets called whenever the user taps the 'Return Key'
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        //print("Return Press")
        
        
        //removes keyboard
        enterNameTextField.resignFirstResponder()
        
        
        //assigns the text of the label to the text inputed by user
        if let text = textField.text {
            if text == "" {
                nameOfGame.text = "Ex: Blue Vs. Red"
            } else {
                nameOfGame.text = text
            }
        }
        
        //We do this so that the keyboard does not follow its normal protocol. We do this manually
        return false
    }
}