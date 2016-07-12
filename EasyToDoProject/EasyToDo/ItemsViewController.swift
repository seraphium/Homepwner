//
//  ItemsViewController.swift
//  Homepwner
//
//  Created by Jackie Zhang on 16/2/29.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class ItemsViewController : UITableViewController,UITextFieldDelegate, PresentNotifyProtocol {
    
    internal typealias Completion = ((Bool) -> Void)?
    
    var itemStore : ItemStore!
    
    var imageStore : ImageStore!
    var audioStore: AudioStore!
    
    var doneClosed : Bool = false
    
    let kCloseCellHeight: CGFloat = 50
    let kOpenCellHeight: CGFloat = 250
    let kExpandDuration = 0.5
    let kUnexpandDuration = 0.7

    var newRow : Int?
    
    let dateFormatter : NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        return formatter
    }()
    
    var selectedItem : Item?
    
    var selectedDate : Date?
    
    var calendarViewController : CalendarViewController!
    
    var calendarView : CalendarView{
        return calendarViewController.calendarView
    }
    
    var refreshView : ItemTableRefreshView!

    var progress: CGFloat = 0.0
    
    var isRefresh = false
    
    
    // MARK: - view lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.itemStore = AppDelegate.itemStore
        self.imageStore = AppDelegate.imageStore
        self.audioStore = AppDelegate.audioStore

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
      
        //refresh the table data if changed in detailed view
        tableView.reloadData()


    }

    
    override func viewWillDisappear(animated: Bool) {

        super.viewWillDisappear(animated)
        //clear the first responder (keyboard)
        view.endEditing(true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //set default background color
        tableView.backgroundColor = AppDelegate.backColor
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 65
        initRefreshView()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        refreshView.initFrame()
        
    }
 
    func initRefreshView() {

        refreshView = getUIViewFromBundle("ItemTableRefreshView") as! ItemTableRefreshView
        tableView.addSubview(refreshView)

        refreshView.scrollView = self.tableView as UIScrollView
 
    }
    
       //MARK: - tableview actions
    override func tableView(tableView : UITableView, numberOfRowsInSection section : Int) -> Int{
        switch section {
        case 0:
            return itemStore.selectedUnfinished.count
        case 1:
            if doneClosed {
                return 0
            } else {
                return itemStore.selectedFinished.count

            }
        default:
            return 0
        }

        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let unfinishedTitle = NSLocalizedString("ItemListHeaderNotFinished", comment: "")
        switch section {
        case 0:
            return unfinishedTitle
        case 1:
            return ""
        default:
            return ""
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let unfinishedString = NSLocalizedString("ItemViewHeaderNotFinished", comment: "")
        let addNewString = NSLocalizedString("ItemListClickToAddLabel", comment: "")

        if section == 0 {
            let view = getUIViewFromBundle("ItemSectionHeaderView") as! ItemSectionHeaderView
            view.tintColor = AppDelegate.cellInnerColor
            view.titleLabel.textColor = AppDelegate.cellInnerColor
            view.headerLabel.textColor = AppDelegate.cellInnerColor
            
            if itemStore.selectedUnfinished.count > 0 {
                view.titleLabel.text = unfinishedString
                view.headerLabel.alpha = 0
                view.headerButton.alpha = 0
            } else {
                view.headerLabel.text = addNewString
                view.titleLabel.alpha = 0
                view.headerButton.alpha = 0

            }
            return view
            
            
        } else if section == 1 {
            if (itemStore.selectedFinished.count > 0) {
                let view = getUIViewFromBundle("ItemSectionHeaderView") as! ItemSectionHeaderView
                view.titleLabel.alpha = 0
                view.headerLabel.alpha = 0
                let btn = view.headerButton
                let showFinishedItemString = NSLocalizedString("ItemListShowFinishedLabel", comment: "")
                let hideFinishedItemString = NSLocalizedString("ItemListHideFinishedLabel", comment: "")
                btn.addTarget(self, action: #selector(clickAction), forControlEvents: UIControlEvents.TouchUpInside)
                if doneClosed {
                    btn.setTitle(showFinishedItemString, forState: .Normal)
                } else {
                    btn.setTitle(hideFinishedItemString, forState: .Normal)

                }
                return view
            }
            else{
            return nil
            }
            
        }
        return nil
        
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return itemStore.selectedUnfinished[indexPath.row].expanded ? kOpenCellHeight : kCloseCellHeight
        case 1:
            return itemStore.selectedFinished[indexPath.row].expanded ? kOpenCellHeight : kCloseCellHeight
        default:
            return 0
        }

    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell", forIndexPath: indexPath) as! ItemCell
        cell.tableView = self.tableView
        cell.calendarView = self.calendarView
        switch indexPath.section {
        case 0:
            var expired = false
            let item = itemStore.selectedUnfinished[indexPath.row]
            if let date = item.dateToNotify {
                if date.earlierDate(NSDate()) == item.dateToNotify {
                    expired = true
                }
            }
           // print ("index:" + String(indexPath.row) + " expanded:" + String(item.expanded))
            cell.updateCell(item.expanded, finished: false, expired: expired)
            
            cell.textField.text = item.name
            cell.item = item
            cell.delegate = self
            cell.initializeDate = selectedDate
            if let dateNotify = item.dateToNotify {
                cell.notifyDateLabel.text = cell.getNotifyFullString(dateNotify, repeatIndex: item.repeatInterval)
               
            } else {
                cell.notifyDateLabel.text = nil
            }

            if let detail = item.detail {
                cell.detailTextView.text = detail
            } else {
                cell.detailTextView.text = nil
            }
            if let date = item.dateToNotify {
                cell.detailNotifyDate.text = dateFormatter.stringFromDate(date)
            }else{
                cell.detailNotifyDate.text = nil
            }
            cell.repeatSelector.selectedSegmentIndex = item.repeatInterval

           
        case 1:
            let item = itemStore.selectedFinished[indexPath.row]
                //finished items are all expanded
            cell.updateCell(false, finished: true, expired: false)
            cell.textField.text = item.name
            cell.notifyDateLabel.text = ""
            cell.item = item
            if let detail = item.detail {
                cell.detailTextView.text = detail
            }

            cell.delegate = self

        default:
            break;
        }

        return cell
       
    }
    
 
 
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //no normal selection
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ItemCell
        toggleExpand(cell)

    }
    
    //disable table row movement between sections
    override func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
            var row = 0
            if (sourceIndexPath.section < proposedDestinationIndexPath.section) {
                row = self.tableView(tableView, numberOfRowsInSection: sourceIndexPath.section) - 1
            }
            return NSIndexPath(forRow: row, inSection: sourceIndexPath.section)
        }
        return proposedDestinationIndexPath
    }
    
       override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if editing {
            return .None

        }
        return .Delete
        
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let titleString = NSLocalizedString("ItemCellDeleteLabel", comment: "")
        let deleteAction = UITableViewRowAction(style: .Destructive, title: titleString, handler: { (action: UITableViewRowAction!, indexPath: NSIndexPath!) in
            self.deleteRow(indexPath)
        })
        deleteAction.backgroundColor =  AppDelegate.backColor
        
        return [deleteAction]
    }
    

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        if (sourceIndexPath.section == destinationIndexPath.section){
            if (sourceIndexPath.section == 0)
            {
                itemStore.MoveItemAtIndex(sourceIndexPath.row, toIndex: destinationIndexPath.row, finishing: false)
            }
        }
    }
    
 
  
