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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        InitCellViews()
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