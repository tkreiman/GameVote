//
//  SelectedQuestionViewController.swift
//  Game Vote
//
//  Created by Tobias Kreiman on 1/24/16.
//  Copyright © 2016 Tobias Kreiman. All rights reserved.
//

import UIKit
import Parse
import SVProgressHUD
import SceneKit
import Charts

class SelectedQuestionViewController: UIViewController {
    
    @IBOutlet weak var questionLabel: UILabel!
    //@IBOutlet weak var optionALabel: UILabel!
    //@IBOutlet weak var optionBLabel: UILabel!
    
    var selectedQuestion: String?
    var fromGame: String?
    var totalVotes: Double?
    var myQuestion: PFObject?
    var numberA: Double?
    var numberB: Double?
    var userVotedQuestions: [String] = []
    var votedQuestionsObject: PFObject?
    //@IBOutlet weak var voteAButton: UIButton!
    //@IBOutlet weak var voteBButton: UIButton!
    
    
    @IBOutlet weak var voteASceneView: SCNView!
    
    @IBOutlet weak var voteBSceneView: SCNView!
    
    let boxA = SCNBox(width: 4, height: 0.5, length: 4, chamferRadius: 0)
    let boxB = SCNBox(width: 4, height: 0.5, length: 4, chamferRadius: 0)
    var boxNodeA = SCNNode()
    var boxNodeB = SCNNode()
    @IBOutlet weak var buttonA: CustomButton!
    @IBOutlet weak var buttonB: CustomButton!
    
    @IBOutlet weak var pieChartView: PieChartView!
    
    
    
    override func viewDidLoad() {
        
       // SVProgressHUD.showWithStatus("Loading...", maskType: SVProgressHUDMaskType.Gradient)
        
        
       /* refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull To Refresh")
        refresh.addTarget(self, action: "startRefresh", forControlEvents: .ValueChanged)
        self.view.addSubview(refresh)
        */
        
        pieChartView.hidden = true
        pieChartView.drawHoleEnabled = true
        pieChartView.drawSlicesUnderHoleEnabled = true
        pieChartView.usePercentValuesEnabled = true
        
        
        voteASceneView.hidden = true
        voteBSceneView.hidden = true
        
        
        
        let sceneA = SCNScene()
        let sceneB = SCNScene()
        
        voteBSceneView.scene = sceneB
        voteASceneView.scene = sceneA
        
        voteASceneView.autoenablesDefaultLighting = true
        voteBSceneView.autoenablesDefaultLighting = true
        
        let cameraA = SCNNode()
        let cameraB = SCNNode()
        
        cameraA.camera = SCNCamera()
        cameraB.camera = SCNCamera()
        
        //cameraA.position = SCNVector3(x: -2, y: 7.5, z: 15)
        //cameraB.position = SCNVector3(x: -4, y: 7.5, z: 15)
        cameraA.position = SCNVector3(x: -4.2, y: 7.80771208, z: 15.0619526)
        cameraB.position = SCNVector3(x: -4, y: 7.80771208, z: 15.0619526)
        
        cameraA.rotation = SCNVector4(x: -0.562657833, y: -0.795193434, z: -0.226018637, w: 0.527592063)
        cameraB.rotation = SCNVector4(x: -0.562657833, y: -0.795193434, z: -0.226018637, w: 0.527592063)
        
        
        sceneA.rootNode.addChildNode(cameraA)
        sceneB.rootNode.addChildNode(cameraB)
        
        //let boxA = SCNBox(width: 4, height: 0.5, length: 4, chamferRadius: 0)
        //let boxB = SCNBox(width: 4, height: 0.5, length: 4, chamferRadius: 0)
        //let boxNodeA = SCNNode(geometry: boxA)
        //let boxNodeB = SCNNode(geometry: boxB)
        
        boxNodeA = SCNNode(geometry: boxA)
        boxNodeB = SCNNode(geometry: boxB)
        

        sceneA.rootNode.addChildNode(boxNodeA)
        sceneB.rootNode.addChildNode(boxNodeB)
        
        boxA.firstMaterial?.diffuse.contents = UIColor.greenColor()
        boxB.firstMaterial?.diffuse.contents = UIColor(red: 30 / 255, green: 150 / 255, blue: 30 / 255, alpha: 1)
        
        boxNodeA.rotation = SCNVector4(x: 0, y: 1, z: 0.0, w: 0.0)
        boxNodeB.rotation = SCNVector4(x: 0, y: 1, z: 0.0, w: 0.0)
        
        
        
        
       // boxNodeA.position = SCNVector3(x: Float(self.voteASceneView.frame.width / 2), y: Float(self.voteASceneView.frame.height / 2), z: 0)
       // boxNodeB.position = SCNVector3(x: Float(self.voteBSceneView.frame.width / 2), y: Float(self.voteBSceneView.frame.height / 2), z: 0)
       /*
        boxNodeA.position.x -= 3
        boxNodeA.position.y += 3
        boxNodeB.position.x -= 3
        boxNodeB.position.y += 3
        boxNodeB.position.z -= 1.5
        boxNodeA.position.z -= 1.5
        */
        self.loadQuestion()
        
        //buttonA.center.x -= view.bounds.width
        //buttonB.center.x += view.bounds.width
        
        UIView.animateWithDuration(1, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: [], animations: {
            self.buttonA.center.x += self.view.bounds.width
            self.buttonB.center.x -= self.view.bounds.width
            }, completion: nil)
        
        
        
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        
        
        buttonA.center.x -= view.bounds.width
        buttonB.center.x += view.bounds.width
    }
    
    
    
