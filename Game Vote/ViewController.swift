//
//  ViewController.swift
//  Game Vote
//
//  Created by Tobias Kreiman on 1/17/16.
//  Copyright © 2016 Tobias Kreiman. All rights reserved.
//

import UIKit
import Parse
import Alamofire
import SVProgressHUD
import Social

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FrostedSidebarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var games: [PFObject] = []
    var selectedGame: String?
    var nameOfGames: [String] = []
    var addedGame: String?
    var newNBAGamesToSave: [String] = []
    var filtered: [String] = []
    var refresh: UIRefreshControl!
    var refreshing = false
    var flagNumberForGames: Int?
    var selectedNameOfGame: String?
    var alreadyFlagObject: PFObject?
    var haveAlreadyBeenFlaggedOnServer: [String] = []
    var sidebar: FrostedSidebar?
    var sidebarShowing = false
    
    var currentSport: String = "" {
        didSet {
            if currentSport == "home" {
                self.nameOfGames = []
                for game in games {
                    let flagged = game["isFlagged"] as! Bool
                    
                    if flagged == false {
                        let name = game["name"] as! String
                        let sport = game["sport"] as! String
                        let myString = "\(game.objectId)/\(name)/\(sport)"
                        self.nameOfGames.append(myString)
                       
                    }

                }
                tableView.reloadData()
            } else if currentSport == "soccer" {
                self.nameOfGames = []
                for game in games {
                    var sportOfGame = ""
                    
                    if game["sport"] == nil {
                        
                    } else {
                        sportOfGame = game["sport"] as! String
                    }
                    
                    if sportOfGame == "soccer" {
                        let flagged = game["isFlagged"] as! Bool
                        
                        if flagged == false {
                            let name = game["name"] as! String
                            let sport = game["sport"] as! String
                            let myString = "\(game.objectId)/\(name)/\(sport)"
                            self.nameOfGames.append(myString)
                        }

                    }
                    
                }
                self.tableView.reloadData()
            } else if currentSport == "basketball"{
                self.nameOfGames = []
                for game in games {
                    var sportOfGame = ""
                    
                    if game["sport"] == nil {
                        
                    } else {
                        sportOfGame = game["sport"] as! String
                    }
                    
                    if sportOfGame == "basketball" {
                        let flagged = game["isFlagged"] as! Bool
                        
                        if flagged == false {
                            let name = game["name"] as! String
                            let sport = game["sport"] as! String
                            let myString = "\(game.objectId)/\(name)/\(sport)"
                            self.nameOfGames.append(myString)
                        }

                    }
                }
                self.tableView.reloadData()
            } else if currentSport == "baseball" {
                self.nameOfGames = []
                for game in games {
                    var sportOfGame = ""
                    
                    if game["sport"] == nil {
                        
                    } else {
                        sportOfGame = game["sport"] as! String
                    }
                    
                    if sportOfGame == "baseball" {
                        let flagged = game["isFlagged"] as! Bool
                        
                        if flagged == false {
                            let name = game["name"] as! String
                            let sport = game["sport"] as! String
                            let myString = "\(game.objectId)/\(name)/\(sport)"
                            self.nameOfGames.append(myString)
                        }
                        
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
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
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        //This creates 'object' and sets its name to 'John'. It then saves it to the server and calls the block when it is done.  
       /* let object = PFObject(className: "Person")
        object["name"] = "John"
        object.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
         
            print("Object has been saved.")
        }*/
        
        addButton.tintColor = UIColor(red: 0, green: 148/255, blue: 62/255, alpha: 1)
        
        
        guard Connection.isConnectedToInternet() == true else {
            print("not connected")
            self.performSegueWithIdentifier("showError", sender: self)
            
            return
        }
        
        //GameHelper.getNBAGames()
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.Dark)
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Gradient)
        
        //SVProgressHUD.showWithStatus("", maskType: SVProgressHUDMaskType.Gradient)
        self.getGames()
        
        
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull To Refresh")
        refresh.addTarget(self, action: "startRefresh", forControlEvents: .ValueChanged)
        self.tableView.addSubview(refresh)
        let image = UIImage(named: "home")
        let image2 = UIImage(named: "Soccerball")
        let image3 = UIImage(named: "Basketball")
        let image4 = UIImage(named: "Baseball")
        
        let colors = [UIColor.whiteColor(), UIColor.whiteColor(), UIColor.whiteColor(), UIColor.whiteColor()]
        
        sidebar = FrostedSidebar(itemImages: [image!, image2!, image3!, image4!], colors: colors, selectionStyle: .Single)
        
        sidebar?.delegate = self
        
        
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleSwipe(_:)))
        rightSwipeGestureRecognizer.direction = .Right
        
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleSwipe(_:)))
        leftSwipeGestureRecognizer.direction = .Left
        
        view.addGestureRecognizer(rightSwipeGestureRecognizer)
        view.addGestureRecognizer(leftSwipeGestureRecognizer)
        /*
        let nbaGame = ScoreHelper.getNBAScore { (game) in
            print(game.team1)
            print(game.team2)
            print(game.time)
        }*/
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = false 
    }
    
    
    
    func handleSwipe(sender: UISwipeGestureRecognizer) {
        if sender.direction == .Left && sidebarShowing == true {
            sidebar?.dismissAnimated(true, completion: nil)
            self.sidebarShowing = false
        } else if sender.direction == .Right && sidebarShowing == false {
            sidebar?.showInViewController(self, animated: true)
            self.sidebarShowing = true
        }
        
    }
    
   
    
        //retrieve all of the games
    func getGames() {
        
        
        guard Connection.isConnectedToInternet() == true else {
            print("not connected")
            self.refresh.endRefreshing()
            self.refreshing = false
            self.performSegueWithIdentifier("showError", sender: self)
            
            return
        }

        
        //SVProgressHUD.showWithStatus("Loading...", maskType: SVProgressHUDMaskType.Gradient)
        if refreshing == false {
            SVProgressHUD.setBackgroundColor(UIColor.blackColor())
            SVProgressHUD.setForegroundColor(UIColor.whiteColor())
            
            SVProgressHUD.showWithStatus("Loading...", maskType: SVProgressHUDMaskType.Gradient)
        }
        games = []
        nameOfGames = []
        haveAlreadyBeenFlaggedOnServer = []
        let gameQuery = PFQuery(className: "Game")
        gameQuery.orderByDescending("createdAt")
        gameQuery.limit = 60
        
       // if self.currentSport == "soccer" || self.currentSport == "basketball" {
         //   gameQuery.whereKey("sport", equalTo: self.currentSport)
        //}
        gameQuery.findObjectsInBackgroundWithBlock { (returnedGames, error) -> Void in
           
            
            if error == nil {
                for game in returnedGames! {
                    
                    let flagged = game["isFlagged"] as! Bool
                    
                    if flagged == false {
                        let name = game["name"] as! String
                        let sport = game["sport"] as! String
                        let myString = "\(game.objectId)/\(name)/\(sport)"
                        if self.currentSport == "soccer" || self.currentSport == "basketball" || self.currentSport == "baseball" {
                            if game["sport"] != nil {
                            
                                if game["sport"] as! String == self.currentSport {
                                    self.nameOfGames.append(myString)
                                }
                            }
                        } else {
                            self.nameOfGames.append(myString)
                        }
                        self.games.append(game)
                    }
                }
               // self.games = returnedGames!
            }
            
            //self.tableView.reloadData()
            let flagNumberQuery = PFQuery(className: "FlagNumber")
            flagNumberQuery.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
                
                if error == nil {
                    if let flagNumberObject = object {
                        self.flagNumberForGames = flagNumberObject["flagNumberForGames"] as? Int
                        
                    }
                }
                
                
                let alreadyFlaggedGamesQuery = PFQuery(className: "Game")
                alreadyFlaggedGamesQuery.whereKey("isFlagged", equalTo: true)
                alreadyFlaggedGamesQuery.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
                    
                    if let returnedArray = result {
                        
                        for game in returnedArray{
                            self.haveAlreadyBeenFlaggedOnServer.append(game["name"] as! String)
                        }
                    }
                    
                    //print(self.haveAlreadyBeenFlaggedOnServer)
                   
                    
                    /*
                        |   |
                        |   |
                        |   |
                        v   V
                    
                    */
                    //Disabled Loading Games From Website Temporarily
                    // self.getNBAGames()
                    
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                        SVProgressHUD.dismiss()
                        if self.refreshing == true {
                            self.refresh.endRefreshing()
                            self.refreshing = false
                        }
                    })

                    
                })
                
                
            })
        }
        
    }
    
    
    func startRefresh() {
        
        self.refreshing = true
        self.getGames()
    }
    
    
    // retrieves NBA games
    func getNBAGames() {
        newNBAGamesToSave = []
        Alamofire.request(.GET, "http://www.nba.com/schedules/national_tv_schedule/").responseString { (response) -> Void in
            
            var previousGameDate = ""
            
            if let myString = response.result.value {
                
                
                
                let myArray = myString.componentsSeparatedByString("NATIONAL TV SCHEDULE")
                // TODO- check if array is out of range
                
                // We get html after National Tv Schedule
                let textWithGames = myArray[1]
                let myArray2 = textWithGames.componentsSeparatedByString("</tr>")
                
                // Puts into in an array everthing separated by <tr>
                // Example: <tr> abcde <tr>
                //Then abcde would be added to the array
               
                for i in 2..<12 {
                    let currentGame = myArray2[i]
                    let textSeparatedByLinesArray = currentGame.componentsSeparatedByString("\n")
                    
                    
                    let gameDateLine = textSeparatedByLinesArray[2]
                    let gameTeamLine = textSeparatedByLinesArray[3]
                    var timeLine = ""
                    if textSeparatedByLinesArray[4].characters.count > 15 {
                        timeLine = textSeparatedByLinesArray[4]
                    } else {
                        timeLine = textSeparatedByLinesArray[5]
                    }
                    
                    let idx = gameDateLine.rangeOfString(">")
                    let substring1 = gameDateLine.substringFromIndex((idx?.first)!)
                    let idx2 = substring1.rangeOfString("<")
                    var gameDate = substring1.substringToIndex((idx2?.first)!)
                    gameDate.removeRange(gameDate.startIndex..<gameDate.startIndex.advancedBy(1))
                    
                    if gameDate.characters.count > 1  {
                        previousGameDate = gameDate
                    } else {
                        gameDate = previousGameDate
                    }
                    
                    
                    let temporaryArray = gameTeamLine.componentsSeparatedByString(">")
                    let numberOfEntriesInTempArray = temporaryArray.count
                    if numberOfEntriesInTempArray > 3 {
                        var team1 = temporaryArray[2]
                        let myIdx = team1.rangeOfString("</a")
                        team1.removeRange(myIdx!)
                        //print (chic)
                        var team2 = temporaryArray[4]
                        let myIdx2 = team2.rangeOfString("</a")
                        team2.removeRange(myIdx2!)
                        
                        
                        let timeLineArray = timeLine.componentsSeparatedByString(">")
                        if timeLineArray.count > 1 {
                            var time = timeLineArray[1]
                            let myIdx3 = time.rangeOfString("</td")
                            time.removeRange(myIdx3!)
                            
                            
                            let NBAGameString = "\(team1) vs. \(team2)"
                            var repeated = false
                            
                            //print("First Time:  \(self.games)")
                            
                            for game in self.nameOfGames {
                                let text = game
                                let seperatorArray = text.componentsSeparatedByString("/")
                                var realGame = ""
                                if seperatorArray.count > 1 {
                                    realGame = seperatorArray[1]
                                }
                                
                                
                                if realGame == NBAGameString {
                                    repeated = true
                                }
                                
                                
                            }
                            
                            
                            
                            for game in self.haveAlreadyBeenFlaggedOnServer {
                                
                                if game == NBAGameString {
                                    repeated = true
                                }
                            }
                            
                            
                            // print("i couldnt find it")
                            if repeated == false {
                                self.nameOfGames.append(NBAGameString)
                                //self.saveGame(NBAGameString)
                                self.newNBAGamesToSave.append(NBAGameString)
                                
                                
                            }
                           
                            
                        }
                        
                    }
                   
                }
                //print(self.newNBAGamesToSave)
                if self.newNBAGamesToSave != [] {
                    self.saveMultipleGames(self.newNBAGamesToSave)
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                    SVProgressHUD.dismiss()
                    if self.refreshing == true {
                        self.refresh.endRefreshing()
                        self.refreshing = false
                    }
                })
            } else  {
                //something went wrong
                
                
            }
            
        }

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: AnyObject = tableView.dequeueReusableCellWithIdentifier("BasicCell")!
        let label1 = cell.viewWithTag(1) as! UILabel
        let label2 = cell.viewWithTag(2) as! UILabel
        let imageView = cell.viewWithTag(3) as! UIImageView
        
        
        if state == .DefaultMode {
            if games.count > indexPath.row {
                
                let text = nameOfGames[indexPath.row]
                let myArray = text.componentsSeparatedByString("/")
                
                if myArray.count > 1 {
                    let gameTitle = myArray[1]
                    let myArray2 = gameTitle.componentsSeparatedByString(" vs. ")
                    label1.text = myArray2[0]
                    label2.text = myArray2[1]
                    
                }
                
                if myArray[2] == "soccer" {
                    let image = UIImage(named: "Soccerball")
                    imageView.image = image
                } else if myArray[2] == "basketball" {
                    let image = UIImage(named: "Basketball")
                    imageView.image = image
                } else if myArray[2] == "baseball" {
                    let image = UIImage(named: "Baseball")
                    imageView.image = image
                }
                
                
            }
        } else {
            if filtered.count > indexPath.row {
                let text = filtered[indexPath.row]
                let myArray = text.componentsSeparatedByString("/")
                
                if myArray.count > 1 {
                    let gameTitle = myArray[1]
                    let myArray2 = gameTitle.componentsSeparatedByString(" vs. ")
                    label1.text = myArray2[0]
                    label2.text = myArray2[1]
                }
                
                if myArray[2] == "soccer" {
                    let image = UIImage(named: "Soccerball")
                    imageView.image = image
                } else if myArray[2] == "basketball" {
                    let image = UIImage(named: "Basketball")
                    imageView.image = image
                } else if myArray[2] == "baseball" {
                    let image = UIImage(named: "Baseball")
                    imageView.image = image
                }


            }
        }
        
        
        
        return cell as! UITableViewCell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 125
    }
    
        
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if state == .SearchMode {
            return filtered.count
        }
        
        
        return nameOfGames.count
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //print(strings[indexPath.row])
        
        if state == .DefaultMode {
            //let selectedObject = games[indexPath.row]
            //self.selectedNameOfGame = selectedObject["name"] as! String
            //self.selectedGame = selectedObject.objectId
            
            let nameOfGame = self.nameOfGames[indexPath.row]
            let myArray = nameOfGame.componentsSeparatedByString("/")
            self.selectedNameOfGame = myArray[1]
            self.selectedGame = myArray[0]
            
        } else {
            
           /* let white = NSCharacterSet.whitespaceCharacterSet()
            let realText = self.searchBar.text?.stringByTrimmingCharactersInSet(white)
            
            if realText == "" {
                let selectedObject = games[indexPath.row]
                self.selectedNameOfGame = selectedObject["name"] as! String
                //print(selectedObject["name"])
                self.selectedGame = selectedObject.objectId
                
                
            } else {*/
                
            if filtered != [] {
            
                let text = filtered[indexPath.row]
                let myArray = text.componentsSeparatedByString("/")
                if myArray.count > 1 {
                    self.selectedNameOfGame = myArray[1]
                    self.selectedGame = myArray[0]
                }
            } else {
                
                //let obj = games[indexPath.row]
                //self.selectedNameOfGame = obj["name"] as! String
                //self.selectedGame = obj.objectId
                
                let nameOfGame = self.nameOfGames[indexPath.row]
                let myArray = nameOfGame.componentsSeparatedByString("/")
                self.selectedNameOfGame = myArray[1]
                self.selectedGame = myArray[0]
            }
            //}
            
        }
        
        state = .DefaultMode
        
        self.performSegueWithIdentifier("showQuestions", sender: self)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showQuestions" {
            let questionViewController = segue.destinationViewController as! QuestionViewController
            questionViewController.selectedGame = self.selectedGame
            questionViewController.selectedNameOfGame = self.selectedNameOfGame
            //print(selectedNameOfGame)
        }
        
    }
    
    func saveMultipleGames(gamesToSave: [String]) {
        self.newNBAGamesToSave = []
       // print(self.newNBAGamesToSave)
        for game in gamesToSave {
            let newGame = PFObject(className: "Game")
            
            let text = game
            let myArray = text.componentsSeparatedByString("vs.")
            let whitespace = NSCharacterSet.whitespaceCharacterSet()
            let team1 = myArray[0].stringByTrimmingCharactersInSet(whitespace)
            let team2 = myArray[1].stringByTrimmingCharactersInSet(whitespace)
            
            
            
            
            newGame["teamA"] = team1
            newGame["teamB"] = team2
            newGame["name"] = game
            newGame["isFlagged"] = false
            newGame["flagVotes"] = 0
            newGame.saveInBackgroundWithBlock({ (success, error) -> Void in
                self.getGames()
            })
            
        }
    }
    
    @IBAction func unwindToSegue(segue: UIStoryboardSegue) {
        
        if let identifier = segue.identifier {
            //print("Identifier \(identifier)")
            if identifier == "save" {
                let source = segue.sourceViewController as! AddGameViewController
                self.addedGame = source.currentNewGame
                if addedGame == "" {
                    // if the user does not input a name and alert shows
                    self.startTime()
                  
                } else {
                    //saves the game
                    saveGame(addedGame!)
                    
                }
            } 
        }
    }
    
    
    
    func displayAlert() {
        let alert = UIAlertController(title: "Could Not Save Game", message: "You did not input a valid name", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func startTime() {
        var timer = NSTimer()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "displayAlert", userInfo: nil, repeats: false)
    }
    
    
    
    
    @IBAction func flagClicked(sender: AnyObject) {
        let buttonPosition = sender.convertPoint(CGPointZero, toView: self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition)
        if let row = indexPath?.row {
            if state == .DefaultMode {
                //print(games[row])
               // var moreClickedGame = games[row]
                
                let moreClickedText = nameOfGames[row]
                let myArray = moreClickedText.componentsSeparatedByString("/")
                //print(myArray[0])
                
                let alertController = UIAlertController(title: "More", message: "\(myArray[1])", preferredStyle: .ActionSheet)
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                let flagAction = UIAlertAction(title: "Report", style: .Default, handler: { (action) -> Void in
                    //print("flag \(self.games[row])")
                    self.flagGame(myArray[0], fromSearch: true)
                })
                let shareFacebook = UIAlertAction(title: "Share To Facebook", style: .Default, handler: { (action) in
                    self.shareTo("Facebook", game: myArray[1])
                })
                let shareTwitter = UIAlertAction(title: "Share To Twitter", style: .Default, handler: { (action) in
                    self.shareTo("Twitter", game: myArray[1])
                })
                alertController.addAction(cancelAction)
                alertController.addAction(flagAction)
                alertController.addAction(shareFacebook)
                alertController.addAction(shareTwitter)
                self.presentViewController(alertController, animated: true, completion: nil)
                
            } else {
                if searchBar.text?.characters.count > 0 {
                 
                    
                    let text = filtered[row]
                    let myArray = text.componentsSeparatedByString("/")
                    //var moreButtonClickedGame = ""
                    var name = ""
                    
                    //moreButtonClickedGame = myArray[0]
                    //print(myArray[0])
                    //print(moreButtonClickedGame)
                    name = myArray[1]
                    
                    state = .DefaultMode
                    searchBar.resignFirstResponder()
                    
                    
                    let alertController = UIAlertController(title: "More", message: "\(name)", preferredStyle: .ActionSheet)
                    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                    let flagAction = UIAlertAction(title: "Report", style: .Default, handler: { (action) -> Void in
                        //print("flag \(moreButtonClickedGame)")
                        self.flagGame(myArray[0], fromSearch: true)
                    })
                    let shareFacebook = UIAlertAction(title: "Share To Facebook", style: .Default, handler: { (action) in
                        self.shareTo("Facebook", game: name)
                    })
                    let shareTwitter = UIAlertAction(title: "Share To Twitter", style: .Default, handler: { (action) in
                        self.shareTo("Twitter", game: name)
                    })
                    alertController.addAction(cancelAction)
                    alertController.addAction(flagAction)
                    alertController.addAction(shareFacebook)
                    alertController.addAction(shareTwitter)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                    
            
            
                    
                } else {
                   // var moreButtonClickedGame = games[row]
                    state = .DefaultMode
                    searchBar.resignFirstResponder()
                    
                    let moreClickedText = nameOfGames[row]
                    let myArray = moreClickedText.componentsSeparatedByString("/")
                    
                    let alertController = UIAlertController(title: "More", message: "\(myArray[1])", preferredStyle: .ActionSheet)
                    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                    let flagAction = UIAlertAction(title: "Report", style: .Default, handler: { (action) -> Void in
                        //print("flag \(moreButtonClickedGame)")
                        self.flagGame(myArray[0], fromSearch: true)
                    })
                    let shareFacebook = UIAlertAction(title: "Share To Facebook", style: .Default, handler: { (action) in
                        self.shareTo("Facebook", game: myArray[1])
                    })
                    let shareTwitter = UIAlertAction(title: "Share To Twitter", style: .Default, handler: { (action) in
                        self.shareTo("Twitter", game: myArray[1])
                    })
                    alertController.addAction(cancelAction)
                    alertController.addAction(flagAction)
                    alertController.addAction(shareFacebook)
                    alertController.addAction(shareTwitter)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }

    }
    
    
    func saveGame(name: String) {
        //print("saving...")
        
        // creates a new 'Game' and saves it to parse
        // it also refreshes the data
        let newGame = PFObject(className: "Game")
        newGame["name"] = name
        newGame["isFlagged"] = false
        newGame["flagVotes"] = 0
        newGame.saveInBackgroundWithBlock { (success, error) -> Void in
            if success {
                if error == nil {
                    self.getGames()
                }
            }
        }
    }
    
    func shareTo(serviveType: String, game: String) {
        var myServiceType = SLServiceTypeFacebook
        if serviveType == "Twitter" {
            myServiceType = SLServiceTypeTwitter
        }
        
        if SLComposeViewController.isAvailableForServiceType(myServiceType) {
            let slViewController: SLComposeViewController = SLComposeViewController(forServiceType: myServiceType)
            slViewController.setInitialText("Come check out \(game) on Game Vote!")
            self.presentViewController(slViewController, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Error", message: "Please log into \(serviveType) within your settings or check your internet connection.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }

    }
    
    
    func flagGame(gameToFlag: String, fromSearch: Bool) {
        
        guard Connection.isConnectedToInternet() == true else {
            print("not connected")
            self.refresh.endRefreshing()
            self.refreshing = false
            self.performSegueWithIdentifier("showError", sender: self)
            
            return
        }

        
        SVProgressHUD.showWithStatus("", maskType: SVProgressHUDMaskType.Gradient)
        
        let flagQuery = PFQuery(className: "Game")
        //flagQuery.whereKey("objectId", equalTo: gameToFlag)
        //print(gameToFlag)
        //let objID = gameToFlag
        /*var realObjId = gameToFlag
        realObjId.removeAtIndex(realObjId.endIndex.predecessor())
        //print(realObjId)
        let myArray = realObjId.componentsSeparatedByString("(")*/
        
        var hasVoted = false
        var userFlagArray: [String] = []
        
        var objId = gameToFlag
        var updated = ""
        if fromSearch == true {
            let myArray = objId.componentsSeparatedByString("(")
            var theText = myArray[1]
            updated = String(theText.characters.dropFirst())
            updated = String(updated.characters.dropLast(2))
        } else {
            updated = gameToFlag
        }
        
        
        let localQuery = PFQuery(className: "localFlags")
        localQuery.fromLocalDatastore()
        localQuery.findObjectsInBackgroundWithBlock { (localResult, localError) -> Void in
            
            if localResult! == [] {
                
                let flaggedQuestions = PFObject(className: "localFlags")
                flaggedQuestions["userFlaggedGames"] = [""]
                self.alreadyFlagObject = flaggedQuestions
                userFlagArray = flaggedQuestions["userFlaggedGames"] as! [String]
                flaggedQuestions.pinInBackground()
                
            } else {
                let returnedObject = localResult![0]
                let arrayFromObject = returnedObject["userFlaggedGames"] as! [String]
                self.alreadyFlagObject = returnedObject
                userFlagArray = returnedObject["userFlaggedGames"] as! [String]
                
                for game in arrayFromObject {
                    //print(game)
                    //print(updated)
                    if game == updated {
                        hasVoted = true
                    }
                }
            }
         
            
            if hasVoted == false {
                flagQuery.getObjectInBackgroundWithId(updated) { (objectReturned, error) -> Void in
                    if error == nil {
                        if let myGame = objectReturned {
                            if myGame["flagVotes"] == nil {
                                //print(0)
                                myGame["flagVotes"] = 1
                                myGame.saveInBackgroundWithBlock({ (success, error) -> Void in
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        SVProgressHUD.dismiss()
                                        let alert = UIAlertController(title: "Thank You", message: "This game will be reviewed.", preferredStyle: .Alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                                        self.presentViewController(alert, animated: true, completion: nil)
                                    })
                                })
                            } else {
                                // myGame has more than 0 flagVotes
                                var numberOfFlagVotes = myGame["flagVotes"] as! Int
                                numberOfFlagVotes++
                                
                                if numberOfFlagVotes >= self.flagNumberForGames {
                                    
                                    myGame["isFlagged"] = true
                                    myGame.saveInBackgroundWithBlock({ (success, error) -> Void in
                                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                            SVProgressHUD.dismiss()
                                            let alert = UIAlertController(title: "Thank You", message: "This game will be reviewed", preferredStyle: .Alert)
                                            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                                            self.presentViewController(alert, animated: true, completion: nil)
                                        })

                                    })
                                    
                                } else {
                                    
                                    myGame["flagVotes"] = numberOfFlagVotes
                                    myGame.saveInBackgroundWithBlock({ (success, error) -> Void in
                                        
                                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                            SVProgressHUD.dismiss()
                                            
                                            let alert = UIAlertController(title: "Thank You", message: "This game will be reviewed", preferredStyle: .Alert)
                                            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                                            self.presentViewController(alert, animated: true, completion: nil)
                                            
                                        })
                                    })
                                }
                            }
                         
                            
                        userFlagArray.append(updated)
                        //print(userFlagArray)
                        self.alreadyFlagObject!["userFlaggedGames"] = userFlagArray
                        self.alreadyFlagObject?.pinInBackground()
                            
                        }
                    } else {
                        //print(error) There was an error
                    }
                    
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    SVProgressHUD.dismiss()
                    let alert = UIAlertController(title: "Error", message: "It appears that you have already reported this game!", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                })
            }
        }
        
    }
    
    /*func makeDefaultQuestions(fromGame: String) {
    
        let question1 = PFObject(className: "Question")
        question1["fromGame"] = fromGame
        question1["question"] = "Who will win"
    
    
    }*/
    
    
   
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        search(searchText)
        
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        state = .SearchMode
        //print(nameOfGames)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        state = .DefaultMode
    }
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    func search(searchString: String) {
        
        filtered = nameOfGames.filter({ (text) -> Bool in
            let tmp: NSString = text
            let range = tmp.rangeOfString(searchString, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        
        
        
        tableView.reloadData()
        
    }
    
    
    func sidebar(sidebar: FrostedSidebar, willShowOnScreenAnimated animated: Bool) {
        
    }
    func sidebar(sidebar: FrostedSidebar, didShowOnScreenAnimated animated: Bool) {
        self.sidebarShowing = true
    }
    func sidebar(sidebar: FrostedSidebar, willDismissFromScreenAnimated animated: Bool) {
        
    }
    func sidebar(sidebar: FrostedSidebar, didDismissFromScreenAnimated animated: Bool) {
        self.sidebarShowing = false
    }
    func sidebar(sidebar: FrostedSidebar, didTapItemAtIndex index: Int) {
        
        if index == 0 {
            self.currentSport = "home"
        } else if index == 1 {
            self.currentSport = "soccer"
        } else if index == 2 {
            self.currentSport = "basketball"
        } else if index == 3 {
            self.currentSport = "baseball"
        }
        self.sidebarShowing = false
        self.sidebar?.dismissAnimated(true, completion: nil)
    }
    func sidebar(sidebar: FrostedSidebar, didEnable itemEnabled: Bool, itemAtIndex index: Int) {
        
    }

    
    
    @IBAction func hamburgerButtonPressed(sender: AnyObject) {
        if sidebarShowing == false {
            self.sidebar?.showInViewController(self, animated: true)
        } else {
            self.sidebar?.dismissAnimated(true, completion: nil)
        }
    }

    
    
}

