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
        newItemName.font = UIFont(name: "HelveticaNeue", size: 18.0)
        newItemName.textColor = AppDelegate.cellColor
        newItemName.tintColor = AppDelegate.cellColor
        newItemName.placeholder = NSLocalizedString("ItemListClickToAddLabel", comment: "")
            
        newItemName.attributedPlaceholder = NSAttributedString(string:newItemName.placeholder!, attributes:[NSForegroundColorAttributeName: AppDelegate.cellColor])
        
        initAddButtonLayer()
        
        containerView.backgroundColor = AppDelegate.darkColor
        
        newItemName.delegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupShadow()
      //  setCellCornerRadius(false, animated: false)
     //   initTextFieldBottomLine()

    }
    
    override func textFieldShouldReturn(textField: UITextField) -> Bool {
        super.textFieldShouldReturn(textField)
        addNewItemBtn.sendActionsForControlEvents(.TouchUpInside)
        return true
    }
    
    func initTextFieldBottomLine() {
        //newItemName.layer.sublayers = nil
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = AppDelegate.cellColor.CGColor
        border.frame = CGRect(x: 0, y:newItemName.frame.size.height + width + 1, width:  newItemName.frame.size.width, height: newItemName.frame.size.height)
        
        border.borderWidth = width
        newItemName.layer.addSublayer(border)
        newItemName.layer.masksToBounds = true
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
        
        //common part to resize and position the shape layer
        bezierPath.applyTransform(CGAffineTransformMakeScale(CGFloat(0.8), CGFloat(0.8)))
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.clearColor().CGColor
        layer.path = bezierPath.CGPath
        layer.fillColor = AppDelegate.cellColor.CGColor
        layer.fillRule = kCAFillRuleEvenOdd
        layer.bounds = CGPathGetPathBoundingBox(bezierPath.CGPath)
        layer.position = CGPoint(x: CGRectGetMidX(addNewItemBtn.bounds), y: CGRectGetMidY(addNewItemBtn.bounds))
        addNewItemBtn.layer.addSublayer(layer)

        
    }
}