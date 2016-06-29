//
//  ItemTableHeaderView.swift
//  Easy Things
//
//  Created by Jackie Zhang on 16/6/29.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class ItemTableHeaderView : UIView {
    
    @IBOutlet var headerTitle: UILabel!
    
    override func awakeFromNib() {
        headerTitle.text = "swipe to show calendar"
    }
    
}
