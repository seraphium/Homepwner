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

    @IBOutlet weak var dateToNotifyLabel: UILabel!
    
    func updateLabels(){
        
        //update font setting
        let bodyFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        textField.font = bodyFont
        
        
    }
    
}
