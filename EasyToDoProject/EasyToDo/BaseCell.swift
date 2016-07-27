//
//  BaseCell.swift
//  EasyToDo
//
//  Created by Jackie Zhang on 16/5/19.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//


import UIKit

class BaseCell : UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var containerView: UIView!    
    
    //layer for content view
    var contentLayer : CALayer {
        return containerView.layer
    }

    let cornerRadius = CGFloat(5.0)

    internal typealias CompletionHandler = () -> Void
    
    override func awakeFromNib() {
        super.awakeFromNib()
        InitCellViews()

        self.backgroundColor = UIColor.clearColor()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func createView(layer: CALayer)
    {
        layer.backgroundColor = AppDelegate.cellColor.CGColor
        layer.transform = transform3d()
    }
    
    func InitCellViews(){
        //create content/animation layer apperance
        createView(contentLayer)
    }
    
    //what's for?
    func transform3d() -> CATransform3D {
        var transform = CATransform3DIdentity
        transform.m34 = 2.5 / -2000;
        return transform
    }
    
    func setCellCornerRadius(expanded: Bool, animated: Bool)
    {
        if (animated) {
            let from = CGFloat(expanded ? cornerRadius : 0)
            let to = CGFloat(expanded ? 0 : cornerRadius)
            contentView.addCornerRadiusAnimation(from, to: to, duration: 0.5)
            containerView.addCornerRadiusAnimation(from, to: to, duration: 0.5)
             } else {
            contentView.layer.cornerRadius = cornerRadius
            containerView.layer.cornerRadius = cornerRadius
        }
        
        
    }

    
    
    func setupShadow()
    {
        
        //setup Shadow
        containerView.layer.shadowOffset = CGSizeMake(0, 2)
        containerView.layer.shadowColor = AppDelegate.cellInnerColor.CGColor
        containerView.layer.shadowRadius = 3
        containerView.layer.shadowOpacity = 0.5
        
        clipsToBounds = false
        
    }


}