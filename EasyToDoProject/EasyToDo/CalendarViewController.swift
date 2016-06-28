//
//  CalendarView.swift
//  Easy Things
//
//  Created by Jackie Zhang on 16/6/21.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class CalendarViewController : UIViewController, CalendarViewDelegate {
    

    @IBOutlet weak var calenderContainerView: UIView!
    
    var itemStore : ItemStore!

    var selectedDate : NSDate?
    
    @IBOutlet var calendarOutsideView: UIView!
    
    @IBOutlet var containerView: UIView!
    
    
    @IBOutlet var calenderViewTopConstraint: NSLayoutConstraint!
    
    
    @IBOutlet var editButton: UIBarButtonItem!
    
    var calendarView : CalendarView!
    
    var tableViewController : ItemsViewController!
    
    var tableView : UITableView{
        return tableViewController.tableView
    }
    
    override func awakeFromNib() {
        

        itemStore = AppDelegate.itemStore
        
        
        // create an instance of calendar view with
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calenderViewTopConstraint.constant = -calendarOutsideView.bounds.height
        // base date (Calendar shows 12 months range from current base date)
        // selected date (marked dated in the calendar)
        let calendarView = CalendarView.instance(NSDate(), selectedDate: nil)
        calendarView.delegate = self
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        self.calendarView = calendarView
        
        //register customized cell xib
        calendarView.RegisterCell("CalendarCell", identifier: "CalendarCell")
        
        calenderContainerView.addSubview(calendarView)
        // Constraints for calendar view - Fill the parent view.
        calenderContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[calendarView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["calendarView": calendarView]))
        calenderContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[calendarView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["calendarView": calendarView]))
        
        calenderContainerView.backgroundColor = UIColor.clearColor()
        calendarOutsideView.backgroundColor = AppDelegate.backColor
        
        editButton.title = NSLocalizedString("CalenderViewEditBtnTitleEdit", comment: "")

        navigationItem.title = NSLocalizedString("CalendarNavTitle", comment: "")

    }
    
    //delegate function
    func didSelectDate(date: NSDate?) {
        selectedDate = date
        if let d = date {
            itemStore.selectedDates = [d]
            tableViewController.selectedDate = Date(date: d)
        } else {
            itemStore.selectedDates = nil
            tableViewController.selectedDate = nil

        }
        tableViewController.tableView.reloadData()
    }
    
    //delegate to setup cell
    func willDisplayCell(cell: UICollectionViewCell, indexPath: NSIndexPath, date: Date) {
        
        let calendarCell = cell as! CalendarCell
        calendarCell.date = date
        //mark selected data
        if let selected = selectedDate {
            calendarCell.mark = (Date(date: selected) == date)
        } else {
            calendarCell.mark = false
        }
        //mark current date bold and color
        let label = calendarCell.label
        if date == Date(date: NSDate()) {
            label.font = UIFont.boldSystemFontOfSize(label.font.pointSize)
            label.textColor = UIColor.redColor()
        }
        else {
            label.font = UIFont.systemFontOfSize(label.font.pointSize)
            label.textColor = UIColor.blackColor()
        }
        //mark hasData date
        let result = itemStore.allItemsUnDone.filter {
            if let d = $0.dateToNotify {
                return Date(date: d) == date
            } else {
                return false
            }
        }
        calendarCell.hasData = (result.count > 0)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ItemViewControllerSegue" {
            let destVC = segue.destinationViewController as! ItemsViewController
            tableViewController = destVC
        }
    }
    

    
    @IBAction func addNewItem(sender: AnyObject) {
        
        tableViewController.addNewItem()
    }
    
    
    @IBAction func editButtonClicked(sender: AnyObject) {
        UIView.animateWithDuration(0.5, animations: {
            self.tableViewController.editing =
                !self.tableViewController.editing
        })
        
        if (self.tableViewController.editing){
            self.editButton.title = NSLocalizedString("CalenderViewEditBtnTitleDone", comment: "")
        } else{
            self.editButton.title = NSLocalizedString("CalenderViewEditBtnTitleEdit", comment: "")
            
        }
       
    }
    
    @IBAction func calendarBarClicked(sender: UIBarButtonItem)
    {
        calendarView.reloadData()
        
        self.view.layoutIfNeeded()
        
        if self.calenderViewTopConstraint.constant == 0{
            self.calenderViewTopConstraint.constant = -self.calendarOutsideView.bounds.height
        } else {
            self.calenderViewTopConstraint.constant = 0
        }
        
        UIView.animateWithDuration(0.5) {
            self.view.layoutIfNeeded()
   
        }
    }
    

    
 
}