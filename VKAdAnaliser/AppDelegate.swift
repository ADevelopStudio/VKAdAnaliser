//
//  AppDelegate.swift
//  VKAdAnaliser
//
//  Created by Dmitrii Zverev on 6/05/2016.
//  Copyright © 2016 Dmitrii Zverev. All rights reserved.
//

import UIKit
import VK_ios_sdk
import KVNProgress

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let loadingConfig = KVNProgressConfiguration()
        loadingConfig.statusColor = originalDarkGrey
        loadingConfig.circleStrokeBackgroundColor = UIColor.groupTableViewBackgroundColor()
        loadingConfig.circleStrokeForegroundColor = originalDarkGrey
        loadingConfig.lineWidth = 3
        loadingConfig.allowUserInteraction = false
        loadingConfig.successColor = originalDarkGrey
        loadingConfig.errorColor = UIColor.redColor()
        loadingConfig.statusFont = UIFont.systemFontOfSize(20)
        loadingConfig.minimumSuccessDisplayTime = 3
        loadingConfig.minimumErrorDisplayTime = 3
        KVNProgress.setConfiguration(loadingConfig)
        
        return true
    }

    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        if #available(iOS 9.0, *) {
            if let ss =  options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String {
                VKSdk.processOpenURL(url, fromApplication: ss)
            }
        }
        return true
    }
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        VKSdk.processOpenURL(url, fromApplication: sourceApplication)
        return true
    }
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

