//
//  NavigationProto.swift
//  VKShopping
//
//  Created by Dmitrii Zverev on 29/01/2016.
//  Copyright © 2016 Dmitrii Zverev. All rights reserved.
//

import UIKit

class NavigationProto: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        let backImage = UIImage(named: "black66percent")
        self.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.translucent = true
        self.navigationBar.tintColor = UIColor.whiteColor()
//        UINavigationBar.appearance().barTintColor = UIColor.darkGrayColor()
//        self.navigationItem.backBarButtonItem?.title = ""
//        
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        
    }

}
