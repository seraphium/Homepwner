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
    let meteringColor : UIColor = AppDelegate.cellInnerColor
    
    //Maxmum metering count
    let maxMeteringArrayCount = 100
    
    var meteringWindowArray : [CGFloat]!
    
    let meteringInstanceWidth  = 3
    
    let meteringInstanceMaxHeight = 45
    
    override func drawRect(rect: CGRect) {
        drawBackground(rect)
        drawMetering(rect)
    }
    
    override func awakeFromNib() {
        initMetering()
    }
    
    func initMetering() {
        meteringWindowArray = [CGFloat].init(count: maxMeteringArrayCount, repeatedValue: CGFloat(0.0))

    }
    func drawBackground(rect: CGRect){
        //draw background
        layer.cornerRadius = 5
        layer.borderWidth = 2
        layer.borderColor = baseColor.CGColor
        layer.backgroundColor = AppDelegate.cellColor.CGColor
        layer.masksToBounds = true
        baseColor.setStroke()
        
        let path = UIBezierPath()
        
        path.lineWidth = 1
        path.moveToPoint(CGPoint(x: 0, y: rect.height / 2))
        path.addLineToPoint(CGPoint(x: rect.width, y: rect.height / 2))
        path.stroke()
    }
    
    func drawMetering(rect: CGRect){
        for i in 1 ..< maxMeteringArrayCount {
            
            let height = meteringWindowArray[i - 1] * CGFloat(meteringInstanceMaxHeight)
            
            let path = UIBezierPath()
            path.lineWidth = CGFloat(meteringInstanceWidth)
            path.moveToPoint(CGPoint(x: CGFloat(i * meteringInstanceWidth), y: rect.height / 2 + height))
            path.addLineToPoint(CGPoint(x: CGFloat(i * meteringInstanceWidth), y: CGFloat(rect.height / 2 - height)))
            meteringColor.setStroke()
            
            path.stroke()
        }
    }
    
    func updateMetering(factor: CGFloat) {
        
        //shift window array that bind to UI metering
        meteringWindowArray.removeFirst()
        meteringWindowArray.append(factor)
        
        setNeedsDisplay()
    
    }
}
