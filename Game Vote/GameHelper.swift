//
//  GameHelper.swift
//  Game Vote
//
//  Created by Tobias Kreiman on 2/5/16.
//  Copyright © 2016 Tobias Kreiman. All rights reserved.
//

import Foundation
import Alamofire


class GameHelper {
    
    
    
    
    static func getNBAGames() -> [String] {
        
        var arrayOfGames = [String]()
        
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
                    let timeLine = textSeparatedByLinesArray[4]
                    
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
                            
                            
                           // print("\(team1) vs. \(team2) will play on \(gameDate) at \(time)")
                          let string = "\(team1) vs. \(team2)"
                          arrayOfGames.append(string)
                            
                        }
                        
                    }
            
                }
                
                print(arrayOfGames)
                
            } else  {
                //something went wrong
                
                
            }
            print(arrayOfGames)
        }
        print(arrayOfGames)
        return arrayOfGames
    }
}