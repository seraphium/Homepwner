//
//  ItemCell.swift
//  Homepwner
//
//  Created by Jackie Zhang on 16/3/8.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class ItemCell : BaseCell {
    

    @IBOutlet var indicatorView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet var notifyDateLabel: UILabel!

    @IBOutlet var doneButton: UIButton!

    var expired : Bool = false
 
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
      //  self.backgroundView?.backgroundColor = UIColor.clearColor()
    
    }
    
    let indicatorLayer = CAShapeLayer()
    var indicatorPath = UIBezierPath()

    
    private func initPath() {
        indicatorPath = UIBezierPath(ovalInRect: CGRect(x: 0, y: 13, width: 8, height: 8))

    }
    
    func initIndicatorView() {
        initPath()
        indicatorLayer.backgroundColor = UIColor.clearColor().CGColor
        indicatorLayer.path = indicatorPath.CGPath
        indicatorLayer.fillColor = UIColor.redColor().CGColor
        indicatorView.layer.addSublayer(indicatorLayer)
        
    }
    
    func updateCell(finished: Bool, expired: Bool){
        
        //create content/animation layer apperance
        createView(contentLayer)
        createView(animationLayer)
        
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
