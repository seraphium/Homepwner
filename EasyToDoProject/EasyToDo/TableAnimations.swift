//
//  TableAnimations.swift
//  EasyToDo
//
//  Created by Jackie Zhang on 16/5/14.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit
class TableAnimations {
    class func getAnimationOpacity() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = 1
        animation.removedOnCompletion = true
        return animation
    }
    
    class func getAnimationMove(from:AnyObject?, to:AnyObject?) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "position")
        animation.fromValue = from
        animation.toValue = to
        animation.duration = 1
        animation.removedOnCompletion = true
        return animation
    }
    
}
