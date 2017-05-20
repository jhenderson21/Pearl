//
//  Colors.swift
//  Pearl
//
//  Created by Jasen Henderson on 5/18/17.
//  Copyright © 2017 Otter. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}

var unselectedButtonColor = UIColor(red: 141, green: 141, blue: 141)

var targetColor = UIColor(red: 255, green: 110, blue: 95)

var replacementColor = UIColor(red: 74, green: 214, blue: 144)

var pressingColor = UIColor(red: 205, green: 205, blue: 205)

var otterThemeColor = UIColor(red: 137, green: 201, blue: 247)

var otterGreyColor = UIColor(red: 78, green: 78, blue: 78)
