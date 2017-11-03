//
//  AppDelegate.swift
//  OJT
//
//  Created by Rob Hendriks on 10/05/16.
//  Copyright © 2016 Rob Hendriks. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
    UIApplication.sharedApplication().statusBarStyle = .Default
    UINavigationBar.appearance().tintColor = UIColor.tintColor()
    
    window?.tintColor = UIColor.tintColor()
    
    return true
  }
  
}
