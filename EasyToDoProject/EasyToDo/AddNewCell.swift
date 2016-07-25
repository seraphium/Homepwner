//
//  AddNewCell.swift
//  Easy Things
//
//  Created by Jackie Zhang on 16/7/24.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class AddNewCell : BaseCell {
    
    @IBOutlet var newItemName: UITextField!
    
    @IBOutlet var addNewItemBtn: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        newItemName.backgroundColor = UIColor.clearColor()
        //update font setting
        let bodyFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        newItemName.font = bodyFont
        newItemName.textColor = AppDelegate.backColor
        newItemName.tintColor = AppDelegate.backColor
        newItemName.placeholder = NSLocalizedString("ItemListClickToAddLabel", comment: "")
            
        newItemName.attributedPlaceholder = NSAttributedString(string:newItemName.placeholder!, attributes:[NSForegroundColorAttributeName: AppDelegate.backColor])
        
        initAddButtonLayer()
        
        containerView.backgroundColor = AppDelegate.cellInnerColor

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupShadow()
        setCellCornerRadius(false, animated: false)
        

    }
    
    func initAddButtonLayer(){
        //// Group
        //// Group 2
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: 18.88, y: 12.5))
        bezierPath.addLineToPoint(CGPoint(x: 28.81, y: 12.5))
        bezierPath.addCurveToPoint(CGPoint(x: 30.54, y: 14.14), controlPoint1: CGPoint(x: 29.96, y: 12.5), controlPoint2: CGPoint(x: 30.54, y: 13.05))
        bezierPath.addLineToPoint(CGPoint(x: 30.54, y: 18.51))
        bezierPath.addLineToPoint(CGPoint(x: 18.88, y: 18.51))
        bezierPath.addLineToPoint(CGPoint(x: 18.88, y: 30.55))
        bezierPath.addLineToPoint(CGPoint(x: 13.84, y: 30.55))
        bezierPath.addCurveToPoint(CGPoint(x: 12.11, y: 28.83), controlPoint1: CGPoint(x: 12.69, y: 30.55), controlPoint2: CGPoint(x: 12.11, y: 29.98))
        bezierPath.addLineToPoint(CGPoint(x: 12.11, y: 18.51))
        bezierPath.addLineToPoint(CGPoint(x: 2.26, y: 18.51))
        bezierPath.addCurveToPoint(CGPoint(x: 0.45, y: 16.87), controlPoint1: CGPoint(x: 1.05, y: 18.51), controlPoint2: CGPoint(x: 0.45, y: 17.97))
        bezierPath.addLineToPoint(CGPoint(x: 0.45, y: 12.5))
        bezierPath.addLineToPoint(CGPoint(x: 12.11, y: 12.5))
        bezierPath.addLineToPoint(CGPoint(x: 12.11, y: 0.46))
        bezierPath.addLineToPoint(CGPoint(x: 17.15, y: 0.46))
        bezierPath.addCurveToPoint(CGPoint(x: 18.88, y: 2.18), controlPoint1: CGPoint(x: 18.3, y: 0.46), controlPoint2: CGPoint(x: 18.88, y: 1.04))
        bezierPath.addLineToPoint(CGPoint(x: 18.88, y: 12.5))
        bezierPath.closePath()
        bezierPath.miterLimit = 4;
        bezierPath.fill()
        
        let layer = CAShapeLayer()
        
        layer.backgroundColor = UIColor.clearColor().CGColor
        layer.path = bezierPath.CGPath
        layer.fillColor = AppDelegate.backColor.CGColor
        layer.fillRule = kCAFillRuleEvenOdd

        addNewItemBtn.layer.addSublayer(layer)

        
    }
}