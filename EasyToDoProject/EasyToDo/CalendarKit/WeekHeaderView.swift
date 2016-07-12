//
//  WeekHeaderView.swift
//  Calendar
//
//  Created by Lancy on 02/06/15.
//  Copyright (c) 2015 Lancy. All rights reserved.
//

import UIKit

class WeekHeaderView: UICollectionReusableView {

    @IBOutlet var labels: [UILabel]!
    
    let formatter = NSDateFormatter()
    
    override func awakeFromNib() {
        self.backgroundColor = AppDelegate.cellInnerColor
        if labels.count == formatter.shortWeekdaySymbols.count {
            for var i = 0; i < formatter.shortWeekdaySymbols.count; i += 1 {
                let weekDayString = formatter.shortWeekdaySymbols[i]
                labels[i].text = weekDayString
            }
        }
    }
    
}
