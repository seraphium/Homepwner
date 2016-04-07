//
//  AppDelegate.swift
//  Homepwner
//
//  Created by Jackie Zhang on 16/2/29.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let itemStore = ItemStore()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        if (UIApplication.instancesRespondToSelector(#selector(UIApplication.registerUserNotificationSettings(_:)))) {
            
            let userAction1 = UIMutableUserNotificationAction()
            userAction1.identifier = "userAction1"
            userAction1.title = "Finished"
            userAction1.activationMode = .Background
            userAction1.authenticationRequired = true
            
            let userAction2 = UIMutableUserNotificationAction()
            userAction2.identifier = "userAction2"
            userAction2.title = "Detail"
            userAction2.activationMode = .Foreground
            userAction2.authenticationRequired = true
            
           let userAction3 = UIMutableUserNotificationAction()
            userAction3.identifier = "userAction2"
            userAction3.title = "Ignore"
            userAction3.activationMode = .Background
            userAction3.authenticationRequired = true
            userAction3.destructive = true
            
            let userCategory = UIMutableUserNotificationCategory()
            userCategory.identifier = "MyNotification"
            userCategory.setActions([userAction1, userAction3], forContext: .Minimal)
            userCategory.setActions([userAction1, userAction2, userAction3], forContext: .Default)

          //  application.registerForRemoteNotifications()
            let setting = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound],
                                                     categories: NSSet(array: [userCategory]) as? Set<UIUserNotificationCategory>)
            application.registerUserNotificationSettings(setting)
            
          
        }
        
        //Create Image Store
        let imageStore =  ImageStore()
        
        //Access the ItemsViewController and set its datasource
        let navController = window!.rootViewController as! UINavigationController
        let itemsController = navController.topViewController as! ItemsViewController
        itemsController.itemStore = itemStore
        itemsController.imageStore = imageStore
        return true
    }

    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        
        print ("identifier=\(identifier)")
        
        
        completionHandler()
    }
    
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        print("received local notification")
        
       let alertController = UIAlertController(title: notification.alertTitle, message: notification.alertBody, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "确定", style: .Default) {
            (alertAction) -> Void in
           
            })
        alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        let navController = window!.rootViewController as! UINavigationController
        let topController = navController.topViewController
        topController!.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        let success = itemStore.saveChanges()
        if (success) {
            print ("saved all items")
        } else{
            print ("saving all items failed")
        }
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
       // application.cancelAllLocalNotifications()
        //application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

