//
//  ImageStore.swift
//  Homepwner
//
//  Created by Jackie Zhang on 16/3/17.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit


class  AudioStore : ResourceStore {
    
    let kSuffix = ".caf"
    
    func audioURLForKey(key: String) -> NSURL? {
        return resourceURLForKey(key, suffix: kSuffix)
    }


}