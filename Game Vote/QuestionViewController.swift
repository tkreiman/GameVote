//
//  QuestionViewController.swift
//  Game Vote
//
//  Created by Tobias Kreiman on 1/18/16.
//  Copyright © 2016 Tobias Kreiman. All rights reserved.
//

import UIKit
import Parse
import SVProgressHUD
import Social


class QuestionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var selectedGame: String?
    var selectedNameOfGame: String?
    var selectedQuestion: String?
    @IBOutlet weak var tableView: UITableView!
    
    var questions:[String] = []
    var filtered: [String] = []
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var scoreView: ScoreView!
    
    var refresh: UIRefreshControl!
    var refreshing = false
    var flagNumberForQuestions: Int?
    var alreadyFlagObject: PFObject?
    var nameForChat: String?
    
    @IBOutlet weak var tableViewConstraint: NSLayoutConstraint!
    
    var sport = "" {
        didSet {
            if sport == "baseball" {
                self.getMLBScore()
            } else if sport == "basketball" {
                self.getNBAScore()
            }
        }
    }
    
    var state: SearchState = .DefaultMode {
        didSet {
            switch (state) {
            case .DefaultMode:
                
                
                
                searchBar.resignFirstResponder() // 3
                searchBar.text = ""
                searchBar.showsCancelButton = false
                self.tableView.reloadData()
            case .SearchMode:
                let searchText = searchBar?.text ?? ""
                searchBar.setShowsCancelButton(true, animated: true) //4
                
            }
            
        }
    }
    
    enum SearchState {
        case DefaultMode
        case SearchMode
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        /*questions = []
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        // retrieve all of the questions that relate to the game
        let questionQuery = PFQuery(className: "Question")
        questionQuery.whereKey("fromGame", equalTo: selectedGame!)
        questionQuery.findObjectsInBackgroundWithBlock { (returnedQuestions, error) -> Void in
            
            if error == nil {
                for question in returnedQuestions! {
                    let nameOfQuestion = question["question"] as! String
                    self.questions.append(nameOfQuestion)
                    
                }
            }
            self.tableView.reloadData()
        }*/
        //self.getQuestions()
        //SVProgressHUD.showWithStatus("Loading...")
        
        
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull To Refresh")
        refresh.addTarget(self, action: "startRefresh", forControlEvents: .ValueChanged)
        self.tableView.addSubview(refresh)
        
        
        
        guard Connection.isConnectedToInternet() == true else {
            print("not connected")
            self.refresh.endRefreshing()
            self.refreshing = false
            self.performSegueWithIdentifier("showErrorFromQuestion", sender: self)
            
            return
        }

        let flagNumberQuery = PFQuery(className: "FlagNumber")
        flagNumberQuery.getFirstObjectInBackgroundWithBlock { (returnedObject, error) -> Void in
            if error == nil {
                
                if let obj = returnedObject {
                    self.flagNumberForQuestions = obj["flagNumberForQuestions"] as? Int
                   // print(self.flagNumberForQuestions)
                }
            }
            
        
            self.getQuestions()
            
        }
        
        if selectedGame!.containsString("Optional") {
            var realObjId = self.selectedGame
            let myArray = realObjId?.componentsSeparatedByString("(\"")
            let text = myArray![1]
            realObjId = String(text.characters.dropLast(2))
            self.selectedGame = realObjId
            
            
            
        }

        
        let gameQuery = PFQuery(className: "Game")
        gameQuery.getObjectInBackgroundWithId(self.selectedGame!) { (object, error) in
            if error == nil {
                if let obj = object {
                    let sport = obj["sport"] as! String
                    if sport == "soccer" {
                        self.scoreView.centerLabel = true
                        self.scoreView.centerText = self.selectedNameOfGame!

                    } else if sport == "basketball" {
                        self.sport = "basketball"
                    } else if sport == "baseball" {
                        self.sport = "baseball"
                    }
                    if self.sport == "basketball" {
                        self.getNBAScore()
                    } else if self.sport == "baseball" {
                        self.getMLBScore()
                    }
                }
            }
        }
        
        
        
        
        //if Connection.isConnectedToInternet() {
          //  print("good to go")
        //} else {
          //  print("no")
        //}
    }
    
    
    func getMLBScore() {
        let currentGame = ScoreHelper.getMLBScore({ (games) in
            
            if games.count < 0 {
                self.scoreView.frame.size.height = 1
            } else {
                var selectedGameTeam1 = self.selectedNameOfGame?.componentsSeparatedByString(" vs. ")[0]
                var selectedGameTeam2 = self.selectedNameOfGame?.componentsSeparatedByString(" vs. ")[1]
                selectedGameTeam1 = selectedGameTeam1?.stringByReplacingOccurrencesOfString(" ", withString: "")
                selectedGameTeam2 = selectedGameTeam2?.stringByReplacingOccurrencesOfString(" ", withString: "")
                var teamFound = false
                for game in games {
                    var team1 = game.team1
                    team1 = team1.stringByReplacingOccurrencesOfString("0", withString: "")
                    team1 = team1.stringByReplacingOccurrencesOfString("1", withString: "")
                    team1 = team1.stringByReplacingOccurrencesOfString("2", withString: "")
                    team1 = team1.stringByReplacingOccurrencesOfString("3", withString: "")
                    team1 = team1.stringByReplacingOccurrencesOfString("4", withString: "")
                    team1 = team1.stringByReplacingOccurrencesOfString("5", withString: "")
                    team1 = team1.stringByReplacingOccurrencesOfString("6", withString: "")
                    team1 = team1.stringByReplacingOccurrencesOfString("7", withString: "")
                    team1 = team1.stringByReplacingOccurrencesOfString("8", withString: "")
                    team1 = team1.stringByReplacingOccurrencesOfString("9", withString: "")
                    team1 = team1.stringByReplacingOccurrencesOfString(" ", withString: "")
                
                    var team2 = game.team2
                    team2 = team2.stringByReplacingOccurrencesOfString("0", withString: "")
                    team2 = team2.stringByReplacingOccurrencesOfString("1", withString: "")
                    team2 = team2.stringByReplacingOccurrencesOfString("2", withString: "")
                    team2 = team2.stringByReplacingOccurrencesOfString("3", withString: "")
                    team2 = team2.stringByReplacingOccurrencesOfString("4", withString: "")
                    team2 = team2.stringByReplacingOccurrencesOfString("5", withString: "")
                    team2 = team2.stringByReplacingOccurrencesOfString("6", withString: "")
                    team2 = team2.stringByReplacingOccurrencesOfString("7", withString: "")
                    team2 = team2.stringByReplacingOccurrencesOfString("8", withString: "")
                    team2 = team2.stringByReplacingOccurrencesOfString("9", withString: "")
                    team2 = team2.stringByReplacingOccurrencesOfString(" ", withString: "")

                    if team1 == selectedGameTeam1 || team1 == selectedGameTeam2 {
                        if team2 == selectedGameTeam1 || team2 == selectedGameTeam2 {
                            self.scoreView.textLabel1 = game.team1
                            self.scoreView.textLabel2 = game.team2
                            self.scoreView.timeText = game.time
                            teamFound = true
                        }
                    }
                }
                if teamFound == false {
                    
                    UIView.animateWithDuration(0.5, animations: {
                        //self.tableViewConstraint.constant = -150
                        //self.scoreView.frame.size.height = 1
                        self.scoreView.centerLabel = true
                        self.scoreView.centerText = self.selectedNameOfGame!
                    })
                    
                }
                let a = self.scoreView.viewWithTag(1) as! UIActivityIndicatorView
                let b = self.scoreView.viewWithTag(2) as! UIButton
                a.stopAnimating()
                b.hidden = false
            }
        })

    }
    
    func getNBAScore() {
        let currentGame = ScoreHelper.getNBAScore({ (games) in
            
            if games.count < 1 {
                UIView.animateWithDuration(0.3, animations: {
                    //self.scoreView.frame.size.height = 1
                    //self.tableViewConstraint.constant = -150
                    self.scoreView.centerLabel = true
                    self.scoreView.centerText = self.selectedNameOfGame!
                })
                
                
            } else {
                var selectedGameTeam1 = self.selectedNameOfGame?.componentsSeparatedByString(" vs. ")[0]
                var selectedGameTeam2 = self.selectedNameOfGame?.componentsSeparatedByString(" vs. ")[1]
                selectedGameTeam1 = selectedGameTeam1?.stringByReplacingOccurrencesOfString(" ", withString: "")
                selectedGameTeam2 = selectedGameTeam2?.stringByReplacingOccurrencesOfString(" ", withString: "")
                var teamFound = false
                for game in games {
                    var team1 = game.team1
                    team1 = team1.stringByReplacingOccurrencesOfString("0", withString: "")
                    team1 = team1.stringByReplacingOccurrencesOfString("1", withString: "")
                    team1 = team1.stringByReplacingOccurrencesOfString("2", withString: "")
                    team1 = team1.stringByReplacingOccurrencesOfString("3", withString: "")
                    team1 = team1.stringByReplacingOccurrencesOfString("4", withString: "")
                    team1 = team1.stringByReplacingOccurrencesOfString("5", withString: "")
                    team1 = team1.stringByReplacingOccurrencesOfString("6", withString: "")
                    team1 = team1.stringByReplacingOccurrencesOfString("7", withString: "")
                    team1 = team1.stringByReplacingOccurrencesOfString("8", withString: "")
                    team1 = team1.stringByReplacingOccurrencesOfString("9", withString: "")
                    team1 = team1.stringByReplacingOccurrencesOfString(" ", withString: "")
                    
                    var team2 = game.team2
                    team2 = team2.stringByReplacingOccurrencesOfString("0", withString: "")
                    team2 = team2.stringByReplacingOccurrencesOfString("1", withString: "")
                    team2 = team2.stringByReplacingOccurrencesOfString("2", withString: "")
                    team2 = team2.stringByReplacingOccurrencesOfString("3", withString: "")
                    team2 = team2.stringByReplacingOccurrencesOfString("4", withString: "")
                    team2 = team2.stringByReplacingOccurrencesOfString("5", withString: "")
                    team2 = team2.stringByReplacingOccurrencesOfString("6", withString: "")
                    team2 = team2.stringByReplacingOccurrencesOfString("7", withString: "")
                    team2 = team2.stringByReplacingOccurrencesOfString("8", withString: "")
                    team2 = team2.stringByReplacingOccurrencesOfString("9", withString: "")
                    team2 = team2.stringByReplacingOccurrencesOfString(" ", withString: "")
                    //print("\(team2) and \(team1)")
                    
                    if team1 == selectedGameTeam1 || team1 == selectedGameTeam2 {
                        if team2 == selectedGameTeam1 || team2 == selectedGameTeam2 {
                            self.scoreView.textLabel1 = game.team1
                            self.scoreView.textLabel2 = game.team2
                            self.scoreView.timeText = game.time
                            teamFound = true
                            
                        }
                    }
                }
                if teamFound == false {
                    UIView.animateWithDuration(0.5, animations: {
                        //self.tableViewConstraint.constant = -150
                        //self.scoreView.frame.size.height = 1
                        self.scoreView.centerLabel = true
                        self.scoreView.centerText = self.selectedNameOfGame!

                    })
                }
                
                let a = self.scoreView.viewWithTag(1) as! UIActivityIndicatorView
                let b = self.scoreView.viewWithTag(2) as! UIButton
                a.stopAnimating()
                b.hidden = false
            }
        })

    }
    
    @IBAction func refreshScoreClicked(sender: AnyObject) {
        
        guard Connection.isConnectedToInternet() == true else {
            print("not connected")
            self.refresh.endRefreshing()
            self.refreshing = false
            self.performSegueWithIdentifier("showErrorFromQuestion", sender: self)
            
            return
        }

        
        let activity = scoreView.viewWithTag(1) as! UIActivityIndicatorView
        activity.startAnimating()
        let button = sender as! UIButton
        button.hidden = true
        if self.sport == "basketball" {
            self.getNBAScore()
        } else if self.sport == "baseball" {
            self.getMLBScore()
        }
    }
    
    
    func getQuestions() {
        
        
        guard Connection.isConnectedToInternet() == true else {
            print("not connected")
            self.refresh.endRefreshing()
            self.refreshing = false
            self.performSegueWithIdentifier("showErrorFromQuestion", sender: self)
            
            return
        }
                if refreshing == false {
            SVProgressHUD.showWithStatus("Loading...", maskType: SVProgressHUDMaskType.Gradient)
        }
        
        questions = []
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        var realObjId = self.selectedGame
        
        // retrieve all of the questions that relate to the game
       
        if selectedGame!.containsString("Optional") {
            
            let myArray = realObjId?.componentsSeparatedByString("(\"")
            let text = myArray![1]
            realObjId = String(text.characters.dropLast(2))
            self.selectedGame = realObjId
        
            
            
        }
        
      //  print(realObjId)
        
        let questionQuery = PFQuery(className: "Question")
        questionQuery.whereKey("fromGame", equalTo: realObjId!)
        questionQuery.findObjectsInBackgroundWithBlock { (returnedQuestions, error) -> Void in
            
            if error == nil {
                
                if returnedQuestions! == [] {
                    
                    let gameQuery = PFQuery(className: "Game")
                    gameQuery.getObjectInBackgroundWithId(self.selectedGame!, block: { (returnedObject, error) -> Void in
                        if error == nil {
                            
                            
                            var newQuestionsArray: [PFObject] = []
                            
                            let question1 = PFObject(className: "Question")
                            question1["fromGame"] = self.selectedGame
                            question1["question"] = "Will the game be close?"
                            question1["optionA"] = "Yes"
                            question1["optionB"] = "No"
                            question1["percentA"] = 0
                            question1["percentB"] = 0
                            question1["totalVotes"] = 0
                            question1["flagVotes"] = 0
                            question1["isFlagged"] = false

                            newQuestionsArray.append(question1)
                            
                            
                            let question2 = PFObject(className: "Question")
                            question2["fromGame"] = self.selectedGame
                            question2["question"] = "Who will win?"
                            question2["optionA"] = returnedObject!["teamA"]
                            question2["optionB"] = returnedObject!["teamB"]
                            question2["percentA"] = 0
                            question2["percentB"] = 0
                            question2["totalVotes"] = 0
                            question2["flagVotes"] = 0
                            question2["isFlagged"] = false

                            newQuestionsArray.append(question2)
                            
                            
                            let question3 = PFObject(className: "Question")
                            question3["fromGame"] = self.selectedGame
                            question3["question"] = "Which team has the best player?"
                            question3["optionA"] = returnedObject!["teamA"]
                            question3["optionB"] = returnedObject!["teamB"]
                            question3["percentA"] = 0
                            question3["percentB"] = 0
                            question3["totalVotes"] = 0
                            question3["flagVotes"] = 0
                            question3["isFlagged"] = false
                            newQuestionsArray.append(question3)
                            
                            for question in newQuestionsArray {
                                question.saveInBackground()
                            }
                            
                            
                            
                        }
                    })
                    
                    
                    
                } else {
                
                
                    for question in returnedQuestions! {
                        
                        let questionFlagged = question["isFlagged"] as! Bool
                        if questionFlagged == false {
                            let nameOfQuestion = question["question"] as! String
                            let questionObjectId = question.objectId
                            let myString = "\(questionObjectId!):\(nameOfQuestion)"
                            self.questions.append(myString)
                        }
                    
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
                if self.refreshing == true {
                    self.refreshing = false
                    self.refresh.endRefreshing()
                }
            })
        }

    }
    
    func startRefresh() {
        
        self.refreshing = true
        self.getQuestions()
    }

    
   
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "showDetailQuestion" {
            let selectedQuestionViewController = segue.destinationViewController as! SelectedQuestionViewController
            selectedQuestionViewController.selectedQuestion = self.selectedQuestion
            selectedQuestionViewController.fromGame = self.selectedGame
            
        } else if segue.identifier == "addQuestion" {
            let destinationController = segue.destinationViewController as! AddQuestionViewController
            destinationController.fromGame = self.selectedGame
        } else if segue.identifier == "showChat" {
            let destinationController = segue.destinationViewController as! ChatViewController
            destinationController.fromGame = self.selectedGame
            destinationController.senderDisplayName = self.nameForChat
        }
    }
    
    

    @IBAction func addQuestion(sender: AnyObject) {
        self.performSegueWithIdentifier("addQuestion", sender: self)
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if state == .SearchMode {
            return filtered.count
        }
        
        
        return questions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: AnyObject = tableView.dequeueReusableCellWithIdentifier("BasicCell")!
        let label = cell.viewWithTag(1) as! UILabel
        if state == .DefaultMode {
            if questions.count > indexPath.row {
                
                let myString = questions[indexPath.row]
                let myArray = myString.componentsSeparatedByString(":")
                
                label.text = myArray[1]
            }
        } else {
            if filtered.count > indexPath.row {
                
                let myString = filtered[indexPath.row]
                let myArray = myString.componentsSeparatedByString(":")
                
                label.text = myArray[1]
            }
        }
        
        
        
        return cell as! UITableViewCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var questionName = ""
        
        if state == .DefaultMode {
            
            let myString = questions[indexPath.row]
            let myArray = myString.componentsSeparatedByString(":")
            
            questionName = myArray[1]
            
        } else {
            
            let text = searchBar.text
            let white = NSCharacterSet.whitespaceCharacterSet()
            let textMinusWhite = text?.stringByTrimmingCharactersInSet(white)
            
            if textMinusWhite == "" {
                let myString = questions[indexPath.row]
                let myArray = myString.componentsSeparatedByString(":")
                
                questionName = myArray[1]
            } else {
            
                let myString = filtered[indexPath.row]
                let myArray = myString.componentsSeparatedByString(":")
            
                questionName = myArray[1]
            }
        
        }
        self.selectedQuestion = questionName
        state = .DefaultMode
        self.performSegueWithIdentifier("showDetailQuestion", sender: self)
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        search(searchText)
        
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        state = .SearchMode
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        state = .DefaultMode
    }
    
    
    func search(searchString: String) {
        
        filtered = questions.filter({ (text) -> Bool in
            let tmp: NSString = text
            let range = tmp.rangeOfString(searchString, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        
        
        
        tableView.reloadData()
        
    }

    @IBAction func moreButtonClicked(sender: AnyObject) {
        
        //print("more click")
        let buttonPosition = sender.convertPoint(CGPointZero, toView: self.tableView)
        let indexPath = tableView.indexPathForRowAtPoint(buttonPosition)
        
        if let row = indexPath?.row {
            
            if state == .DefaultMode {
                // Not in search mode
               //print(questions[row])
                let moreClickedQuestion = questions[row]
                let myArray = moreClickedQuestion.componentsSeparatedByString(":")
                
                let alert = UIAlertController(title: "More", message: myArray[1], preferredStyle: .ActionSheet)
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                let reportAction = UIAlertAction(title: "Report", style: .Default, handler: { (action) in
                    //print("Flagging: \(myArray[1]) With Object ID: \(myArray[0])")
                    self.reportQuestion(myArray[0])
                })
                let shareFacebook = UIAlertAction(title: "Share To Facebook", style: .Default, handler: { (action) in
                    self.shareTo("Facebook", question: myArray[1])
                })
                let shareTwitter = UIAlertAction(title: "Share To Twitter", style: .Default, handler: { (action) in
                    self.shareTo("Twitter", question: myArray[1])
                })
                alert.addAction(cancelAction)
                alert.addAction(reportAction)
                alert.addAction(shareFacebook)
                alert.addAction(shareTwitter)
                self.presentViewController(alert, animated: true, completion: nil)
                
                
            } else {
                let text = searchBar.text
                let white = NSCharacterSet.whitespaceCharacterSet()
                let textMinusWhite = text?.stringByTrimmingCharactersInSet(white)
                
                
                if textMinusWhite == "" {
                    
                    // In search mode but nothing typed
                   // print(questions[row])
                    let moreClickedQuestion = questions[row]
                    let myArray = moreClickedQuestion.componentsSeparatedByString(":")
                    
                    let alert = UIAlertController(title: "More", message: myArray[1], preferredStyle: .ActionSheet)
                    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                    let reportAction = UIAlertAction(title: "Report", style: .Default, handler: { (action) in
                       // print("Flagging: \(myArray[1]) With Object ID: \(myArray[0])")
                        self.reportQuestion(myArray[0])
                    })
                    let shareFacebook = UIAlertAction(title: "Share To Facebook", style: .Default, handler: { (action) in
                        self.shareTo("Facebook", question: myArray[1])
                    })
                    let shareTwitter = UIAlertAction(title: "Share To Twitter", style: .Default, handler: { (action) in
                        self.shareTo("Twitter", question: myArray[1])
                    })
                    alert.addAction(cancelAction)
                    alert.addAction(reportAction)
                    alert.addAction(shareFacebook)
                    alert.addAction(shareTwitter)
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                } else {
                    // In search mode with something typed
                   // print(filtered[row])
                    let moreClickedQuestion = filtered[row]
                    let myArray = moreClickedQuestion.componentsSeparatedByString(":")
                    
                    let alert = UIAlertController(title: "More", message: myArray[1], preferredStyle: .ActionSheet)
                    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                    let reportAction = UIAlertAction(title: "Report", style: .Default, handler: { (action) in
                       // print("Flagging: \(myArray[1]) With Object ID: \(myArray[0])")
                        self.reportQuestion(myArray[0])
                    })
                    let shareFacebook = UIAlertAction(title: "Share To Facebook", style: .Default, handler: { (action) in
                        self.shareTo("Facebook", question: myArray[1])
                    })
                    let shareTwitter = UIAlertAction(title: "Share To Twitter", style: .Default, handler: { (action) in
                        self.shareTo("Twitter", question: myArray[1])
                    })
                    alert.addAction(cancelAction)
                    alert.addAction(reportAction)
                    alert.addAction(shareFacebook)
                    alert.addAction(shareTwitter)
                    self.presentViewController(alert, animated: true, completion: nil)
                
                }
                
            }
        }
    }
    
    
    
    
    @IBAction func chatButtonPressed(sender: AnyObject) {
        //print("Take me to chat!")
        
        let alert = UIAlertController(title: "Chat", message: "Enter your name for the chat.", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textfield) in
            textfield.placeholder = "Enter Your Name"
        }
        
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) in
            let text = alert.textFields!.first!.text
            let white = NSCharacterSet.whitespaceCharacterSet()
            let textMinusWhite = text?.stringByTrimmingCharactersInSet(white)
            
            if textMinusWhite == "" {
                //Show error
                let errorAlert = UIAlertController(title: "Error", message: "You did not input a valid name for the chat", preferredStyle: .Alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                self.presentViewController(errorAlert, animated: true, completion: nil)
            } else {
                // Segue to chat
                self.nameForChat = text
                self.performSegueWithIdentifier("showChat", sender: nil)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
        
        //self.performSegueWithIdentifier("showChat", sender: nil)
    }
    
    func shareTo(serviveType: String, question: String) {
        var myServiceType = SLServiceTypeFacebook
        if serviveType == "Twitter" {
            myServiceType = SLServiceTypeTwitter
        }
        
        if SLComposeViewController.isAvailableForServiceType(myServiceType) {
            let slViewController: SLComposeViewController = SLComposeViewController(forServiceType: myServiceType)
            slViewController.setInitialText("Come check out \(self.selectedNameOfGame!) on Game Vote! \(question)")
            self.presentViewController(slViewController, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Error", message: "Please log into \(serviveType) within your settings or check your internet connection.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }

    
    
    
    
    func reportQuestion(questionToFlag: String) {
        
        
        guard Connection.isConnectedToInternet() == true else {
            print("not connected")
            self.refresh.endRefreshing()
            self.refreshing = false
            self.performSegueWithIdentifier("showErrorFromQuestion", sender: self)
            
            return
        }
        
        SVProgressHUD.showWithStatus("", maskType: SVProgressHUDMaskType.Gradient)
       // print(questionToFlag)
        var userFlagArray: [String] = []
        var hasVoted = false
        
        let localQuery = PFQuery(className: "localFlagQuestions")
        localQuery.fromLocalDatastore()
        localQuery.findObjectsInBackgroundWithBlock { (result, error) in
           
            if result! == [] {
                var flaggedQuestions = PFObject(className: "localFlagQuestions")
                flaggedQuestions["userFlaggedQuestions"] = [""]
                userFlagArray = flaggedQuestions["userFlaggedQuestions"] as! [String]
                self.alreadyFlagObject = flaggedQuestions
                flaggedQuestions.pinInBackground()
                
            } else {
                let returnedObject = result![0]
                let arrayFromObject = returnedObject["userFlaggedQuestions"] as! [String]
                self.alreadyFlagObject = returnedObject
                userFlagArray = arrayFromObject
                
                for question in arrayFromObject {
                    if questionToFlag == question {
                        hasVoted = true
                    }
                }
                
            }
            
            
            if hasVoted == false {
                
                //TODO - Flag the question 
                
                let flagQuery = PFQuery(className: "Question")
                flagQuery.getObjectInBackgroundWithId(questionToFlag, block: { (returnedObject, error) in
                    if error == nil {
                        if let obj = returnedObject {
                            var numberOfFlagsForQuestion = obj["flagVotes"] as! Int
                            if numberOfFlagsForQuestion == 0 {
                                obj["flagVotes"] = 1
                                obj.saveInBackgroundWithBlock({ (success, error) in
                                    if error == nil {
                                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                            SVProgressHUD.dismiss()
                                            let alert = UIAlertController(title: "Thank You", message: "This question will be reviewed", preferredStyle: .Alert)
                                            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                                            self.presentViewController(alert, animated: true, completion: nil)
                                        })

                                    }
                                })
                            } else {
                                
                                numberOfFlagsForQuestion += 1
                                
                                
                                if numberOfFlagsForQuestion >= self.flagNumberForQuestions {
                                    
                                    obj["isFlagged"] = true
                                    obj["flagVotes"] = numberOfFlagsForQuestion
                                    obj.saveInBackgroundWithBlock({ (success, error) in
                                        if error == nil {
                                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                                SVProgressHUD.dismiss()
                                                let alert = UIAlertController(title: "Thank You", message: "This question will be reviewed", preferredStyle: .Alert)
                                                alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                                                self.presentViewController(alert, animated: true, completion: nil)
                                            })

                                        }
                                    })
                                    
                                } else {
                                    obj["flagVotes"] = numberOfFlagsForQuestion
                                    obj.saveInBackgroundWithBlock({ (success, error) in
                                        if error == nil {
                                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                                SVProgressHUD.dismiss()
                                                let alert = UIAlertController(title: "Thank You", message: "This question will be reviewed", preferredStyle: .Alert)
                                                alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                                                self.presentViewController(alert, animated: true, completion: nil)
                                            })

                                        }
                                    })
                                }
                            }
                        }
                        
                        userFlagArray.append(questionToFlag)
                        self.alreadyFlagObject!["userFlaggedQuestions"] = userFlagArray
                        self.alreadyFlagObject?.pinInBackground()
                    }
                })
                
                
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    SVProgressHUD.dismiss()
                    let alert = UIAlertController(title: "Error", message: "It appears that you have already reported this question!", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                })

                
                
            }
            
        }
        
    }
    
}