    @IBAction func refresh(sender: AnyObject) {
        self.loadQuestion()
    }
    
    func loadQuestion() {
        
        guard Connection.isConnectedToInternet() == true else {
            print("not connected")
            self.performSegueWithIdentifier("showErrorFromSelectedQuestion", sender: self)
            
            return
        }

        
        SVProgressHUD.showWithStatus("Loading...", maskType: SVProgressHUDMaskType.Gradient)
        
        let questionQuery = PFQuery(className: "Question")
        questionQuery.whereKey("question", equalTo: selectedQuestion!)
        questionQuery.whereKey("fromGame", equalTo: fromGame!)
        questionQuery.findObjectsInBackgroundWithBlock { (returnedQuestions, error) -> Void in
            
            if error == nil {
                if let result = returnedQuestions {
                    let questionObject = result[0]
                    self.questionLabel.text = questionObject["question"] as? String
                    
                   // self.pieChartView.centerText = questionObject["question"] as? String
                    //let p = NSMutableParagraphStyle()
                    //p.lineBreakMode = NSLineBreakMode.ByWordWrapping
                    
                      //                 let s = NSMutableAttributedString(string: questionObject["question"] as! String, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(20)])
                    //s.addAttribute(NSParagraphStyleAttributeName, value: p, range: NSRange(location: 0, length: String(questionObject["question"]).characters.count))
                    
                   // self.pieChartView.centerAttributedText = s
                    
                    
                    //self.optionALabel.text = questionObject["optionA"] as? String
                    //self.optionBLabel.text = questionObject["optionB"] as? String
                    
                    self.buttonA.text = questionObject["optionA"] as! String
                    self.buttonB.text = questionObject["optionB"] as! String
                    
                    //self.totalVotes = questionObject["totalVotes"] as! Double
                    self.numberA = questionObject["percentA"] as? Double
                    self.numberB = questionObject["percentB"] as? Double
                    self.myQuestion = questionObject
                    self.totalVotes = self.numberA! + self.numberB!
                    
                    
                    
                    //if let id = self.myQuestion?.objectId {
                    //print(id)
                    //}
                    
                    let localQuery = PFQuery(className: "localQuestions")
                    localQuery.fromLocalDatastore()
                    localQuery.findObjectsInBackgroundWithBlock({ (localResult, localError) -> Void in
                        
                        if localResult! == [] {
                            //print("nothing found")
                            let votedQuestions = PFObject(className: "localQuestions")
                            votedQuestions["userVotedQuestions"] = [""]
                            votedQuestions.pinInBackground()
                            self.votedQuestionsObject = votedQuestions
                        } else {
                            //print("found something")
                            let returnedArrayObject = localResult![0]
                            self.votedQuestionsObject = returnedArrayObject
                            self.userVotedQuestions = returnedArrayObject["userVotedQuestions"] as! [String]
                            
                            for questionId in self.userVotedQuestions {
                                if self.myQuestion?.objectId == questionId {
                                    self.alreadyVote()
                                }
                            }
                        }
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            SVProgressHUD.dismiss()
                        })
                    })
                    
                }
            } else {
                //SVProgressHUD.dismiss()
                //let vc = self.storyboard?.instantiateViewControllerWithIdentifier("errorViewController")
                //self.navigationController?.presentViewController(vc!, animated: true, completion: nil)
            }
        }

    }
    
    /*
    @IBAction func voteOptionA(sender: AnyObject) {
        
        numberA = myQuestion!["percentA"] as! Double
        totalVotes = totalVotes! + 1
        numberA = numberA! + 1
        myQuestion!["percentA"] = numberA
        //myQuestion!["totalVotes"] = totalVotes
        myQuestion?.saveInBackground()
        
        self.userVotedQuestions.append((myQuestion?.objectId)!)
        votedQuestionsObject!["userVotedQuestions"] = userVotedQuestions
        votedQuestionsObject?.pinInBackground()
        
        self.alreadyVote()
        
    }
    
    @IBAction func voteOptionB(sender: AnyObject) {
        numberB = myQuestion!["percentB"] as! Double
        totalVotes = totalVotes! + 1
        numberB = numberB! + 1
        myQuestion!["percentB"] = numberB
        //myQuestion!["totalVotes"] = totalVotes
        myQuestion?.saveInBackground()
        
        self.userVotedQuestions.append((myQuestion?.objectId)!)
        votedQuestionsObject!["userVotedQuestions"] = userVotedQuestions
        votedQuestionsObject?.pinInBackground()

        
        self.alreadyVote()
    }
    
    */
    @IBAction func buttonADown(sender: AnyObject) {
        self.buttonA.animate()
    }
    
    
    @IBAction func buttonAUp(sender: AnyObject) {
        self.buttonA.undoAnimate()
        
        guard Connection.isConnectedToInternet() == true else {
            print("not connected")
            self.performSegueWithIdentifier("showErrorFromSelectedQuestion", sender: self)
            
            return
        }
        
        numberA = myQuestion!["percentA"] as! Double
        totalVotes = totalVotes! + 1
        numberA = numberA! + 1
        myQuestion!["percentA"] = numberA
        //myQuestion!["totalVotes"] = totalVotes
        myQuestion?.saveInBackground()
        
        self.userVotedQuestions.append((myQuestion?.objectId)!)
        votedQuestionsObject!["userVotedQuestions"] = userVotedQuestions
        votedQuestionsObject?.pinInBackground()
        
        self.alreadyVote()

    }
    
    
    @IBAction func buttonBDown(sender: AnyObject) {
        self.buttonB.animate()
    }
    
    @IBAction func buttonBUp(sender: AnyObject) {
        self.buttonB.undoAnimate()
        
        guard Connection.isConnectedToInternet() == true else {
            print("not connected")
            self.performSegueWithIdentifier("showErrorFromSelectedQuestion", sender: self)
            
            return
        }
        
        numberB = myQuestion!["percentB"] as! Double
        totalVotes = totalVotes! + 1
        numberB = numberB! + 1
        myQuestion!["percentB"] = numberB
        //myQuestion!["totalVotes"] = totalVotes
        myQuestion?.saveInBackground()
        
        self.userVotedQuestions.append((myQuestion?.objectId)!)
        votedQuestionsObject!["userVotedQuestions"] = userVotedQuestions
        votedQuestionsObject?.pinInBackground()
        
        
        self.alreadyVote()
    }
    
    
    @IBAction func buttonACancel(sender: AnyObject) {
        buttonA.undoAnimate()
    }
    
    @IBAction func buttonBCancel(sender: AnyObject) {
        buttonB.undoAnimate()
    }
    
    
    @IBAction func touchUpOutsideA(sender: AnyObject) {
        buttonA.undoAnimate()
    }
    
    @IBAction func touchUpOutsideB(sender: AnyObject) {
        buttonB.undoAnimate()
    }
    
    func alreadyVote() {
        //voteAButton.hidden = true
        //voteBButton.hidden = true
        
        buttonA.userInteractionEnabled = false
        buttonB.userInteractionEnabled = false
        
        buttonA.hidden = true
        buttonB.hidden = true
        
        
        
        //questionLabel.hidden = true
        
        let percentA = (numberA! / totalVotes!) * 100
        let percentB = (numberB! / totalVotes!) * 100
        var roundA = round(percentA)
        var roundB = round(percentB)
        
        if roundA + roundB != 100 {
            roundB -= 1
        }
        
        setChart([String(myQuestion!["optionA"]), String(myQuestion!["optionB"])], values: [roundA, roundB])
        
        pieChartView.hidden = false
        
        pieChartView.animate(yAxisDuration: 1.25, easingOption: .EaseInQuad)
        pieChartView.animate(xAxisDuration: 1.25, easingOption: .EaseInQuad)
        
        //pieChartView.highlightValue(ChartHighlight(xIndex: 1, dataSetIndex: 0))
        
        
        //optionALabel.text = String("\(myQuestion!["optionA"]): \(Int(roundA))%")
        //optionBLabel.text = String("\(myQuestion!["optionB"]): \(Int(roundB))%")
        
        buttonA.text = String("\(myQuestion!["optionA"]): \(Int(roundA))%")
        buttonB.text = String("\(myQuestion!["optionB"]): \(Int(roundB))%")
        
        
        //voteBSceneView.hidden = false
        //voteASceneView.hidden = false
        
        let heightA = percentA / 10
        let heightB = percentB / 10
        
        SCNTransaction.begin()
        SCNTransaction.setAnimationDuration(5)
        
        boxNodeA.rotation.w = Float(-0.3*M_PI)
        
        if heightA < 1 {
            boxA.height = 0.5
            boxB.height = CGFloat(heightB)
        } else if heightB < 1 {
            boxB.height = 0.5
            boxA.height = CGFloat(heightA)
        } else {
            boxA.height = CGFloat(heightA)
            boxB.height = CGFloat(heightB)
        }
        
        boxNodeB.rotation.w = Float(0.2*M_PI)
       // boxNodeA.rotation.y = Float(0.02*M_PI)
        boxNodeA.pivot = SCNMatrix4MakeTranslation(0, 0, 0)
        boxNodeB.pivot = SCNMatrix4MakeTranslation(0, 0, 0)
        SCNTransaction.commit()
        
        
        
        
        //print((numberA! / totalVotes!) * 100)
        //print((numberB! / totalVotes!) * 100)
        //print("number a \(numberA)")
        //print("number b \(numberB)")
        //print("total \(totalVotes)")
        //print(numberA!/totalVotes!)
        
    }
}


extension SelectedQuestionViewController {
    func setChart(dataPoints: [String], values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "Options")
        let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
        pieChartView.data = pieChartData
        
        
        pieChartDataSet.sliceSpace = 5
        pieChartDataSet.valueFont = NSUIFont.systemFontOfSize(17)
        pieChartDataSet.valueTextColor = UIColor.blackColor()
        pieChartDataSet.selectionShift = 0
        //pieChartDataSet.xValuePosition = .OutsideSlice
        //pieChartDataSet.valueLinePart2Length = 0.1
        //pieChartDataSet.valueLinePart1Length = 0.2
        let c = UIColor(red: 30/255, green: 190/255, blue: 30/255, alpha: 1)
        pieChartDataSet.colors = [UIColor(red: 0/255, green: 148/255, blue: 62/255, alpha: 1), c]
        
        let h = ChartHighlight(xIndex: 0, dataSetIndex: 0)
        
        
        
        
        
    }
    

}
