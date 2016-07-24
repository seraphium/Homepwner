//
//  AddNewCell.swift
//  Easy Things
//
//  Created by Jackie Zhang on 16/7/24.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class AddNewCell : UITableViewCell {
    
    
    @IBOutlet var newItemName: UITextField!
    
    @IBOutlet var addNewItemBtn: UIButton!
    
    override func awakeFromNib() {
        backgroundColor = AppDelegate.backColor
        //update font setting
        let bodyFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        newItemName.font = bodyFont
        newItemName.tintColor = AppDelegate.cellColor

    }
}