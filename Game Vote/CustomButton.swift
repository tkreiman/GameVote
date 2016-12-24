//
//  CustomButton.swift
//  Game Vote
//
//  Created by Tobias Kreiman on 5/21/16.
//  Copyright © 2016 Tobias Kreiman. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
    
    
    var pressDown = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var text = "Hello" {
        didSet {
            setNeedsDisplay()
        }
    }

    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        DrawButton.drawCanvas1(frame: bounds, text: self.text, pressDown: self.pressDown)
    }
    
    func animate() {
        
        self.pressDown = true
        var multiplier = -0.1
        
        if self.tag == 2 {
            multiplier = 0.1
        }
        
        
        UIView.animateWithDuration(0.3) {
            self.bounds.size.width = self.bounds.size.width * 1.2
            self.bounds.size.height = self.bounds.size.height * 1.2
            self.transform = CGAffineTransformMakeRotation(CGFloat(M_PI * multiplier))
        }
        
    }
    
    func undoAnimate() {
        self.pressDown = false
        if self.tag == 2 {
            UIView.animateWithDuration(0.4) {
                self.bounds.size.width = self.bounds.size.width / 1.2
                self.bounds.size.height = self.bounds.size.height / 1.2
                self.transform = CGAffineTransformMakeRotation(0)
            }
        } else if self.tag == 1 {
           UIView.animateWithDuration(0.4, animations: {
                self.bounds.size.width = 125
                self.bounds.size.height = 125
                self.transform = CGAffineTransformMakeRotation(0)
            })
        }
        
        
    }


}
