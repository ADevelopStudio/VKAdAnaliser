//
//  Constants.swift
//  Wotslocal_Swift
//
//  Created by Dmitry Zverev on 2/06/2015.
//  Copyright (c) 2015 Dmitry Zverev. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import VK_ios_sdk


var VKSCOPE: Array<AnyObject> = [VK_PER_ADS]


let defaults = NSUserDefaults.standardUserDefaults()

let screenWight:CGFloat = UIScreen.mainScreen().bounds.width
let screenHeight:CGFloat = UIScreen.mainScreen().bounds.height

let originalBlue: UIColor = UIColor(red: 83.0/255.0, green: 142.0/255.0, blue: 214.0/255.0, alpha: 1.0)
let originalDarkGrey: UIColor = UIColor(red: 67.0/255.0, green: 74.0/255.0, blue: 84.0/255.0, alpha: 1.0)
