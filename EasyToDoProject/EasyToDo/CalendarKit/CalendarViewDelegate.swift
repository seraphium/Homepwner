//
//  CalendarViewDelegate.swift
//  Easy Things
//
//  Created by Jackie Zhang on 16/6/23.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import Foundation

protocol CalendarViewDelegate: class {
    func didSelectDate(date: NSDate)
    func willDisplayCell(cell: DayCollectionCell, indexPath: NSIndexPath)
}
