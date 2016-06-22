//
//  CellView.swift
//  AnotherTestCalendar
//
//  Created by Jackie Zhang on 16/6/20.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import JTAppleCalendar

class CellView: JTAppleDayCellView {
    
    @IBOutlet weak var DayLabel: UILabel!
    
    var normalDayColor = UIColor.blackColor()
    var weekendDayColor = UIColor.grayColor()
    
    
    func setupCellBeforeDisplay(cellState: CellState, date: NSDate) {
        
        // Setup text color
        configureTextColor(cellState)
        
        // Setup Cell text
        DayLabel.text =  cellState.text
          }
    
    func configureTextColor(cellState: CellState) {
        if cellState.dateBelongsTo == .ThisMonth {
            DayLabel.textColor = normalDayColor
        } else {
            DayLabel.textColor = weekendDayColor
        }
    }
    
}
