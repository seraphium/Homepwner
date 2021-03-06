//
//  ImageStore.swift
//  Homepwner
//
//  Created by Jackie Zhang on 16/3/17.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit
import AVFoundation


class  AudioStore : ResourceStore {
    
    let kSuffix = ".m4a"
    
    func audioURLForKey(key: String) -> NSURL? {
        return resourceURLForKey(key, suffix: kSuffix)
    }
    
    func hasAudioForURL(url: NSURL) -> Bool {
        do {
            _ = try AVAudioPlayer(contentsOfURL: url)
        } catch {
            return false
        }
        return true
    }

    func deleteAudioForKey(key: String) {
        
        //removeResource(key)
        let audioURL = resourceURLForKey(key, suffix: kSuffix)
        do {
            try NSFileManager.defaultManager().removeItemAtURL(audioURL)
            print("removed audio for key:" + key)
        } catch let deleteError {
            print ("error removing audio file from disk:\(deleteError)")
        }
        
    }
}