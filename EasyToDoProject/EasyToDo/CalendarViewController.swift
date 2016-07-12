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
    
    var calendarShowed : Bool = false
    
    @IBOutlet var calendarOutsideView: UIView!
    
    @IBOutlet var containerView: UIView!
    
    
    @IBOutlet var calenderViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet var editButton: UIBarButtonItem!
    
    var calendarView : CalendarView!
    
    var tableViewController : ItemsViewController!
    
    
    var tableView : UITableView{
        return tableViewController.tableView
    }
    
    
    var notifyView : CalendarNotifyView!

    let fixedHeight = CGFloat(30) //height for notify view

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
        self.calendarView.alpha = 0.0
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
        
        initNotifyView()


    }
    
    override func viewDidAppear(animated: Bool) {
        UIView.animateWithDuration(2, animations: {
            self.notifyView.show()
            }, completion:  { done -> Void in
                UIView.animateWithDuration(2, animations: {
                    self.notifyView.hide()
                })
        })

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let height = UIScreen.mainScreen().bounds.height - 120
        if let sv = tableView.superview {
            notifyView.frame = CGRectMake(0, height - fixedHeight, sv.frame.size.width, fixedHeight)
        } else {
            notifyView.frame = CGRectMake(0, height - fixedHeight, tableView.frame.size.width, fixedHeight)
            
        }
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
    func willDisplayCell(cell: UICollectionViewCell, indexPath: NSIndexPath, date: Date, disabled: Bool) {
        
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
            label.textColor = AppDelegate.cellInnerColor
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
        let hasData = (result.count > 0)
        if hasData {
            print ("cell  : \(indexPath.section): \(indexPath.row) update on hasData \(hasData)")

        }
        calendarCell.hasData = (result.count > 0)
        calendarCell.disabled = disabled
        calendarCell.updateViews()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ItemViewControllerSegue" {
            let destVC = segue.destinationViewController as! ItemsViewController
            tableViewController = destVC
            tableViewController.calendarViewController = self
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
    
    @IBAction func calendarBarClicked(sender: AnyObject?)
    {
        
        
        if self.calenderViewTopConstraint.constant == 0{
            self.calenderViewTopConstraint.constant = -self.calendarOutsideView.bounds.height
            calendarShowed = false
        } else {
            self.calenderViewTopConstraint.constant = 0
            calendarShowed = true
            
        }
        
        UIView.animateWithDuration(0.5) {
            self.view.layoutIfNeeded()
            self.calendarView.alpha = self.calendarView.alpha == 0.0 ? 1.0 : 0.0
        }
        calendarView.reloadData()


    }
    
    
    func initNotifyView() {
        notifyView = getUIViewFromBundle("CalendarNotifyView") as! CalendarNotifyView
        tableView.addSubview(notifyView)
        notifyView.alpha = 0.0
        notifyView.scrollView = self.tableView as UIScrollView
    }
    

    
    
    //MARK:- swipe gesture for calendar
    
    @IBAction func calendarSwiped(sender: UISwipeGestureRecognizer) {
        
        calendarBarClicked(nil)
    }

    
 
}