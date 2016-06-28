//
//  MonthCollectionCell.swift
//  Calendar
//
//  Created by Lancy on 02/06/15.
//  Copyright (c) 2015 Lancy. All rights reserved.
//

import UIKit


class MonthCollectionCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var collectionView: UICollectionView!
    weak var monthCellDelgate: MonthCollectionCellDelegate?

    var cellXibName : String!
    
    var cellIdentifier : String!
    
    var dates = [Date]()
    var previousMonthVisibleDatesCount = 0
    var currentMonthVisibleDatesCount = 0
    var nextMonthVisibleDatesCount = 0

    var logic: CalendarLogic? {
        didSet {
            populateDates()
            if collectionView != nil {
                collectionView.reloadData()
            }
        }
    }
    
    var selectedDate: Date? {
        didSet {
            if collectionView != nil {
                collectionView.reloadData()
            }
        }
    }
    
    func populateDates() {
        if logic != nil {
            dates = [Date]()
            
            dates += logic!.previousMonthVisibleDays!
            dates += logic!.currentMonthDays!
            dates += logic!.nextMonthVisibleDays!
            
            previousMonthVisibleDatesCount = logic!.previousMonthVisibleDays!.count
            currentMonthVisibleDatesCount = logic!.currentMonthDays!.count
            nextMonthVisibleDatesCount = logic!.nextMonthVisibleDays!.count
            
        } else {
            dates.removeAll(keepCapacity: false)
        }
    }
    
    func registerCell(xibName: String, identifier : String)
    {
       cellXibName = xibName
       cellIdentifier = identifier
        
        let nib = UINib(nibName: cellXibName, bundle: nil)
        self.collectionView.registerNib(nib, forCellWithReuseIdentifier: cellIdentifier)
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        

        let headerNib = UINib(nibName: "WeekHeaderView", bundle: nil)
        self.collectionView.registerNib(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "WeekHeaderView")
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 7*6 = 42 :- 7 columns (7 days in a week) and 6 rows (max 6 weeks in a month)
        return 42
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) 
        
        let date = dates[indexPath.item]
       
        //if use default cell xib
        let disabled = (indexPath.item < previousMonthVisibleDatesCount) ||
            (indexPath.item >= previousMonthVisibleDatesCount
                + currentMonthVisibleDatesCount)
        
        if let defaultCell = cell as? DayCollectionCell
        {
            defaultCell.date = (indexPath.item < dates.count) ? date : nil
            defaultCell.mark = (selectedDate == date)
            
            defaultCell.disabled = disabled
        }
        else {
            monthCellDelgate?.willDisplayCell(cell, indexPath: indexPath, date: date, disabled: disabled)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if monthCellDelgate != nil {
            monthCellDelgate!.didSelect(dates[indexPath.item])
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "WeekHeaderView", forIndexPath: indexPath) 
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.frame.width/7.0, collectionView.frame.height/7.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(collectionView.frame.width, collectionView.frame.height/7.0)
    }
}
