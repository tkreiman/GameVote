//
//  ScoreView.swift
//  Game Vote
//
//  Created by Tobias Kreiman on 6/10/16.
//  Copyright © 2016 Tobias Kreiman. All rights reserved.
//

import UIKit

class ScoreView: UIView {

    var textLabel1 = " " {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var textLabel2 = " " {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var timeText = " " {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var centerLabel = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var centerText = " " {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        for sub in self.subviews {
            if sub.tag != 1 {
                if sub.tag != 2 {
                    sub.removeFromSuperview()
                }
            }
        }
        
        if self.centerLabel == false {
        
            let rect1 = CGRectMake(-80, 20, self.frame.width - 20, 40)
            let rect2 = CGRectMake(-80, 76, self.frame.width - 20, 40)
            let rect3 = CGRectMake(75, 48, self.frame.width - 20, 40)
        
            let label1 = UILabel(frame: rect1)
            let label2 = UILabel(frame: rect2)
            let label3 = UILabel(frame: rect3)
        
            label1.text = self.textLabel1
            label2.text = self.textLabel2
            label3.text = self.timeText
            label1.textAlignment = .Center
            label2.textAlignment = .Center
            label3.textAlignment = .Center
        
            label1.font = UIFont.systemFontOfSize(24)
            label2.font = UIFont.systemFontOfSize(24)
            label3.font = UIFont.systemFontOfSize(16)
            
            let button = self.viewWithTag(2) as! UIButton
            button.hidden = false

            
            self.addSubview(label1)
            self.addSubview(label2)
            self.addSubview(label3)
        } else {
            let rect = CGRectMake(self.frame.size.width/4 - (self.frame.width/4 - 20), self.frame.size.height/4, self.frame.width - 20, 50)
            let label = UILabel(frame: rect)
            label.text = self.centerText
            label.textAlignment = .Center
            label.font = UIFont.systemFontOfSize(26)
            label.numberOfLines = 0
            
            let button = self.viewWithTag(2) as! UIButton
            button.hidden = true
            
            self.addSubview(label)
            
        }
    
    }
    

}
