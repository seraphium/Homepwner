 //
//  Item.swift
//  Homepwner
//
//  Created by Jackie Zhang on 16/2/29.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit


class Item: NSObject, NSCoding {
    var name : String
    var detail : String?
    var dateToNotify : NSDate?
    var repeatInterval : Int
    let dateCreated : NSDate
    let itemKey : String
    var finished: Bool
    var expanded: Bool
    init(itemkey: String?, name: String, detail: String?, dateToNotify : NSDate?, repeatInterval: Int,finished: Bool){
        self.name = name
        self.detail = detail
        self.dateToNotify = dateToNotify
        self.repeatInterval = repeatInterval
        self.dateCreated = NSDate()
        if let key = itemkey {
            self.itemKey = key
        } else {
            self.itemKey = NSUUID().UUIDString

        }
        self.finished = finished
        self.expanded = false
        super.init()
    }
    
    convenience init(itemkey: String?, dateToNotify: NSDate?, repeatInterval: Int,finished: Bool) {
            let newItemString = NSLocalizedString("NewItemName", comment: "New item default name")

        self.init(itemkey: itemkey, name: newItemString, detail: nil, dateToNotify: dateToNotify, repeatInterval: repeatInterval,finished: finished)
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(dateCreated, forKey: "dateCreated")
        aCoder.encodeObject(itemKey, forKey: "itemKey")
        aCoder.encodeObject(detail, forKey: "detail")
        aCoder.encodeObject(dateToNotify, forKey: "dateToNotify")
        aCoder.encodeObject(repeatInterval, forKey: "repeatInterval")

        aCoder.encodeObject(finished, forKey: "finished")
        aCoder.encodeObject(finished, forKey: "expanded")


    }
    
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("name") as! String
        dateCreated = aDecoder.decodeObjectForKey("dateCreated") as! NSDate
        itemKey = aDecoder.decodeObjectForKey("itemKey") as! String
        detail = aDecoder.decodeObjectForKey("detail") as! String?
        name = aDecoder.decodeObjectForKey("name") as! String
        dateToNotify = aDecoder.decodeObjectForKey("dateToNotify") as! NSDate?
        repeatInterval = aDecoder.decodeObjectForKey("repeatInterval") as! Int

        finished = aDecoder.decodeObjectForKey("finished") as! Bool
        expanded = aDecoder.decodeObjectForKey("expanded") as! Bool
        super.init()
    }
    
    
    
    
    
}