//MARK: - tableview Cell animation
    func presentNotify(controller: UIViewController) {
        self.presentViewController(controller, animated: true) { () -> Void in
            
        };
    }
    func updateWithExpandCell(cell: ItemCell, item: Item) {
        item.expanded = true
        cell.expanded = true
        let duration = kExpandDuration
        UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            }, completion: nil)
        cell.expandAnimation(0, completion: { done -> Void in
            
            
        })
    }
    
    func updateWithUnExpandCell(cell: ItemCell, item: Item, completion: (() -> ())?) {
        item.expanded = false
        cell.expanded = false

        let duration = kUnexpandDuration
        cell.unExpandAnimation(0, completion: nil)
        UIView.animateWithDuration(duration, delay: 0, options: .CurveLinear, animations: { () -> Void in
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            }, completion: { done -> Void in
                completion?()
        })

        
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == newRow {
            let itemCell = cell as! ItemCell
            itemCell.openAnimation(0, completion: nil)
            newRow = nil
        }

    }

    
  //MARK: - segue actions
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //pass the value to the detailed view
        if segue.identifier == "ShowPicture" {

        let picVC = segue.destinationViewController as! PictureViewController
        picVC.item = selectedItem
        picVC.imageStore = imageStore

      }
        if segue.identifier == "ShowAudio" {
            let audioVC = segue.destinationViewController as! AudioViewController
            audioVC.item = selectedItem
            audioVC.audioStore = audioStore
            
        }
    
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        
        return true
    }
    
    //MARK: - other actions
    func addNewItem() {
        let initialDate : NSDate?
        if let date = selectedDate {
            //make 08:00 as default notify date for selected date in calendar
            initialDate = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Hour, value: 8, toDate: date.nsdate, options: NSCalendarOptions(rawValue: 0))
        } else {
            initialDate = nil
        }
        let newItem = self.itemStore.CreateItem(random: false, finished: false, notifyDate: initialDate)
       // direct scheduling notify if has initial date
        if let date = initialDate {
            AppDelegate.scheduleNotifyForDate(date,
                                              withRepeatInteval: nil,
                                              onItem: newItem,
                                              withTitle: newItem.name, withBody: newItem.detail)
        }
        
        if let index = self.itemStore.selectedUnfinished.indexOf(newItem) {
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation:.Fade)
            self.newRow = indexPath.row
            self.tableView.reloadSections(NSIndexSet(index:0), withRowAnimation: .Fade)
        }
        self.calendarView.reloadData()
    }
    
    

    
    private func toggleExpand(cell: ItemCell) {
        let indexPath = tableView.indexPathForCell(cell)!
        switch indexPath.section {
        case 0:
            selectedItem = itemStore.selectedUnfinished[indexPath.row]

            if !((selectedItem?.expanded)!) { // open cell
                updateWithExpandCell(cell, item: selectedItem!)
                
            } else {// close cell
                updateWithUnExpandCell(cell, item: selectedItem!) {
                    self.selectedItem = nil
                }
            }
        case 1:
            selectedItem = itemStore.selectedFinished[indexPath.row]

            if !((selectedItem?.expanded)!)   { // open cell
                updateWithExpandCell(cell, item: selectedItem!)
                
            } else {// close cell
                updateWithUnExpandCell(cell, item: selectedItem!) {
                    self.selectedItem = nil
                }
            }
        default:
            break
        }
        
    }
    
    private func deleteItemFromTable(item: Item, indexPath: NSIndexPath) {
        //remove from notification center if has created notify
        if (item.dateToNotify) != nil && item.finished != true {
            AppDelegate.cancelNotification(item)
        }
        //remove from item store
        self.itemStore.RemoveItem(item)
        //remove the item from image cache
        self.imageStore.deleteImageForKey(item.itemKey)
        self.audioStore.deleteAudioForKey(item.itemKey)
        //delete from tableview
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
        tableView.reloadSections(NSIndexSet(index:indexPath.section), withRowAnimation: .Automatic)
    }
    

    
    func clickAction(bt: UIButton) -> Void {
        doneClosed = !doneClosed
        let indexSet = NSIndexSet(index: 1)
        tableView.reloadSections(indexSet, withRowAnimation: UITableViewRowAnimation.Fade)
    }

    func deleteRow(indexPath: NSIndexPath) {
        var item : Item
        if (indexPath.section == 0)
        {
            item = itemStore.selectedUnfinished[indexPath.row]
            let deleteString = NSLocalizedString("ItemCellDeleteLabel", comment: "")
            let title = "\(deleteString) \(item.name)"
            let message = NSLocalizedString("ItemCellDeleteConfirm", comment: "")
            
            let ac = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
            let cancelAction = UIAlertAction(title: NSLocalizedString("ItemCellDeleteCancel", comment: ""), style: .Cancel, handler: nil)
            ac.addAction(cancelAction)
            let deleteAction = UIAlertAction(title: NSLocalizedString("ItemCellDeleteLabel", comment: ""), style: .Destructive, handler: { (action) -> Void in
                self.deleteItemFromTable(item, indexPath: indexPath)
            })
            ac.addAction(deleteAction)
            presentViewController(ac, animated: true, completion: nil)
        } else {
            item = itemStore.selectedFinished[indexPath.row]
            self.deleteItemFromTable(item, indexPath: indexPath)
            
        }
        
    }
    
    func finishItemReload(item : Item)
    {
        //only finish and move cell of non-repeat notification
        //for repeat notify, re create notify
        itemStore.finishItem(item)
        item.expanded = false
        let range = NSMakeRange(0, self.tableView.numberOfSections)
        let sections = NSIndexSet(indexesInRange: range)
        self.tableView.reloadSections(sections, withRowAnimation: .Automatic)
        self.calendarView.reloadData()
    }
    
    @IBAction func itemDoneClicked(sender: UIButton) {
        let cell = sender.superview?.superview?.superview?.superview as! ItemCell
        let indexPath = self.tableView.indexPathForCell(cell)!
        if (indexPath.section == 0)
        {
            let item = itemStore.selectedUnfinished[indexPath.row]

            //if expired (red), means badgenumber will remains and need reduce
            if cell.expired {
                cell.expired = false
                UIApplication.sharedApplication().applicationIconBadgeNumber -= 1
            } else {
                AppDelegate.cancelNotification(item)
            }
            
            finishItemReload(item)
            
           // if item.expanded {
            //    updateWithUnExpandCell(cell, item: item, completion: nil)
        //}
        
        }
    }


    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @IBAction func detailButtonClicked(sender: UIButton) {
        let cell = sender.superview?.superview as! ItemCell
        let indexPath = self.tableView.indexPathForCell(cell)!
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        if (editing) {
            view.endEditing(true)
        }
        super.setEditing(editing, animated: animated)
    }
    
    @IBAction func cellEditingEnd(sender: UITextField) {
        let cell = sender.superview?.superview?.superview?.superview as! ItemCell
        let indexPath = self.tableView.indexPathForCell(cell)!
        var item : Item
        if (indexPath.section == 0)
        {
            item = itemStore.selectedUnfinished[indexPath.row]
        } else {
            item = itemStore.selectedFinished[indexPath.row]
            
        }
        item.name = sender.text!
        sender.resignFirstResponder()
    }
    
    
    @IBAction func backgroundTapped(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    //MARK:- scroll delegate logic
    
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        beginRefresh()
        
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let offY = max(-1*(scrollView.contentOffset.y+scrollView.contentInset.top),0)
        progress = min(offY / refreshView.frame.size.height , 1.0)
        if isRefresh && progress >= 1 {
            //do refresh work
            endRefresh()

            doRefresh()
        }
        
    }
    
 /*   override func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if isRefresh && progress >= 1 {
            //do refresh work
            doRefresh()
        }
    }*/
    
    func beginRefresh() {
        isRefresh = true
        if calendarViewController.calendarShowed {
            refreshView.swipeUpRefresh()
        } else {
            refreshView.swipeDownRefresh()
        }
        //handling refresh animation
    }
    
    func endRefresh() {
        isRefresh = false
    }

    
    func doRefresh() {
        calendarViewController.calendarBarClicked(nil)
    }
}

//MARK: - extension
extension UIViewController {
    func getUIViewFromBundle(name: String) -> UIView
    {
        let nib = NSBundle.mainBundle().loadNibNamed(name, owner: self, options: nil)
        let view : UIView = nib[0] as! UIView
        return view
    }
}