//
//  ItemTableHeaderView.swift
//  Easy Things
//
//  Created by Jackie Zhang on 16/6/29.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

protocol RefreshDelegate {
    func doRefresh(refreshView : ItemTableRefreshView)
}

class ItemTableRefreshView : UIView, UIScrollViewDelegate {
    
    @IBOutlet var headerTitle: UILabel!
    
    var scrollView : UIScrollView!
    
    var delegate : RefreshDelegate?
    
    var progress: CGFloat = 0.0
    
    var isRefresh = false
    
    override func awakeFromNib() {
        headerTitle.text = "swipe to show calendar"
    }
    
    func initScrollView(scrollView : UIScrollView) {
        self.scrollView = scrollView
        scrollView.delegate = self
        
        if let sv = scrollView.superview {
            self.frame = CGRectMake(0, -40, sv.frame.size.width, 40)
        } else {
            self.frame = CGRectMake(0, -40, scrollView.frame.size.width, 40)
            
        }
        
    }

    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        beginRefresh()

    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offY = max(-1*(scrollView.contentOffset.y+scrollView.contentInset.top),0)
        progress = min(offY / self.frame.size.height , 1.0)
        //print (progress)

    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if isRefresh && progress >= 1 {
            //do refresh work
            delegate?.doRefresh(self)
        }
    }
    
    func beginRefresh() {
        isRefresh = true
        //handling refresh animation
    }
    
    func endRefresh() {
        isRefresh = false


    }
    
    
}
