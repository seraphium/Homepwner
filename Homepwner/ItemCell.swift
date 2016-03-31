//
//  ItemCell.swift
//  Homepwner
//
//  Created by Jackie Zhang on 16/3/8.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class ItemCell : UITableViewCell {
    @IBOutlet var nameLabel : UILabel!
    @IBOutlet var detailLabel : UILabel!
    @IBOutlet var dateToNotifyLabel : UILabel!
    var valueInDollar : Int!
    
    func updateLabels(){
        
        //update font setting
        let bodyFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        nameLabel.font = bodyFont
        dateToNotifyLabel.font = bodyFont
        
        let caption1Font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        detailLabel.font = caption1Font

        
    }
    
}
