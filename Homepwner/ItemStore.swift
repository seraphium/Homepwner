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
        let newItem = Item(random: random, dateToNotify: NSDate(), finished: finished)
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
    
    func MoveItemAtIndex( fromIndex: Int, toIndex: Int, finished: Bool) {
        if fromIndex == toIndex {
            return ;
        }
        var items : [Item]
        if (finished) {
            items = allItemsDone
            } else {
            items = allItemsUnDone
        }
        let movedItem = items[fromIndex]
        items.removeAtIndex(fromIndex)
        items.insert(movedItem, atIndex: toIndex)

        
    }
    
    //save to file
    func saveChanges() -> Bool {
        print ("saving items to \(unDoneItemArchiveURL.path!)")
        print ("saving items to \(doneItemArchiveURL.path!)")

        return  NSKeyedArchiver.archiveRootObject(allItemsUnDone, toFile: unDoneItemArchiveURL.path!)
        return  NSKeyedArchiver.archiveRootObject(allItemsDone, toFile: doneItemArchiveURL.path!)

    }
    
}


