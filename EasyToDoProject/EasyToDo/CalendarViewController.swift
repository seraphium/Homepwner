//
//  CalendarView.swift
//  Easy Things
//
//  Created by Jackie Zhang on 16/6/21.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class CalendarViewController : UIViewController, CalendarViewDelegate, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var calenderContainerView: UIView!
    
    @IBOutlet weak var itemTableView: UITableView!
    
    var itemStore : ItemStore!

    var selectedDate : NSDate!
    
    var ItemsForSelectedDate : [Item]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemStore = AppDelegate.itemStore
        
        itemTableView.delegate = self
        itemTableView.dataSource = self
        // todays date.
        let date = NSDate()
        
        // create an instance of calendar view with
        // base date (Calendar shows 12 months range from current base date)
        // selected date (marked dated in the calendar)
        let calendarView = CalendarView.instance(date, selectedDate: date)
        calendarView.delegate = self
        calendarView.translatesAutoresizingMaskIntoConstraints = false

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
        itemTableView.reloadData()
    }
    
    //delegate function
    func didSelectDate(date: NSDate) {
        selectedDate = date
        reloadItems()
    }
    
    func willDisplayCell(cell: DayCollectionCell, indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.redColor()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let items = ItemsForSelectedDate {
            return items.count
        } else {
            return 0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = itemTableView.dequeueReusableCellWithIdentifier("itemCell", forIndexPath: indexPath) as UITableViewCell
        if let items = ItemsForSelectedDate {
            cell.textLabel?.text = items[indexPath.row].name

        }
        return cell
    }
    

}