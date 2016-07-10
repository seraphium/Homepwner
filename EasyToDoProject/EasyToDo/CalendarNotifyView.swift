//
//  CalendarNotifyView.swift
//  Easy Things
//
//  Created by Jackie Zhang on 16/7/10.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class CalendarNotifyView : UIView {
    
    
    @IBOutlet var notifyLabel: UILabel!
    
    var scrollView : UIScrollView!

    
    let fixedHeight = CGFloat(20)
    
    override func awakeFromNib() {
        self.alpha = 0.0
        notifyLabel.textColor = AppDelegate.cellColor
        notifyLabel.text = NSLocalizedString("CalenderViewNotifyViewTitle", comment: "")
        self.backgroundColor = AppDelegate.cellInnerColor

    }

    func show() {
        self.alpha  = 0.6
    }
    
    func hide() {
        self.alpha = 0.0
    }
    
    func initFrame() {
        
        if let sv = scrollView.superview {
            self.frame = CGRectMake(0, 0, sv.frame.size.width, fixedHeight)
        } else {
            self.frame = CGRectMake(0, 0, scrollView.frame.size.width, fixedHeight)
            
        }
        
    }

}
