//
//  ImageStore.swift
//  Homepwner
//
//  Created by Jackie Zhang on 16/3/17.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit


class  ImageStore {
    let cache = NSCache()
    
    func setImage(image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key)
    }
    
    func imageForKey(key: String) -> UIImage? {
        return cache.objectForKey(key)  as? UIImage
    }
    
    func deleteImageForKey(key: String) {
        cache.removeObjectForKey(key)
    }
    
}