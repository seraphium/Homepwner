//
//  ResourceStore.swift
//  EasyToDo
//
//  Created by Jackie Zhang on 16/6/3.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class ResourceStore {
    private let cache = NSCache()
    
    func setResource(resource: AnyObject, forKey key: String) {
        cache.setObject(resource, forKey: key)
    }

    func getResource(key: String) -> AnyObject?{
        return cache.objectForKey(key)
    }
    
    func removeResource(key: String) {
        cache.removeObjectForKey(key)
    }
    
    func resourceURLForKey(key: String, suffix: String) ->NSURL {
        let documentDirectories = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory = documentDirectories.first!
        return documentDirectory.URLByAppendingPathComponent(key + suffix)
        
    }
    
}
