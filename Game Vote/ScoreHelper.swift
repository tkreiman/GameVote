//
//  ScoreHelper.swift
//  Game Vote
//
//  Created by Tobias Kreiman on 6/8/16.
//  Copyright © 2016 Tobias Kreiman. All rights reserved.
//

import Foundation
import Alamofire

extension String {
    func removePercentTwenty() -> String {
        return self.stringByReplacingOccurrencesOfString("%20", withString: " ")
    }
}



class Game {
    
    var team1 = ""
    var team2 = ""
    var time = ""
    
}


class ScoreHelper {
    
  
    
    
    
    static func getNBAScore(callback: ([Game]) -> Void) {
        var games = [Game]()
        
        
        Alamofire.request(.GET, "http://espn.go.com/nba/bottomline/scores").responseString { (responseString) in
            if let websiteString = responseString.result.value {
                
                
                var decodedSTR = websiteString.removePercentTwenty()
                var separated = decodedSTR.componentsSeparatedByString("left")
                if separated.count < 2 {
                    print("No live games!")
                    callback(games)
                } else {
                    separated.removeAtIndex(0)
                    for game in separated {
                        let removedNumber = game.componentsSeparatedByString("=")[1]
                        let removedAnd = removedNumber.componentsSeparatedByString("&")[0]
                        let newGame = Game()
                        var time = removedAnd.componentsSeparatedByString("(")[1]
                        time = String(time.characters.dropLast())
                        newGame.time = time
                    
                        var teams = removedAnd.componentsSeparatedByString("(")[0]
                        teams = String(teams.characters.dropLast())
                        teams = teams.stringByReplacingOccurrencesOfString("   ", withString: "  ")
                        teams = teams.stringByReplacingOccurrencesOfString(" at ", withString: "  ")
                        var team1 = teams.componentsSeparatedByString("  ")[0]
                        var team2 = teams.componentsSeparatedByString("  ")[1]
                        team1 = team1.stringByReplacingOccurrencesOfString("^", withString: "")
                        team2 = team2.stringByReplacingOccurrencesOfString("^", withString: "")
                        newGame.team1 = team1
                        newGame.team2 = team2
                        games.append(newGame)
                    }
                    callback(games)
                }

            } else {
                print("Error getting website information!")
                callback(games)
                
            }
        }
        
        
    }
    
    static func getMLBScore(callback: ([Game]) -> Void) {
        var games = [Game]()
        
        Alamofire.request(.GET, "http://espn.go.com/mlb/bottomline/scores").responseString { (responseString) in
            if let websiteString = responseString.result.value {
                let decodedSTR = websiteString.removePercentTwenty()
                var arraySeparatedByEqual = decodedSTR.componentsSeparatedByString("left")
                if arraySeparatedByEqual.count < 2 {
                    print("No live games!")
                    callback(games)
                } else {
                    arraySeparatedByEqual.removeAtIndex(0)
                    for game in arraySeparatedByEqual {
                        let removedNumber = game.componentsSeparatedByString("=")[1]
                        let removedAnd = removedNumber.componentsSeparatedByString("&")[0]
                    
                        
                        
                        let newGame = Game()
                        
                        var time = removedAnd.componentsSeparatedByString("(")[1]
                        time = String(time.characters.dropLast())
                    
                        newGame.time = time
                
                        var teams = removedAnd.componentsSeparatedByString("(")[0]
                        teams = String(teams.characters.dropLast())
                        teams = teams.stringByReplacingOccurrencesOfString("   ", withString: "  ")
                        teams = teams.stringByReplacingOccurrencesOfString(" at ", withString: "  ")
                        var team1 = teams.componentsSeparatedByString("  ")[0]
                        var team2 = teams.componentsSeparatedByString("  ")[1]
                        team1 = team1.stringByReplacingOccurrencesOfString("^", withString: "")
                        team2 = team2.stringByReplacingOccurrencesOfString("^", withString: "")
                        newGame.team1 = team1
                        newGame.team2 = team2
                        
                        games.append(newGame)
                        
                        
                    
                    }
                    callback(games)
                }
            } else {
                print("Error getting website information!")
                callback(games)
            }
        }
        
    }
    
    static func getNFLScore() -> Game {
        let game = Game()
        
        return game
    }
    
    
}


