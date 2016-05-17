//
//  ItemCell.swift
//  Homepwner
//
//  Created by Jackie Zhang on 16/3/8.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class ItemCell : UITableViewCell {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet var notifyDateLabel: UILabel!

    @IBOutlet var doneButton: UIButton!
    
    //view for content
    @IBOutlet weak var containerView: UIView!
    
    //view for showing animation for containerView
    @IBOutlet weak var animationView: UIView!
    
    var expired : Bool = false
    
    //removed existing animationViews
    private func removeImageItemsFromAnimationView() {
        
        guard let animationView = self.animationView else {
            return
        }
        
        animationView.subviews.forEach({ $0.removeFromSuperview() })
    }
    
    //prepare containerView snapsho timage for animation
    func addImageItemsToAnimationView() {
        containerView.alpha = 1;
        let contSize        = containerView.bounds.size
        let image = containerView.pb_takeSnapshot(CGRect(x: 0, y: 0, width: contSize.width, height: contSize.height))
        let imageView = UIImageView(image: image)
           imageView.tag = 0
        animationView?.addSubview(imageView)

    }
    
    
    func updateLabels(finished: Bool, expired: Bool){

        //finished item will not be "Done"able
        if (finished) {
            doneButton.alpha = 0.0
            doneButton.enabled = false
            textField.textColor = UIColor.grayColor()
        } else {
            doneButton.alpha = 1.0
            doneButton.enabled = true
            textField.textColor = UIColor.blackColor()
        }
        
        if expired { //expired notify item
            textField.textColor = UIColor.redColor()
            self.expired = true
        }



        //update font setting
        let bodyFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        textField.font = bodyFont
        
        notifyDateLabel.textColor = UIColor.grayColor()
        
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
