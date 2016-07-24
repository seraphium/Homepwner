//
//  ItemSectionHeaderView.swift
//  EasyToDo
//
//  Created by Jackie Zhang on 16/5/1.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class ItemSectionHeaderView: UIView {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var headerButton: UIButton!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override func awakeFromNib() {
        tintColor = AppDelegate.cellInnerColor
        titleLabel.textColor = AppDelegate.cellInnerColor
        headerLabel.textColor = AppDelegate.cellInnerColor
        
    }

}
