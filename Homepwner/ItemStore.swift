//
//  ItemStore.swift
//  Homepwner
//
//  Created by Jackie Zhang on 16/2/29.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class ItemStore  {
    var allItemsUnDone = [Item]()
    var allItemsDone = [Item]()

    //archive path to save undone items
    let unDoneItemArchiveURL : NSURL = {
        let documentDirectories = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory = documentDirectories.first!
        return  documentDirectory.URLByAppendingPathComponent("itemsundone.archive")
        
    }()
    
    //archive path to save undone items
    let doneItemArchiveURL : NSURL = {
        let documentDirectories = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory = documentDirectories.first!
        return  documentDirectory.URLByAppendingPathComponent("itemsdone.archive")
        
    }()
    
    init() {
        if let archivedItemsUnDone =  NSKeyedUnarchiver.unarchiveObjectWithFile(unDoneItemArchiveURL.path!) as? [Item] {
            allItemsUnDone += archivedItemsUnDone
        }
        if let archivedItemsDone =  NSKeyedUnarchiver.unarchiveObjectWithFile(doneItemArchiveURL.path!) as? [Item] {
            allItemsDone += archivedItemsDone
        }
        
    }
    
    func getItem(itemKey: String, finished: Bool) -> Item? {
        if finished {
            for item in allItemsDone {
                if item.itemKey == itemKey {
                    return item
                }
            }
        }
        else {
            for item in allItemsUnDone {
                if item.itemKey == itemKey {
                    return item
                }
            }
        }
        return nil
    }
    
    func CreateItem(random random: Bool, finished: Bool) -> Item {
        let newItem = Item(random: random, dateToNotify: nil, finished: finished)
        if (finished){
            allItemsDone.append(newItem)
        } else {
            allItemsUnDone.append(newItem)
        }
        return newItem
    }
    
    func RemoveItem( item: Item) {
        if let index = allItemsUnDone.indexOf(item) {
            allItemsUnDone.removeAtIndex(index)
        } else if let index = allItemsDone.indexOf(item){
            allItemsDone.removeAtIndex(index)
        }
    }
    
    func MoveItemAtIndex( fromIndex: Int, toIndex: Int, finishing: Bool) {
        if finishing == false && (fromIndex == toIndex) {
            return ;
        }
        let item = allItemsUnDone[fromIndex]
        allItemsUnDone.removeAtIndex(fromIndex)
        if (finishing == true) {
            allItemsDone.insert(item, atIndex: toIndex)

        } else {
            allItemsUnDone.insert(item, atIndex: toIndex)
        }

    }

    
    func finishItemNotification(notification : UILocalNotification) {
        var userInfo = notification.userInfo!
        let key = userInfo["itemKey"] as! String
        if let item = self.getItem(key, finished: false){
            self.finishItem(item)
            let app = UIApplication.sharedApplication()
            app.cancelLocalNotification(notification)
            app.applicationIconBadgeNumber -= 1
        }
        
    }

    
    func finishItem(item : Item){
        item.finished = true
        item.dateToNotify = nil

        let destIndexPath = self.allItemsDone.count
        if let sourceIndex = self.allItemsUnDone.indexOf(item) {
            self.MoveItemAtIndex(sourceIndex, toIndex: destIndexPath, finishing: true)
        }
    }
    
    //save to file
    func saveChanges() -> Bool {
        print ("saving items to \(unDoneItemArchiveURL.path!)")
        print ("saving items to \(doneItemArchiveURL.path!)")

        let res = NSKeyedArchiver.archiveRootObject(allItemsUnDone, toFile: unDoneItemArchiveURL.path!)
        let res2 = NSKeyedArchiver.archiveRootObject(allItemsDone, toFile: doneItemArchiveURL.path!)
        return res && res2
    }
    
}


