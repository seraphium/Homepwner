//
//  ImageStore.swift
//  Homepwner
//
//  Created by Jackie Zhang on 16/3/17.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit


class  ImageStore : ResourceStore {
    
    let kSuffix = ".png"
    
    func setImage(image: UIImage, forKey key: String) {
        self.setResource(image, forKey: key)
        
        //create full url for image
        let imageURL = resourceURLForKey(key, suffix: kSuffix)
        
        if let data = UIImageJPEGRepresentation(image, 0.5) {
            //write image data to URL
            data.writeToURL(imageURL, atomically: true)
        }
        
    }
    
    func imageForKey(key: String) -> UIImage? {
        if let existingImage = getResource(key) as? UIImage {
            return existingImage
        }
        
        let imageURL = resourceURLForKey(key, suffix: kSuffix)
        guard let imageFromDisk = UIImage(contentsOfFile: imageURL.path!) else {
            return nil
        }
        setResource(imageFromDisk, forKey: key)
        return imageFromDisk
    }
    
    func deleteImageForKey(key: String) {
        
        removeResource(key)
        let imageURL = resourceURLForKey(key, suffix: kSuffix)
        do {
           try NSFileManager.defaultManager().removeItemAtURL(imageURL)
            print ("removed image for key:" + key)
        } catch let deleteError {
            print ("error removing image from disk:\(deleteError)")
        }

    }
    


}