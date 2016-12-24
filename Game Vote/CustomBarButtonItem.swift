//
//  CustomBarButtonItem.swift
//  Game Vote
//
//  Created by Tobias Kreiman on 5/7/16.
//  Copyright © 2016 Tobias Kreiman. All rights reserved.
//

import UIKit

class CustomBarButtonItem: UIButton {
    override func drawRect(rect: CGRect) {
        DrawHamburger.drawCanvas1()
    }
}
