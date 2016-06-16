//
//  AudioMeteringView.swift
//  EasyToDo
//
//  Created by Jackie Zhang on 16/6/16.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

@IBDesignable class AudioMeteringView : UIView {
    
    let baseColor : UIColor = AppDelegate.cellInnerColor
    
    //stored the value to draw the rect in metering view
    var audioMeteringArray = [Int]()
    
    //Maxmum metering count
    let maxArrayCount = 50
    
    let meteringInstanceWidth  = 6
    
    let meteringInstanceMaxHeight = 45
    
    override func drawRect(rect: CGRect) {
        initBackground(rect)
        initDrawMetering(rect)
    }
    
    func initBackground(rect: CGRect){
        //draw background
        layer.cornerRadius = 5
        layer.borderWidth = 2
        layer.borderColor = baseColor.CGColor
        
        baseColor.setStroke()
        
        let path = UIBezierPath()
        
        path.lineWidth = 1
        path.moveToPoint(CGPoint(x: 0, y: rect.height / 2))
        path.addLineToPoint(CGPoint(x: rect.width, y: rect.height / 2))
        path.stroke()
    }
    
    func initDrawMetering(rect: CGRect){
        for i in 1 ..< maxArrayCount {
            let height = CGFloat(arc4random() % UInt32(meteringInstanceMaxHeight))
            let path = UIBezierPath()
            path.lineWidth = CGFloat(meteringInstanceWidth)
            path.moveToPoint(CGPoint(x: CGFloat(i * meteringInstanceWidth), y: rect.height / 2))
            path.addLineToPoint(CGPoint(x: CGFloat(i * meteringInstanceWidth), y: CGFloat(rect.height / 2 - height)))
            path.stroke()
        }
    }
}
