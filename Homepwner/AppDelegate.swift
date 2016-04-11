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
    let imageStore =  ImageStore()
    
    
    //-- MARK: notification handling
    func notificationHandleFinish(application: UIApplication, forNotification notification: UILocalNotification) {
        itemStore.finishItemNotification(notification)
    }
    
    func notificationHandleDetail(application: UIApplication, forNotification notification: UILocalNotification) {
       //todo: present detail view controller
        let navController = window!.rootViewController as! UINavigationController
        let detailVC =  navController.storyboard!.instantiateViewControllerWithIdentifier("detailVC") as! DetailViewController
        
        var userInfo = notification.userInfo!
        let key = userInfo["itemKey"] as! String
        if let item = itemStore.getItem(key, finished: false){
            detailVC.item = item
            detailVC.imageStore = imageStore
            navController.pushViewController(detailVC, animated: true)
        }

    }
    
    func showNotificationAlertController(application:UIApplication, forNotification notification: UILocalNotification)
    {
        let alertController = UIAlertController(title: notification.alertTitle, message: notification.alertBody, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Finish", style: .Default) {
            (alertAction) -> Void in
                self.notificationHandleFinish(application, forNotification: notification)
            })
        alertController.addAction(UIAlertAction(title: "Detail", style: .Default) {
            (alertAction) -> Void in
                self.notificationHandleDetail(application, forNotification: notification)
            })

        alertController.addAction(UIAlertAction(title: "Ignore", style: .Cancel, handler: nil))
        let navController = window!.rootViewController as! UINavigationController
        let topController = navController.topViewController
        topController!.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        
        print ("identifier=\(identifier)")
        if let identify = identifier {
            switch identify {
            case "finished":
                print ("finished")
                itemStore.finishItemNotification(notification)
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
    
  //-- MARK: App delegate logic
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        
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
        itemsController.imageStore = imageStore
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
        
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

