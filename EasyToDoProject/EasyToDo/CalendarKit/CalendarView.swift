//
//  CalendarView.swift
//  Calendar
//
//  Created by Lancy on 02/06/15.
//  Copyright (c) 2015 Lancy. All rights reserved.
//

import UIKit

// 12 months - base date - 12 months
let kMonthRange = 12


class CalendarView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, MonthCollectionCellDelegate {
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var headerViewHeightContraint: NSLayoutConstraint!
    
    @IBOutlet var monthYearLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var previousButton: UIButton!
    weak var delegate: CalendarViewDelegate?
    
    var cellXibName : String = "DayCollectionCell"
    
    var cellIdentifier : String = "DayCollectionCell"
    
    //previous button layer
    let previousLayer = CAShapeLayer()
    //next button layer
    var nextLayer = CAShapeLayer()
    
    private var collectionData = [CalendarLogic]()
    
    var showHeader : Bool  = true {
        didSet {
            if showHeader {
                headerViewHeightContraint.constant = 40
            } else {
                headerViewHeightContraint.constant = 0
            }
        }
        
    }
    
    var baseDate: NSDate? {
        didSet {
            collectionData = [CalendarLogic]()
            if baseDate != nil {
                var dateIter1 = baseDate!, dateIter2 = baseDate!
                var set = Set<CalendarLogic>()
                set.insert(CalendarLogic(date: baseDate!))
                // advance one year
                for _ in [0 ..< kMonthRange] {
                    dateIter1 = dateIter1.firstDayOfFollowingMonth
                    dateIter2 = dateIter2.firstDayOfPreviousMonth
                    
                    set.insert(CalendarLogic(date: dateIter1))
                    set.insert(CalendarLogic(date: dateIter2))
                }
                collectionData = Array(set).sort(<)
            }
            
            updateHeader()
            collectionView.reloadData()
        }
    }
    
    var selectedDate: NSDate? {
        didSet {
            if self.delegate != nil {
                self.delegate!.didSelectDate(self.selectedDate)
            }
                dispatch_async(dispatch_get_main_queue()){
                    self.collectionView.reloadData()
                    if let date = self.selectedDate {
                        self.moveToDate(date, animated: false)
                    } else {
                        self.moveToDate(NSDate(), animated: false)
                    }
            }
        }
    }
    
    override func awakeFromNib() {
        let nib = UINib(nibName: "MonthCollectionCell", bundle: nil)
        self.collectionView.registerNib(nib, forCellWithReuseIdentifier: "MonthCollectionCell")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //create border
     /*   let border = CALayer()
        let borderHeight = CGFloat(2)
        border.backgroundColor = AppDelegate.cellInnerColor.colorWithAlphaComponent(0.5).CGColor
        border.frame = CGRectMake(0, self.frame.height - borderHeight, self.frame.width, borderHeight)
        border.zPosition = 10000
        
        self.layer.addSublayer(border) */
        initPreviousButtonView()
        initNextButtonView()
    
    }
    
    class func instance(baseDate: NSDate, selectedDate: NSDate?) -> CalendarView {
        let calendarView = NSBundle.mainBundle().loadNibNamed("CalendarView", owner: nil, options: nil).first as! CalendarView
        calendarView.selectedDate = selectedDate
        calendarView.baseDate = baseDate
        return calendarView
    }
    

    
    func reloadData(){
        self.collectionView.reloadData()
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionData.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MonthCollectionCell", forIndexPath: indexPath) as! MonthCollectionCell
        
        cell.registerCell(cellXibName, identifier: cellIdentifier)
        
        cell.monthCellDelgate = self
        
        cell.logic = collectionData[indexPath.item]
        if let selected = selectedDate {
            if cell.logic!.isVisible(selected) {
                cell.selectedDate = Date(date: selectedDate!)
            }
 
        }
               return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
            updateHeader()
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        updateHeader()

    }
    
    func updateHeader() {
        let pageNumber = Int(collectionView.contentOffset.x / collectionView.frame.width)
        updateHeader(pageNumber)
    }
    
    func updateHeader(pageNumber: Int) {
        if collectionData.count > pageNumber {
            let logic = collectionData[pageNumber]
            monthYearLabel.text = logic.currentMonthAndYear as String
            delegate?.updateHeader(monthYearLabel.text!)
        }
    }
    
    @IBAction func retreatToPreviousMonth(button: UIButton) {
        advance(-1, animate: true)
    }
    
    @IBAction func advanceToFollowingMonth(button: UIButton) {
        advance(1, animate: true)
    }
    
    func advance(byIndex: Int, animate: Bool) {
        var visibleIndexPath = self.collectionView.indexPathsForVisibleItems().first as NSIndexPath!
        
        if (visibleIndexPath.item == 0 && byIndex == -1) ||
           ((visibleIndexPath.item + 1) == collectionView.numberOfItemsInSection(0) && byIndex == 1) {
           return
        }
        
        visibleIndexPath = NSIndexPath(forItem: visibleIndexPath.item + byIndex, inSection: visibleIndexPath.section)
        updateHeader(visibleIndexPath.item)
        collectionView.scrollToItemAtIndexPath(visibleIndexPath, atScrollPosition: .CenteredHorizontally, animated: animate)
    }
    
