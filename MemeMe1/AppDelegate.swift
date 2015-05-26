//
//  AppDelegate.swift
//  MemeMe1
//
//  Created by Vishruti Kekre on 5/23/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit

 @UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var memes = [Meme]()
    var savedMemes = [Meme]()
    let defaults = NSUserDefaults.standardUserDefaults()
    let memesDataKey = "memesDataKey"
    


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    
}

