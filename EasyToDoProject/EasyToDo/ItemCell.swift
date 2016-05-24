//
//  ItemCell.swift
//  Homepwner
//
//  Created by Jackie Zhang on 16/3/8.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class ItemCell : BaseCell {
    
    @IBOutlet var foregroundView: UIView!
    @IBOutlet var foldView: UIView!

    @IBOutlet var indicatorView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet var notifyDateLabel: UILabel!

    @IBOutlet var doneButton: UIButton!

    var expired : Bool = false
 
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    let indicatorLayer = CAShapeLayer()
    var indicatorPath = UIBezierPath()

    //give row edge inset for item row
    override func layoutSubviews() {
        super.layoutSubviews()

        let f = contentView.frame
        let fr = UIEdgeInsetsInsetRect(f, UIEdgeInsetsMake(5, 5, 5, 5))
        contentView.frame = fr
        
    }

    //find and replace default Reorder Control view
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        for view in subviews {
            if let reorderControlView = view.findSubViewWithString("ReorderControl") {
                for subview in reorderControlView.subviews as! [UIImageView] {
                    if subview.isKindOfClass(UIImageView) {
                    subview.image = UIImage(named: "moveicon")
                        break
                    }
                }
            }

        }
    }

    //init expired item indicator view
    func initIndicatorView() {
        indicatorPath = UIBezierPath(ovalInRect: CGRect(x: 0, y: 13, width: 8, height: 8))
        indicatorLayer.backgroundColor = UIColor.clearColor().CGColor
        indicatorLayer.path = indicatorPath.CGPath
        indicatorLayer.fillColor = UIColor.redColor().CGColor
        indicatorView.layer.addSublayer(indicatorLayer)
        
    }
    
    func updateCell(finished: Bool, expired: Bool){
        
        //finished item will not be "Done"able
        if (finished) {
            doneButton.alpha = 0.0
            doneButton.enabled = false
            textField.textColor = UIColor.whiteColor()
            contentView.alpha = 0.4
        } else {
            doneButton.alpha = 0.8
            doneButton.enabled = true
            textField.textColor = UIColor.whiteColor()
            contentView.alpha = 0.8
        }
        
        if expired { //expired notify item
            indicatorView.alpha = 1.0
            self.expired = true
        } else {
            indicatorView.alpha = 0.0
        }


        //update font setting
        let bodyFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        textField.font = bodyFont
        notifyDateLabel.textColor = UIColor.whiteColor()
        
    }
    
    
    
}


extension UIView {
    
    func findSubViewWithString(partialName: String) -> UIView? {
        
        if self.dynamicType.description().rangeOfString("Reorder") != nil {
            return self
        }
        
        for view in subviews as [UIView]
        {
                if let match = view.findSubViewWithString(partialName) {
                    return match
                }
                
        }
        
        return nil

    }


    func pb_takeSnapshot(frame: CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0.0)
        
        let context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, frame.origin.x * -1, frame.origin.y * -1)
        
        guard let currentContext = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        self.layer.renderInContext(currentContext)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
