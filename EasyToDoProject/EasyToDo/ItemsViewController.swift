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
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if section == 0 {
            
            let bt : UIButton = UIButton.init(type: UIButtonType.System)
            bt.frame = CGRectMake(0, 0, 100, 60)
            // bt.backgroundColor = UIColor.cyanColor()
            if itemStore.allItemsUnDone.count > 0 {
                bt.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
                bt.setTitle("未完成", forState: .Normal)
            } else {
                bt.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
                bt.setTitle("请点击+添加项目", forState: .Normal)
                
            }
            return bt
            
        } else if section == 1 {
            if (itemStore.allItemsDone.count > 0) {
                let bt : UIButton = UIButton.init(type: UIButtonType.System)
                bt.frame = CGRectMake(0, 0, 375, 60)
                bt.addTarget(self, action: #selector(clickAction), forControlEvents: UIControlEvents.TouchUpInside)
                // bt.backgroundColor = UIColor.cyanColor()
                if doneClosed {
                    bt.setTitle("显示已完成", forState: .Normal)
                } else {
                    bt.setTitleColor(UIColor.redColor(), forState: .Normal)
                    bt.setTitle("隐藏已完成", forState: .Normal)

                }
                return bt
            }
            return nil
            

        }
        return nil
        
    }
    
    func clickAction(bt: UIButton) -> Void {
        doneClosed = !doneClosed
        let indexSet = NSIndexSet(index: 1)
        tableView.reloadSections(indexSet, withRowAnimation: UITableViewRowAnimation.Fade)
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

            cell.updateLabels(false, expired: expired)
            cell.textField.text = item.name
            if let dateNotify = item.dateToNotify {
                cell.notifyDateLabel.text = dateFormatter.stringFromDate(dateNotify)
            }
        case 1:
            cell.updateLabels(true, expired: false)
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
        //remove from item store
        self.itemStore.RemoveItem(item)
        //remove the item from image cache
        self.imageStore.deleteImageForKey(item.itemKey)
        //delete from tableview
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
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
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            tableView.reloadSections(NSIndexSet(index:0), withRowAnimation: .Fade)
        }
        
    }
    
    
    @IBAction func itemDoneClicked(sender: UIButton) {
        let cell = sender.superview?.superview as! ItemCell
        let indexPath = self.tableView.indexPathForCell(cell)!
        if (indexPath.section == 0)
        {
            let item = itemStore.allItemsUnDone[indexPath.row]
            itemStore.finishItem(item)
            //if expired (red), means badgenumber will remains and need reduce
            if cell.expired {
                UIApplication.sharedApplication().applicationIconBadgeNumber -= 1
            }
            tableView.reloadData()
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
        let cell = sender.superview?.superview as! ItemCell
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