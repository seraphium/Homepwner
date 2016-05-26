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

    @IBOutlet weak var foldAnimationView: UIView!
    
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
    
    func updateCell(expanded: Bool, finished: Bool, expired: Bool){
        
        self.foldView.hidden = !expanded

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
    
    //MARK: - animation setup
    //removed existing animationViews
    private func removeImageItemsFromAnimationView(view: UIView?) {
        
        guard let animationView = view else {
            return
        }
        
        animationView.subviews.forEach({ $0.removeFromSuperview() })
    }
    
    //prepare containerView snapsho timage for animation
    func addImageItemsToAnimationView(sourceView : UIView, destView: UIView?) {
        sourceView.alpha = 1;
        let contSize    = sourceView.bounds.size
        let image       = sourceView.pb_takeSnapshot(CGRect(x: 0, y: 0, width: contSize.width, height: contSize.height))
        let imageView   = UIImageView(image: image)
        imageView.tag   = 0
        destView?.addSubview(imageView)
        
    }
    
    //MARK: open animation
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
        
        animationLayer.addAnimation(slideAnimation, forKey: "rotation.x")
    }
    
    func openAnimation(delay:NSTimeInterval,completion: CompletionHandler?) {
        
        removeImageItemsFromAnimationView(animationView)
        addImageItemsToAnimationView(containerView, destView: animationView)
        
        animationView.alpha = 1;
        containerView.alpha = 0;
        
        let timing                = kCAMediaTimingFunctionEaseIn
        // let from: CGFloat         = -containerView.bounds.size.width
        //let to: CGFloat           = 0
        
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
    
    //MARK: - Fold animation
    func foldingAnimation(timing: String, from: CGFloat, to: CGFloat, duration: NSTimeInterval, delay:NSTimeInterval) {
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation.x")
        rotateAnimation.timingFunction      = CAMediaTimingFunction(name: timing)
        rotateAnimation.fromValue           = (from)
        rotateAnimation.toValue             = (to)
        rotateAnimation.duration            = duration
        rotateAnimation.delegate            = self;
        rotateAnimation.fillMode            = kCAFillModeForwards
        rotateAnimation.removedOnCompletion = false;
        rotateAnimation.beginTime           = CACurrentMediaTime() + delay
        
        foldAnimationView.layer.addAnimation(rotateAnimation, forKey: "folding")
    }
    
    func expandAnimation(delay:NSTimeInterval,completion: CompletionHandler?) {
        
        foldView.hidden = false
        
        removeImageItemsFromAnimationView(foldAnimationView)
        addImageItemsToAnimationView(foldView, destView: foldAnimationView)
//        foldAnimationView.layer.anchorPoint = CGPoint(x: 0.5, y: 0)

        foldView.alpha = 0
        foldAnimationView.alpha = 1.0
        foldAnimationView.layer.shouldRasterize = true
        let delay: NSTimeInterval = 0
        let timing                = kCAMediaTimingFunctionEaseIn
        let from: CGFloat         = CGFloat(-M_PI / 2)
        let to: CGFloat           = 0
        let duration              = 0.5

        foldingAnimation(timing, from: from, to: to, duration: duration, delay: delay)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.foldAnimationView?.alpha = 0
            self.foldAnimationView.layer.removeAllAnimations()
            self.foldAnimationView.layer.shouldRasterize = false
            self.foldView.alpha  = 1
            completion?()
        }
    }
    
    
    func unExpandAnimation(delay:NSTimeInterval,completion: CompletionHandler?) {
        
        removeImageItemsFromAnimationView(foldAnimationView)
        addImageItemsToAnimationView(foldView, destView: foldAnimationView)
        
        foldView.alpha = 0
        foldAnimationView.alpha = 1.0
        foldAnimationView.layer.shouldRasterize = true
        let delay: NSTimeInterval = 0
        let timing                = kCAMediaTimingFunctionEaseIn
        let from: CGFloat         = 0
        let to: CGFloat           = CGFloat(-M_PI / 2)
        let duration              = 0.5
        
        foldingAnimation(timing, from: from, to: to, duration: duration, delay: delay)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.foldAnimationView?.alpha = 0
            self.foldAnimationView.layer.removeAllAnimations()
            self.foldAnimationView.layer.shouldRasterize = false
            self.foldView.alpha  = 0
            self.foldView.hidden = true

            completion?()
        }
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