    func moveToDate(moveDate: NSDate, animated: Bool) {
        var index = -1
        for i in 0 ..< collectionData.count  {
            let logic = collectionData[i]
            if logic.containsDate(moveDate) {
                index = i
                break
            }
        }
        
        if index != -1 {
            let indexPath = NSIndexPath(forItem: index, inSection: 0)
            updateHeader(indexPath.item)
            collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: animated)
        }
    }
    
    //MARK: Month cell delegate.
    func didSelect(date: Date?) {
        if let d = date, selected = selectedDate {
            if d == Date(date: selected) {
                selectedDate = nil
                print("selectedDate = nil")
            } else {
                selectedDate = d.nsdate
                print("selectedDate = " + String(selectedDate))
            }
        } else if let d = date{
                selectedDate = d.nsdate
                print("selectedDate = " + String(selectedDate))

        } else {
                selectedDate = nil
                print("selectedDate = nil")

        }
        
    }
    
    func willDisplayCell(cell: UICollectionViewCell, indexPath: NSIndexPath, date: Date, disabled: Bool){
        delegate?.willDisplayCell(cell, indexPath: indexPath, date: date, disabled: disabled)
    }
    
    func RegisterCell(nibName : String, identifier : String)
    {
       cellXibName = nibName
       cellIdentifier = identifier

        
    }
    
    func initNextButtonView() {
        
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: 13.34, y: 8.81))
        bezierPath.addCurveToPoint(CGPoint(x: 12.94, y: 8.81), controlPoint1: CGPoint(x: 13.22, y: 8.69), controlPoint2: CGPoint(x: 13.05, y: 8.69))
        bezierPath.addLineToPoint(CGPoint(x: 12.54, y: 9.2))
        bezierPath.addCurveToPoint(CGPoint(x: 12.54, y: 9.6), controlPoint1: CGPoint(x: 12.43, y: 9.32), controlPoint2: CGPoint(x: 12.43, y: 9.49))
        bezierPath.addLineToPoint(CGPoint(x: 18.32, y: 15.37))
        bezierPath.addLineToPoint(CGPoint(x: 12.26, y: 21.43))
        bezierPath.addCurveToPoint(CGPoint(x: 12.26, y: 21.83), controlPoint1: CGPoint(x: 12.15, y: 21.54), controlPoint2: CGPoint(x: 12.15, y: 21.71))
        bezierPath.addLineToPoint(CGPoint(x: 12.66, y: 22.22))
        bezierPath.addCurveToPoint(CGPoint(x: 13.05, y: 22.22), controlPoint1: CGPoint(x: 12.77, y: 22.34), controlPoint2: CGPoint(x: 12.94, y: 22.34))
        bezierPath.addLineToPoint(CGPoint(x: 19.17, y: 16.11))
        bezierPath.addCurveToPoint(CGPoint(x: 19.28, y: 16.05), controlPoint1: CGPoint(x: 19.22, y: 16.11), controlPoint2: CGPoint(x: 19.28, y: 16.05))
        bezierPath.addLineToPoint(CGPoint(x: 19.67, y: 15.66))
        bezierPath.addCurveToPoint(CGPoint(x: 19.67, y: 15.26), controlPoint1: CGPoint(x: 19.79, y: 15.54), controlPoint2: CGPoint(x: 19.79, y: 15.37))
        bezierPath.addLineToPoint(CGPoint(x: 13.34, y: 8.81))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 15.26, y: 0.26))
        bezierPath.addCurveToPoint(CGPoint(x: 0.26, y: 15.26), controlPoint1: CGPoint(x: 7, y: 0.26), controlPoint2: CGPoint(x: 0.26, y: 7))
        bezierPath.addCurveToPoint(CGPoint(x: 15.26, y: 30.26), controlPoint1: CGPoint(x: 0.26, y: 23.52), controlPoint2: CGPoint(x: 7, y: 30.26))
        bezierPath.addCurveToPoint(CGPoint(x: 30.26, y: 15.26), controlPoint1: CGPoint(x: 23.52, y: 30.26), controlPoint2: CGPoint(x: 30.26, y: 23.52))
        bezierPath.addCurveToPoint(CGPoint(x: 15.26, y: 0.26), controlPoint1: CGPoint(x: 30.26, y: 7), controlPoint2: CGPoint(x: 23.52, y: 0.26))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 15.26, y: 29.13))
        bezierPath.addCurveToPoint(CGPoint(x: 1.39, y: 15.26), controlPoint1: CGPoint(x: 7.62, y: 29.13), controlPoint2: CGPoint(x: 1.39, y: 22.9))
        bezierPath.addCurveToPoint(CGPoint(x: 15.26, y: 1.39), controlPoint1: CGPoint(x: 1.39, y: 7.62), controlPoint2: CGPoint(x: 7.62, y: 1.39))
        bezierPath.addCurveToPoint(CGPoint(x: 29.13, y: 15.26), controlPoint1: CGPoint(x: 22.9, y: 1.39), controlPoint2: CGPoint(x: 29.13, y: 7.62))
        bezierPath.addCurveToPoint(CGPoint(x: 15.26, y: 29.13), controlPoint1: CGPoint(x: 29.13, y: 22.9), controlPoint2: CGPoint(x: 22.9, y: 29.13))
        bezierPath.closePath()

        bezierPath.miterLimit = 4;
        
        nextLayer.backgroundColor = UIColor.clearColor().CGColor
        nextLayer.path = bezierPath.CGPath
        nextLayer.fillColor = AppDelegate.cellInnerColor.CGColor

        nextButton.layer.addSublayer(nextLayer)
    }
    
    func initPreviousButtonView() {
        
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: 16.92, y: 8.55))
        bezierPath.addCurveToPoint(CGPoint(x: 17.32, y: 8.55), controlPoint1: CGPoint(x: 17.04, y: 8.43), controlPoint2: CGPoint(x: 17.21, y: 8.43))
        bezierPath.addLineToPoint(CGPoint(x: 17.72, y: 8.94))
        bezierPath.addCurveToPoint(CGPoint(x: 17.72, y: 9.34), controlPoint1: CGPoint(x: 17.83, y: 9.06), controlPoint2: CGPoint(x: 17.83, y: 9.23))
        bezierPath.addLineToPoint(CGPoint(x: 11.94, y: 15.11))
        bezierPath.addLineToPoint(CGPoint(x: 18, y: 21.17))
        bezierPath.addCurveToPoint(CGPoint(x: 18, y: 21.57), controlPoint1: CGPoint(x: 18.11, y: 21.28), controlPoint2: CGPoint(x: 18.11, y: 21.45))
        bezierPath.addLineToPoint(CGPoint(x: 17.6, y: 21.96))
        bezierPath.addCurveToPoint(CGPoint(x: 17.21, y: 21.96), controlPoint1: CGPoint(x: 17.49, y: 22.08), controlPoint2: CGPoint(x: 17.32, y: 22.08))
        bezierPath.addLineToPoint(CGPoint(x: 11.09, y: 15.85))
        bezierPath.addCurveToPoint(CGPoint(x: 10.98, y: 15.79), controlPoint1: CGPoint(x: 11.04, y: 15.85), controlPoint2: CGPoint(x: 10.98, y: 15.79))
        bezierPath.addLineToPoint(CGPoint(x: 10.58, y: 15.4))
        bezierPath.addCurveToPoint(CGPoint(x: 10.58, y: 15), controlPoint1: CGPoint(x: 10.47, y: 15.28), controlPoint2: CGPoint(x: 10.47, y: 15.11))
        bezierPath.addLineToPoint(CGPoint(x: 16.92, y: 8.55))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 15, y: 0))
        bezierPath.addCurveToPoint(CGPoint(x: 30, y: 15), controlPoint1: CGPoint(x: 23.26, y: 0), controlPoint2: CGPoint(x: 30, y: 6.74))
        bezierPath.addCurveToPoint(CGPoint(x: 15, y: 30), controlPoint1: CGPoint(x: 30, y: 23.26), controlPoint2: CGPoint(x: 23.26, y: 30))
        bezierPath.addCurveToPoint(CGPoint(x: 0, y: 15), controlPoint1: CGPoint(x: 6.74, y: 30), controlPoint2: CGPoint(x: 0, y: 23.26))
        bezierPath.addCurveToPoint(CGPoint(x: 15, y: 0), controlPoint1: CGPoint(x: 0, y: 6.74), controlPoint2: CGPoint(x: 6.74, y: 0))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 15, y: 28.87))
        bezierPath.addCurveToPoint(CGPoint(x: 28.87, y: 15), controlPoint1: CGPoint(x: 22.64, y: 28.87), controlPoint2: CGPoint(x: 28.87, y: 22.64))
        bezierPath.addCurveToPoint(CGPoint(x: 15, y: 1.13), controlPoint1: CGPoint(x: 28.87, y: 7.36), controlPoint2: CGPoint(x: 22.64, y: 1.13))
        bezierPath.addCurveToPoint(CGPoint(x: 1.13, y: 15), controlPoint1: CGPoint(x: 7.36, y: 1.13), controlPoint2: CGPoint(x: 1.13, y: 7.36))
        bezierPath.addCurveToPoint(CGPoint(x: 15, y: 28.87), controlPoint1: CGPoint(x: 1.13, y: 22.64), controlPoint2: CGPoint(x: 7.36, y: 28.87))
        bezierPath.closePath()

        bezierPath.miterLimit = 4;
                
        previousLayer.backgroundColor = UIColor.clearColor().CGColor
        previousLayer.path = bezierPath.CGPath
        previousLayer.fillColor = AppDelegate.cellInnerColor.CGColor
        previousButton.layer.addSublayer(previousLayer)
    }



}
