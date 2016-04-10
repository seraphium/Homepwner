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
    var dateToNotify : NSDate
    let dateCreated : NSDate
    let itemKey : String
    var finished: Bool
    init(name: String, detail: String?, dateToNotify : NSDate){
        self.name = name
        self.detail = detail
        self.dateToNotify = dateToNotify
        self.dateCreated = NSDate()
        self.itemKey = NSUUID().UUIDString
        self.finished = false
        super.init()
    }
    
    convenience init(random : Bool = false, dateToNotify: NSDate) {
        if random {
            let adjective = ["Fluffy", "Rusty", "Shiny"]
            let nouns = ["Bear", "Spork", "Mac"]
            var idx = arc4random_uniform(UInt32(adjective.count))
            let randomAdjective = adjective[Int(idx)]
            idx = arc4random_uniform(UInt32(nouns.count))
            let randomNouns = nouns[Int(idx)]
            let randomName = "\(randomAdjective) \(randomNouns)"
            let randomSerialNumber = NSUUID().UUIDString.componentsSeparatedByString("-").first!
            
            self.init(name: randomName, detail: randomSerialNumber, dateToNotify: dateToNotify)
            
        } else{
            self.init(name: "New Item", detail: nil, dateToNotify: dateToNotify)
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(dateCreated, forKey: "dateCreated")
        aCoder.encodeObject(itemKey, forKey: "itemKey")
        aCoder.encodeObject(detail, forKey: "detail")
        aCoder.encodeObject(dateToNotify, forKey: "dateToNotify")
        aCoder.encodeObject(finished, forKey: "finished")

    }
    
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("name") as! String
        dateCreated = aDecoder.decodeObjectForKey("dateCreated") as! NSDate
        itemKey = aDecoder.decodeObjectForKey("itemKey") as! String
        detail = aDecoder.decodeObjectForKey("detail") as! String?
        name = aDecoder.decodeObjectForKey("name") as! String
        dateToNotify = aDecoder.decodeObjectForKey("dateToNotify") as! NSDate
        finished = aDecoder.decodeBoolForKey("finished")
        super.init()
    }
    
    
    
    
    
}