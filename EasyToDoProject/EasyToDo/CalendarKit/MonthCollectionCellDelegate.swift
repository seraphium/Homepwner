//
//  MonthCellDelegate.swift
//  Easy Things
//
//  Created by Jackie Zhang on 16/6/23.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import Foundation

protocol MonthCollectionCellDelegate: class {
    func didSelect(date: Date)
    func willDisplayCell(cell: DayCollectionCell, indexPath : NSIndexPath)
}
