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

    var selectedDate : NSDate!
    
    var ItemsForSelectedDate : [Item]?
    
    @IBOutlet var calendarOutsideView: UIView!
    
    @IBOutlet var containerView: UIView!
    
    
    @IBOutlet var calenderViewTopConstraint: NSLayoutConstraint!
    
    var tableViewController : ItemsViewController!
    
    var tableView : UITableView{
        return tableViewController.tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calenderViewTopConstraint.constant = -calendarOutsideView.bounds.height
        
        navigationItem.title = NSLocalizedString("CalendarNavTitle", comment: "")
        
        itemStore = AppDelegate.itemStore
        
        // todays date.
        let date = NSDate()
        
        // create an instance of calendar view with
        // base date (Calendar shows 12 months range from current base date)
        // selected date (marked dated in the calendar)
        let calendarView = CalendarView.instance(date, selectedDate: date)
        calendarView.delegate = self
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        
        //register customized cell xib
        calendarView.RegisterCell("CalendarCell", identifier: "CalendarCell")
        
        calenderContainerView.addSubview(calendarView)
        // Constraints for calendar view - Fill the parent view.
        calenderContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[calendarView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["calendarView": calendarView]))
        calenderContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[calendarView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["calendarView": calendarView]))
        
    }
    
    func reloadItems(){
        var items = [Item]()
        for item in itemStore.allItemsUnDone {
            if let date = item.dateToNotify {
                if date.year == selectedDate.year &&
                    date.month == selectedDate.month &&
                    date.day == selectedDate.day {
                    items.append(item)
                }
            }
        }
        
        ItemsForSelectedDate = items
    }
    
    //delegate function
    func didSelectDate(date: NSDate) {
        selectedDate = date
        reloadItems()
    }
    
    //delegate to setup cell
    func willDisplayCell(cell: UICollectionViewCell, indexPath: NSIndexPath, date: Date) {
        
        let calendarCell = cell as! CalendarCell
       // calendarCell.backgroundColor = UIColor.redColor()
        calendarCell.date = date
        if let selected = selectedDate {
            calendarCell.mark = (Date(date: selected) == date)

        }
        
      
        
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
    
    @IBAction func calendarBarClicked(sender: UIBarButtonItem)
    {
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