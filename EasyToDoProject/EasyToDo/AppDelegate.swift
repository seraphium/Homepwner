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
    static let imageStore =  ImageStore()
    
    static let RepeatTime : [String] = ["不重复", "每天",  "每周" , "每月", "每年"]

    static let backColor = UIColor(red: 206.0/255.0, green: 203.0/255.0, blue: 188.0/255.0, alpha: 1.0)
    static let cellColor = UIColor(red: 169.0/255.0, green: 167.0/255.0, blue: 158.0/255.0, alpha: 0.8)
    static let cellInnerColor = UIColor(red: 206.0/255.0, green: 203.0/255.0, blue: 188.0/255.0, alpha: 0.7)

    func finishItemNotification(notification : UILocalNotification) -> Item? {
        var userInfo = notification.userInfo!
        let key = userInfo["itemKey"] as! String
        if let item = self.itemStore.getItem(key, finished: false){
            self.itemStore.finishItem(item)
            let app = UIApplication.sharedApplication()
            app.cancelLocalNotification(notification)
            app.applicationIconBadgeNumber -= 1
            
            return item
        }
        
        return nil
    }
    
    
    //-- MARK: notification handling on alert dialog
    func notificationHandleFinish(application: UIApplication, forNotification notification: UILocalNotification) {
        if let item = finishItemNotification(notification) {
            let navController = window!.rootViewController as! UINavigationController
            if let ivc = navController.topViewController as? ItemsViewController {
                ivc.finishItemReload(item)
            }
        }
        
    }
    
    
    func notificationHandleIgnore(application: UIApplication, forNotification notification: UILocalNotification) {
        let navController = window!.rootViewController as! UINavigationController
        if let ivc = navController.topViewController as? ItemsViewController {
            ivc.tableView.reloadData();
        }
    }

    
    func showNotificationAlertController(application:UIApplication, forNotification notification: UILocalNotification)
    {
        let alertController = UIAlertController(title: notification.alertTitle, message: notification.alertBody, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Finish", style: .Default) {
            (alertAction) -> Void in
                self.notificationHandleFinish(application, forNotification: notification)
            })

        alertController.addAction(UIAlertAction(title: "Ignore", style: .Cancel) {
            (alertAction) -> Void in
            self.notificationHandleIgnore(application, forNotification: notification);
            })
        let navController = window!.rootViewController as! UINavigationController
        let topController = navController.topViewController
        topController!.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MARK: app notification handling logic
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        if let identify = identifier {
            switch identify {
            case "finished":
                print ("finished")
                finishItemNotification(notification)
            case "detail":
                showNotificationAlertController(application, forNotification: notification)
            case "ignore":
                print ("Ignore")
            default:
                print ("others")
            }
        }
        
        
        completionHandler()
    }
    
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        print("received local notification")
        
       showNotificationAlertController(application, forNotification: notification)
    }
    
    static func cancelNotification(item: Item) {
        let app = UIApplication.sharedApplication()
        //clear all old notify
        let oldNotify = app.scheduledLocalNotifications
        
        //cancel the old notify for this item
        for notif in oldNotify! {
            let itemKey =  notif.userInfo!["itemKey"] as! String
            if itemKey == item.itemKey {
                app.cancelLocalNotification(notif)
            }
        }

    }
    
    static func scheduleNotifyForDate(date: NSDate, withRepeatInteval repeatInterval: NSCalendarUnit?, onItem item: Item, withTitle title: String, withBody body:String?){
        
        cancelNotification(item)
        
        let newNotify = UILocalNotification()
        newNotify.fireDate = date
        newNotify.timeZone = NSTimeZone.localTimeZone()
        
        if let interval = repeatInterval {
            newNotify.repeatInterval = interval
            
        }
        newNotify.soundName = UILocalNotificationDefaultSoundName
        newNotify.alertTitle = title
        newNotify.alertBody = body
        newNotify.alertAction = "OK"
        newNotify.applicationIconBadgeNumber = 1
        newNotify.category = "MyNotification"
        
        var userInfo : [NSObject:AnyObject] = [NSObject:AnyObject]()
        userInfo["itemKey"] = item.itemKey
        newNotify.userInfo = userInfo
        
        let app = UIApplication.sharedApplication()
        app.scheduleLocalNotification(newNotify)
        
        print ("scheduled local notification")
    }

    static func NSCalenderUnitFromRepeatInterval(repeatInterval: Int) -> NSCalendarUnit?{
        var interval: NSCalendarUnit?
        switch repeatInterval {
        case 0:
            interval = nil
        case 1:
            interval = NSCalendarUnit.Day
        case 2:
            interval = NSCalendarUnit.WeekOfYear
        case 3:
            interval = NSCalendarUnit.Month
        default:
            interval = NSCalendarUnit()
        }
        return interval

    }
    
  //-- MARK: App delegate logic
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
       // application.applicationIconBadgeNumber = 0;
        if let notification = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] {
            showNotificationAlertController(application, forNotification: notification as! UILocalNotification)
            
        }
        
        if (UIApplication.instancesRespondToSelector(#selector(UIApplication.registerUserNotificationSettings(_:)))) {
            
            //TODO: should add response to local notification here
            
            
            let userAction1 = UIMutableUserNotificationAction()
            userAction1.identifier = "finished"
            userAction1.title = "Finished"
            userAction1.activationMode = .Background
            userAction1.authenticationRequired = true
            
            let userAction2 = UIMutableUserNotificationAction()
            userAction2.identifier = "detail"
            userAction2.title = "Detail"
            userAction2.activationMode = .Foreground
            userAction2.authenticationRequired = true
            
            let userAction3 = UIMutableUserNotificationAction()
            userAction3.identifier = "ignore"
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
        
        
        
        //Access the ItemsViewController and set its datasource
        let navController = window!.rootViewController as! UINavigationController
        let itemsController = navController.topViewController as! ItemsViewController
        itemsController.itemStore = itemStore
        itemsController.imageStore = AppDelegate.imageStore
        return true
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
        let navController = window!.rootViewController as! UINavigationController
        if let itemsController = navController.topViewController as? ItemsViewController {
            itemsController.tableView.reloadData()
        }
        //clear badge number 
        application.applicationIconBadgeNumber = 0;
        
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

