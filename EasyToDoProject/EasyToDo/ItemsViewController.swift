//
//  ItemsViewController.swift
//  Homepwner
//
//  Created by Jackie Zhang on 16/2/29.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class ItemsViewController : UITableViewController,UITextFieldDelegate {
    
    var itemStore : ItemStore!
    
    var imageStore : ImageStore!
    
    var doneClosed : Bool = false
    
    var newRow : Int?
    let dateFormatter : NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        return formatter
    }()
    
    
    // MARK: - initializer
    required init?(coder aDecoder: NSCoder){
        //set default edit mode button
        super.init(coder : aDecoder)
        navigationItem.leftBarButtonItem = editButtonItem()
        
    }
    
    
    // MARK: - view lifecycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //set default background color
        tableView.backgroundColor = UIColor(red: 206.0/255.0, green: 203.0/255.0, blue: 188.0/255.0, alpha: 1.0)
        
        //refresh the table data if changed in detailed view
        tableView.reloadData()
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        //clear the first responder (keyboard)
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 65
      //  tableView.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        
    }
    
    
    //MARK: - tableview actions
    override func tableView(tableView : UITableView, numberOfRowsInSection section : Int) -> Int{
        switch section {
        case 0:
            return itemStore.allItemsUnDone.count
        case 1:
            if doneClosed {
                return 0
            } else {
                return itemStore.allItemsDone.count

            }
        default:
            return 0
        }

        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "未完成项目"
        case 1:
            return ""
        default:
            return ""
        }
    }
    
    func getUIViewFromBundle(name: String) -> UIView
    {
        let nib = NSBundle.mainBundle().loadNibNamed(name, owner: self, options: nil)
        let view : UIView = nib[0] as! UIView
        return view
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if section == 0 {
            let view = getUIViewFromBundle("ItemSectionHeaderView") as! ItemSectionHeaderView
            if itemStore.allItemsUnDone.count > 0 {
                view.titleLabel.text = "未完成"
                view.headerLabel.alpha = 0
                view.headerButton.alpha = 0
            } else {
                view.headerLabel.text = "请点击+添加项目"
                view.titleLabel.alpha = 0
                view.headerButton.alpha = 0

            }
            return view
            
            
        } else if section == 1 {
            if (itemStore.allItemsDone.count > 0) {
                let view = getUIViewFromBundle("ItemSectionHeaderView") as! ItemSectionHeaderView
                view.titleLabel.alpha = 0
                view.headerLabel.alpha = 0
                let btn = view.headerButton
                
                btn.addTarget(self, action: #selector(clickAction), forControlEvents: UIControlEvents.TouchUpInside)
                if doneClosed {
                    btn.setTitle("显示已完成", forState: .Normal)
                } else {
                    btn.setTitle("隐藏已完成", forState: .Normal)

                }
                return view
            }
            else{
            return nil
            }
            
        }
        return nil
        
    }
    
    func clickAction(bt: UIButton) -> Void {
        doneClosed = !doneClosed
        let indexSet = NSIndexSet(index: 1)
        tableView.reloadSections(indexSet, withRowAnimation: UITableViewRowAnimation.Fade)
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell", forIndexPath: indexPath) as! ItemCell
        //update cell font
        
        switch indexPath.section {
        case 0:
            var expired = false
            let item = itemStore.allItemsUnDone[indexPath.row]
            if let date = item.dateToNotify {
                if date.earlierDate(NSDate()) == item.dateToNotify {
                    expired = true
                }
            }

            cell.updateCell(false, expired: expired)
            cell.textField.text = item.name
           
            if let dateNotify = item.dateToNotify {
                var notifyString = dateFormatter.stringFromDate(dateNotify)
                if item.repeatInterval != 0 {
                    notifyString = notifyString + "," + AppDelegate.RepeatTime[item.repeatInterval]
                }
                cell.notifyDateLabel.text = notifyString
            }
        case 1:
            cell.updateCell(true, expired: false)
            let item = itemStore.allItemsDone[indexPath.row]
            cell.textField.text = item.name
            cell.notifyDateLabel.text = ""
        default:
            break;
        }

        return cell
       
    }
    

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //no normal selection
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    //disable table row movement between sections
    override func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        if (sourceIndexPath.section != proposedDestinationIndexPath) {
            var row = 0
            if (sourceIndexPath.section < proposedDestinationIndexPath.section) {
                row = self.tableView(tableView, numberOfRowsInSection: sourceIndexPath.section) - 1
            }
            return NSIndexPath(forRow: row, inSection: sourceIndexPath.section)
        }
        return proposedDestinationIndexPath
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
        //delete from tableview
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        tableView.reloadSections(NSIndexSet(index:indexPath.section), withRowAnimation: .Automatic)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            var item : Item
            if (indexPath.section == 0)
            {
                item = itemStore.allItemsUnDone[indexPath.row]
                let title = "Delete \(item.name)?"
                let message = "Are you sure you want to delete this item?"
                
                let ac = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                ac.addAction(cancelAction)
                let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: { (action) -> Void in
                    self.deleteItemFromTable(item, indexPath: indexPath)
                })
                ac.addAction(deleteAction)
                presentViewController(ac, animated: true, completion: nil)
            } else {
                item = itemStore.allItemsDone[indexPath.row]
                self.deleteItemFromTable(item, indexPath: indexPath)

            }
            
           
            }
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
    //let rotation = CGAffineTransformMakeRotation(CGFloat(M_PI))
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == newRow {
            let itemCell = cell as! BaseCell
            itemCell.openAnimation(completion: nil)
            newRow = nil
        }
    }

    
  //MARK: - segue actions
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //pass the value to the detailed view
        if segue.identifier == "ShowItem" {
            if let row = tableView.indexPathForSelectedRow?.row {
                var item : Item
                if (tableView.indexPathForSelectedRow?.section == 0)
                {
                    item = itemStore.allItemsUnDone[row]
                } else {
                    item = itemStore.allItemsDone[row]
                }
                let detailViewController = segue.destinationViewController as! DetailViewController
                detailViewController.item = item
                detailViewController.imageStore = imageStore
                
            }
            
        }
    
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "ShowItem" {
            if editing {
                return false
            }
        }
        return true
    }
    
    //MARK: - other actions
    @IBAction func addNewItem(sender: AnyObject) {
       let newItem = itemStore.CreateItem(random: false, finished: false)
        if let index = itemStore.allItemsUnDone.indexOf(newItem) {
            let indexPath = NSIndexPath(forRow: index, inSection: 0)

            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            newRow = indexPath.row

            tableView.reloadSections(NSIndexSet(index:0), withRowAnimation: .None)
        }
        
    }
    
    
    @IBAction func itemDoneClicked(sender: UIButton) {
        let cell = sender.superview?.superview?.superview as! ItemCell
        let indexPath = self.tableView.indexPathForCell(cell)!
        if (indexPath.section == 0)
        {
            let item = itemStore.allItemsUnDone[indexPath.row]

            //if expired (red), means badgenumber will remains and need reduce
            if cell.expired {
                cell.expired = false
                UIApplication.sharedApplication().applicationIconBadgeNumber -= 1
            } else {
                AppDelegate.cancelNotification(item)
            }
            
            //only finish and move cell of non-repeat notification
            //for repeat notify, re create notify
            itemStore.finishItem(item)
            let range = NSMakeRange(0, self.tableView.numberOfSections)
            let sections = NSIndexSet(indexesInRange: range)
            self.tableView.reloadSections(sections, withRowAnimation: .Automatic)
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
        let cell = sender.superview?.superview?.superview as! ItemCell
        let indexPath = self.tableView.indexPathForCell(cell)!
        var item : Item
        if (indexPath.section == 0)
        {
            item = itemStore.allItemsUnDone[indexPath.row]
        } else {
            item = itemStore.allItemsDone[indexPath.row]
            
        }
        item.name = sender.text!
        sender.resignFirstResponder()
    }
    
    
    @IBAction func backgroundTapped(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    

    

    
}