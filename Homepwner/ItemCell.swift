//
//  ItemCell.swift
//  Homepwner
//
//  Created by Jackie Zhang on 16/3/8.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class ItemCell : UITableViewCell {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet var notifyDateLabel: UILabel!

    @IBOutlet var doneButton: UIButton!
    
    var expired : Bool = false
    
    func updateLabels(finished: Bool, expired: Bool){

        //finished item will not be "Done"able
        if (finished) {
            doneButton.alpha = 0.0
            doneButton.enabled = false
            textField.textColor = UIColor.grayColor()
        } else {
            doneButton.alpha = 1.0
            doneButton.enabled = true
            textField.textColor = UIColor.blackColor()
        }
        
        if expired { //expired notify item
            textField.textColor = UIColor.redColor()
            self.expired = true
        } else {
            textField.textColor = UIColor.blackColor()
            self.expired = false
        }
        



        //update font setting
        let bodyFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        textField.font = bodyFont
        
        notifyDateLabel.textColor = UIColor.grayColor()
        
    }
    
}
