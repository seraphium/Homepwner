//
//  BaseCell.swift
//  EasyToDo
//
//  Created by Jackie Zhang on 16/5/19.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//


import UIKit

class BaseCell : UITableViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var animationView: UIView!
    
    //layer for content view
    var contentLayer : CALayer {
        return containerView.layer
    }
    //layer for content view
    var animationLayer : CALayer {
        return animationView.layer
    }

    internal typealias CompletionHandler = () -> Void
    
    //MARK: - Init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
        //  self.backgroundView?.backgroundColor = UIColor.clearColor()
        
    }

    //MARK: - animation setup
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
        
        animationLayer.addAnimation(slideAnimation, forKey: "rotation.x")
    }
    
    func openAnimation(delay:NSTimeInterval,completion: CompletionHandler?) {
        
        removeImageItemsFromAnimationView()
        addImageItemsToAnimationView()
        
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
    
    func createView(layer: CALayer)
    {

        layer.backgroundColor = UIColor(red: 169.0/255.0, green: 167.0/255.0, blue: 158.0/255.0, alpha: 0.8).CGColor
        layer.cornerRadius = 2
        layer.transform = transform3d()
    }
    
    func InitCellViews(){
        //create content/animation layer apperance
        createView(contentLayer)
        createView(animationLayer)
    }
    
    //what's for?
    func transform3d() -> CATransform3D {
        var transform = CATransform3DIdentity
        transform.m34 = 2.5 / -2000;
        return transform
    }
    

}