//
//  CalendarViewDelegate.swift
//  Easy Things
//
//  Created by Jackie Zhang on 16/6/23.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

protocol CalendarViewDelegate: class {
    func didSelectDate(date: NSDate)
    func willDisplayCell(cell: UICollectionViewCell, indexPath: NSIndexPath, date: Date)
}
