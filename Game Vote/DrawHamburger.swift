//
//  DrawHamburger.swift
//  Game Vote
//
//  Created by Tobias Kreiman on 5/7/16.
//  Copyright © 2016 Tobias Kreiman. All rights reserved.
//

import UIKit

class DrawHamburger: NSObject {
    static func drawCanvas1(frame frame: CGRect = CGRect(x: 0, y: 1, width: 49, height: 49)) {
        
        //// Rectangle Drawing
        let rectanglePath = UIBezierPath(roundedRect: CGRect(x: frame.minX, y: frame.minY, width: floor((frame.width) * 0.81633 + 0.5) - 1, height: floor((frame.height) * 0.08163 + 0.5)), cornerRadius: 2)
        UIColor.whiteColor().setFill()
        rectanglePath.fill()
        
        
        //// Rectangle 2 Drawing
        let rectangle2Path = UIBezierPath(roundedRect: CGRect(x: frame.minX, y: frame.minY + 10, width: floor((frame.width) * 0.81633 + 0.5) - 1, height: floor((frame.height - 10) * 0.10256 + 0.5)), cornerRadius: 2)
        UIColor.whiteColor().setFill()
        rectangle2Path.fill()
        
        
        //// Rectangle 3 Drawing
        let rectangle3Path = UIBezierPath(roundedRect: CGRect(x: frame.minX, y: frame.minY + 20, width: floor((frame.width) * 0.81633 + 0.5) - 1, height: floor((frame.height - 20) * 0.13793 + 0.5)), cornerRadius: 2)
        UIColor.whiteColor().setFill()
        rectangle3Path.fill()
    }
}
