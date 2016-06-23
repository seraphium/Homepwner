//
//  CalendarCell.swift
//  Easy Things
//
//  Created by Jackie Zhang on 16/6/23.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class CalendarCell : UICollectionViewCell {
    
    @IBOutlet var label: UILabel!
    
    @IBOutlet var markedView: UIView!
    @IBOutlet var markedViewWidth: NSLayoutConstraint!
    @IBOutlet var markedViewHeight: NSLayoutConstraint!
    
    var date: Date? {
        didSet {
            if date != nil {
                label.text = "\(date!.day)"
            } else {
                label.text = ""
            }
        }
    }
    
    var disabled: Bool = false {
        didSet {
            if disabled {
                alpha = 0.4
            } else {
                alpha = 1.0
            }
        }
    }
    
    var mark: Bool = false {
        didSet {
            if mark {
                markedView!.hidden = false
            } else {
                markedView!.hidden = true
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
      //  markedViewWidth!.constant = min(self.frame.width, self.frame.height)
       // markedViewHeight!.constant = min(self.frame.width, self.frame.height)
       // markedView!.layer.cornerRadius = min(self.frame.width, self.frame.height) / 2.0
    }

    
}
