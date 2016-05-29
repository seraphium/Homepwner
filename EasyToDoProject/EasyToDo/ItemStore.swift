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
    let MaxItemInUndone = 5
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
        let newItem = Item(random: random, dateToNotify: nil, repeatInterval: 0,finished: finished)
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
        var actualToIndex = toIndex
        let item = allItemsUnDone[fromIndex]
        allItemsUnDone.removeAtIndex(fromIndex)
        if finishing == true {
            //remove item in Done list if items exceed
            if allItemsDone.count >= MaxItemInUndone {
                allItemsDone.removeAtIndex(0)
                actualToIndex -= 1
            }
            allItemsDone.insert(item, atIndex: actualToIndex)
        } else {
            allItemsUnDone.insert(item, atIndex: actualToIndex)
        }

    }

    


    
    func finishItem(item : Item) -> Int {
        let sourceIndex = self.allItemsUnDone.indexOf(item)
        //if in repeat notify, update dateToNotify and not finish item actually
        if item.repeatInterval != 0 {
            if let date = item.dateToNotify {
                let unit = AppDelegate.NSCalenderUnitFromRepeatInterval(item.repeatInterval)
                if let u = unit {
                    //create new notify date according to current notify date + interval
                    if let newDate = NSCalendar.currentCalendar().dateByAddingUnit(u, value: 1, toDate: date, options: NSCalendarOptions(rawValue: 0))
                    { //recreate notify for repeat notify
                        item.dateToNotify = newDate
                        AppDelegate.scheduleNotifyForDate(newDate, withRepeatInteval: u, onItem: item, withTitle: item.name, withBody: item.detail)
                    }

                }
            }
            
            return sourceIndex!
        } else {
            //not repeat notify
            item.finished = true
            item.dateToNotify = nil
            
            let destIndexPath = self.allItemsDone.count
            if let source = sourceIndex {
                self.MoveItemAtIndex(source, toIndex: destIndexPath, finishing: true)
            }
            return destIndexPath
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


