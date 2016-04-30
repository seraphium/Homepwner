//
//  ImageScrollView.swift
//  Homepwner
//
//  Created by Jackie Zhang on 16/4/26.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class ImageScrollView : UIScrollView {
    var imageView: UIImageView!
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        // center the zoom view as it becomes smaller than the size of the screen
        let boundsSize = self.bounds.size
        var frameToCenter = self.imageView.frame
        // center horizontally
        if (frameToCenter.size.width < boundsSize.width){
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
        }else{
            frameToCenter.origin.x = 0;
        } // center vertically
        if (frameToCenter.size.height < boundsSize.height)
        {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
        }
        else{
            frameToCenter.origin.y = 0;
        }
        
        self.imageView.frame = frameToCenter;


    }
    
}


