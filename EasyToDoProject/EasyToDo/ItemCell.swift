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
    
    //layer for content view
    var contentLayer : CALayer {
        return containerView.layer
    }
    
    //view for showing animation for containerView
    @IBOutlet weak var animationView: UIView!
    
    var expired : Bool = false
    
    internal typealias CompletionHandler = () -> Void

    
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
        let contSize    = containerView.bounds.size
        let image       = containerView.pb_takeSnapshot(CGRect(x: 0, y: 0, width: contSize.width, height: contSize.height))
        let imageView   = UIImageView(image: image)
        imageView.tag   = 0
        animationView?.addSubview(imageView)

    }
    
    func slideAnimation(timing: String, from: CGFloat, to: CGFloat, duration: NSTimeInterval, delay:NSTimeInterval, hidden:Bool) {
        
        let slideAnimation = CABasicAnimation(keyPath: "transform.rotation.x")
        slideAnimation.timingFunction      = CAMediaTimingFunction(name: timing)
        slideAnimation.fromValue           = (from)
        slideAnimation.toValue             = (to)
        slideAnimation.duration            = duration
        slideAnimation.delegate            = self;
        slideAnimation.fillMode            = kCAFillModeForwards
        slideAnimation.removedOnCompletion = false;
        slideAnimation.beginTime           = CACurrentMediaTime() + delay
        
        animationView.layer.addAnimation(slideAnimation, forKey: "translation.x")
    }
    
    func openAnimation(completion completion: CompletionHandler?) {
        
        removeImageItemsFromAnimationView()
        addImageItemsToAnimationView()
        
        animationView.alpha = 1;
        containerView.alpha = 0;
        
        let delay: NSTimeInterval = 0
        let timing                = kCAMediaTimingFunctionEaseIn
       // let from: CGFloat         = -containerView.bounds.size.width
       // let to: CGFloat           = 0
        
        let from: CGFloat         = CGFloat(-M_PI / 2)
        let to: CGFloat           = 0
        let hidden                = true
        let duration              = NSTimeInterval(0.5)

        slideAnimation(timing, from: from, to: to, duration: duration, delay: delay, hidden: hidden)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64((delay + duration) * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.animationView?.alpha = 0
            self.containerView.alpha  = 1
            completion?()
        }


    }
    
    func createContentView()
    {
        contentLayer.borderColor = UIColor.whiteColor().CGColor
        contentLayer.borderWidth = 1
        contentLayer.backgroundColor = UIColor.clearColor().CGColor
        contentLayer.cornerRadius = 5
        contentLayer.transform = transform3d()
    }
    
    
    
    //what's for?
    func transform3d() -> CATransform3D {
        var transform = CATransform3DIdentity
        transform.m34 = 2.5 / -2000;
        return transform
    }
  
    
    
    func updateCell(finished: Bool, expired: Bool){

        //finished item will not be "Done"able
        if (finished) {
            doneButton.alpha = 0.0
            doneButton.enabled = false
            textField.textColor = UIColor.whiteColor()
        } else {
            doneButton.alpha = 1.0
            doneButton.enabled = true
            textField.textColor = UIColor.whiteColor()
        }
        
        if expired { //expired notify item
            textField.textColor = UIColor.redColor()
            self.expired = true
        }

        //create content layer apperance
        createContentView()

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
