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

    
    override func awakeFromNib() {
        self.alpha = 0.0
        notifyLabel.textColor = AppDelegate.cellColor
        notifyLabel.text = NSLocalizedString("CalenderViewNotifyViewTitle", comment: "")
        self.backgroundColor = AppDelegate.cellInnerColor

    }

    func show() {
        self.alpha  = 1.0
    }
    
    func hide() {
        self.alpha = 0.0
    }
    


}
