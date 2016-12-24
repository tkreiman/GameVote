//
//  DrawButton.swift
//  Game Vote
//
//  Created by Tobias Kreiman on 5/21/16.
//  Copyright © 2016 Tobias Kreiman. All rights reserved.
//

import UIKit

class DrawButton: NSObject {
    static func drawCanvas1(frame frame: CGRect = CGRect(x: 0, y: 0, width: 50, height: 50), text: String = "Hello", pressDown: Bool) {
        
        var fontSize: CGFloat = 24
        if text.characters.count > 8 {
            fontSize = 17
        }
        
        var colorToUse = UIColor(red: 0/255, green: 148/255, blue: 62/255, alpha: 0.89)
        var textColor = UIColor.whiteColor()
        if pressDown == true {
            colorToUse = UIColor(red: 0/255, green: 168/255, blue: 62/255, alpha: 0.89)
            textColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
        }
        
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        //// Color Declarations
        let color = UIColor(red: 0.000, green: 0.386, blue: 1.000, alpha: 0.912)
        
        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalInRect: CGRect(x: frame.minX + floor(frame.width * 0.04000 + 0.5), y: frame.minY + floor(frame.height * 0.04000 + 0.5), width: floor(frame.width * 0.96000 + 0.5) - floor(frame.width * 0.04000 + 0.5), height: floor(frame.height * 0.96000 + 0.5) - floor(frame.height * 0.04000 + 0.5)))
        colorToUse.setFill()
        ovalPath.fill()
        
        
        //// Hello Drawing
        let helloRect = CGRect(x: frame.minX + floor(frame.width * 0.12000 + 0.5), y: frame.minY + floor(frame.height * 0.18000 + 0.5), width: floor(frame.width * 0.92000 + 0.5) - floor(frame.width * 0.12000 + 0.5), height: floor(frame.height * 0.82000 + 0.5) - floor(frame.height * 0.18000 + 0.5))
        let helloStyle = NSMutableParagraphStyle()
        helloStyle.alignment = .Center
        
        let helloFontAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(fontSize), NSForegroundColorAttributeName: textColor, NSParagraphStyleAttributeName: helloStyle]
        
        let helloTextHeight: CGFloat = NSString(string: text).boundingRectWithSize(CGSize(width: helloRect.width, height: CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: helloFontAttributes, context: nil).size.height
        CGContextSaveGState(context)
        CGContextClipToRect(context, helloRect)
        NSString(string: text).drawInRect(CGRect(x: helloRect.minX, y: helloRect.minY + (helloRect.height - helloTextHeight) / 2, width: helloRect.width, height: helloTextHeight), withAttributes: helloFontAttributes)
        CGContextRestoreGState(context)
    }

}
