//
//  AudioMeteringView.swift
//  EasyToDo
//
//  Created by Jackie Zhang on 16/6/16.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

@IBDesignable class AudioMeteringView : UIView {
    
    override func drawRect(rect: CGRect) {
        
        layer.cornerRadius = 5
        layer.borderWidth = 2
        layer.borderColor = AppDelegate.cellInnerColor.CGColor
        
        AppDelegate.cellInnerColor.setStroke()
        let path = UIBezierPath()
        path.lineWidth = 1
        path.moveToPoint(CGPoint(x: 0, y: rect.height / 2))
        path.addLineToPoint(CGPoint(x: rect.width, y: rect.height / 2))
        path.stroke()
        
        
    }
}
