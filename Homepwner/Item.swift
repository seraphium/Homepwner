//
//  Item.swift
//  Homepwner
//
//  Created by Jackie Zhang on 16/2/29.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit


class Item: NSObject {
    var name : String
    var valueInDollars : Int
    var serialNumber : String?
    let dateCreated: NSDate
    
    init(name: String, serialNumber: String?, valueInDollars : Int){
        self.name = name
        self.valueInDollars = valueInDollars
        self.serialNumber = serialNumber
        self.dateCreated = NSDate()
        super.init()
    }
    
    convenience init(random : Bool = false) {
        if random {
            let adjective = ["Fluffy", "Rusty", "Shiny"]
            let nouns = ["Bear", "Spork", "Mac"]
            var idx = arc4random_uniform(UInt32(adjective.count))
            let randomAdjective = adjective[Int(idx)]
            idx = arc4random_uniform(UInt32(nouns.count))
            let randomNouns = nouns[Int(idx)]
            let randomName = "\(randomAdjective) \(randomNouns)"
            let randomValue  = Int(arc4random_uniform(100))
            let randomSerialNumber = NSUUID().UUIDString.componentsSeparatedByString("-").first!
            
            self.init(name: randomName, serialNumber: randomSerialNumber, valueInDollars: randomValue)
            
        } else{
            self.init(name: "", serialNumber: nil, valueInDollars: 0)
        }
    }
}