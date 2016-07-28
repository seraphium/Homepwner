//
//  ItemTableHeaderView.swift
//  Easy Things
//
//  Created by Jackie Zhang on 16/6/29.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class ItemTableRefreshView : UIView {
    
    @IBOutlet var headerTitle: UILabel!
    
    var scrollView : UIScrollView!
    
    let fixedHeight = CGFloat(80)
    
    override func awakeFromNib() {
        self.alpha = 1.0
        headerTitle.textColor = AppDelegate.cellColor
        headerTitle.text = NSLocalizedString("CalenderViewSwipeViewTitle", comment: "")
        self.backgroundColor = AppDelegate.calendarColor
        
    }
    
    func swipeDownRefresh() {
        headerTitle.text = NSLocalizedString("CalenderViewSwipeViewTitle", comment: "")
    }
    
    func swipeUpRefresh() {
        headerTitle.text = NSLocalizedString("CalenderViewSwipeHideTitle", comment: "")
    }
    
    
    func initFrame() {
        
        if let sv = scrollView.superview {
            self.frame = CGRectMake(0, -fixedHeight, sv.frame.size.width, fixedHeight)
        } else {
            self.frame = CGRectMake(0, -fixedHeight, scrollView.frame.size.width, fixedHeight)
            
        }
        
    }

      
    
}
