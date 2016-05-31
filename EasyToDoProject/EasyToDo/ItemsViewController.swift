//
//  ItemsViewController.swift
//  Homepwner
//
//  Created by Jackie Zhang on 16/2/29.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class ItemsViewController : UITableViewController,UITextFieldDelegate, PresentNotifyProtocol {
    
    var itemStore : ItemStore!
    
    var imageStore : ImageStore!
    
    var doneClosed : Bool = false
    
    let kCloseCellHeight: CGFloat = 50
    let kOpenCellHeight: CGFloat = 250

    var cellHeightsForUnDone = [CGFloat]()
    var cellHeightsForDone = [CGFloat]()

    var newRow : Int?
    let dateFormatter : NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        return formatter
    }()

    
    var selectedItem : Item?
    
    // MARK: - initializer
    required init?(coder aDecoder: NSCoder){
        //set default edit mode button
        super.init(coder : aDecoder)
        navigationItem.leftBarButtonItem = editButtonItem()
        
    }
    
    
    func createCellHeightsArray() {
        cellHeightsForUnDone.removeAll()
        cellHeightsForDone.removeAll()
        let rowCountForUndone = itemStore.allItemsUnDone.count
        for _ in 0...rowCountForUndone {
            cellHeightsForUnDone.append(kCloseCellHeight)
        }
        let rowCountForDone = itemStore.allItemsDone.count
        for _ in 0...rowCountForDone {
            cellHeightsForDone.append(kCloseCellHeight)
        }
    }
    

    // MARK: - view lifecycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //set table cell height
        createCellHeightsArray()
        
        //set default background color
        tableView.backgroundColor = AppDelegate.backColor
        
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
            let view = getUIViewFromBundle("ItemSectionHeaderView") as! ItemSectionHeaderView
            view.tintColor = AppDelegate.cellInnerColor
            view.titleLabel.textColor = AppDelegate.cellInnerColor
            view.headerLabel.textColor = AppDelegate.cellInnerColor
            
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

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return cellHeightsForUnDone[indexPath.row]
        case 1:
            return cellHeightsForDone[indexPath.row]
        default:
            return 0
        }

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
            let expand = cellHeightsForUnDone[indexPath.row] == kOpenCellHeight
            cell.updateCell(expand, finished: false, expired: expired)
            cell.textField.text = item.name
            cell.item = item
            cell.delegate = self
            if let dateNotify = item.dateToNotify {
                cell.notifyDateLabel.text = cell.getNotifyFullString(dateNotify, repeatIndex: item.repeatInterval)
               
            } else {
                cell.notifyDateLabel.text = nil
            }
           
        case 1:
            let expand = cellHeightsForDone[indexPath.row] == kOpenCellHeight

            cell.updateCell(expand, finished: true, expired: false)
            let item = itemStore.allItemsDone[indexPath.row]
            cell.textField.text = item.name
            cell.notifyDateLabel.text = ""
            cell.item = item
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
        switch indexPath.section {
        case 0:
            if cellHeightsForUnDone[indexPath.row] == kCloseCellHeight { // open cell
                cellHeightsForUnDone[indexPath.row] = kOpenCellHeight
                selectedItem = itemStore.allItemsUnDone[indexPath.row]
                updateWithExpandCell(cell)

            } else {// close cell
                cellHeightsForUnDone[indexPath.row] = kCloseCellHeight
                selectedItem = nil
                updateWithUnExpandCell(cell)
            }
        case 1:
            if cellHeightsForDone[indexPath.row] == kCloseCellHeight { // open cell
                cellHeightsForDone[indexPath.row] = kOpenCellHeight
                selectedItem = itemStore.allItemsDone[indexPath.row]
                updateWithExpandCell(cell)

            } else {// close cell
                cellHeightsForDone[indexPath.row] = kCloseCellHeight
                selectedItem = nil

                updateWithUnExpandCell(cell)

            }
        default:
            break
        }
 

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
        
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete", handler: { (action: UITableViewRowAction!, indexPath: NSIndexPath!) in
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
    func updateWithExpandCell(cell: ItemCell) {
        let duration = 0.5
        UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            }, completion: nil)
        cell.expandAnimation(0, completion: nil)
    }
    
    func updateWithUnExpandCell(cell: ItemCell) {
        let duration = 0.5
        UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            }, completion: nil)
        cell.unExpandAnimation(0, completion: nil)
        
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
    
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {

        return true
    }
    
    //MARK: - other actions
    @IBAction func addNewItem(sender: AnyObject) {

       let newItem = itemStore.CreateItem(random: false, finished: false)
        createCellHeightsArray()

        if let index = itemStore.allItemsUnDone.indexOf(newItem) {
            let indexPath = NSIndexPath(forRow: index, inSection: 0)

            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            newRow = indexPath.row
            createCellHeightsArray()
            tableView.reloadSections(NSIndexSet(index:0), withRowAnimation: .None)
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
        //delete from tableview
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
        createCellHeightsArray()
        
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
    
    func finishItemReload(item : Item)
    {
        //only finish and move cell of non-repeat notification
        //for repeat notify, re create notify
        itemStore.finishItem(item)
        
        createCellHeightsArray()
        
        let range = NSMakeRange(0, self.tableView.numberOfSections)
        let sections = NSIndexSet(indexesInRange: range)
        self.tableView.reloadSections(sections, withRowAnimation: .Automatic)
    }
    
    @IBAction func itemDoneClicked(sender: UIButton) {
        let cell = sender.superview?.superview?.superview?.superview as! ItemCell
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
            
            finishItemReload(item)
           
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

//MARK: - extension
extension UIViewController {
    func getUIViewFromBundle(name: String) -> UIView
    {
        let nib = NSBundle.mainBundle().loadNibNamed(name, owner: self, options: nil)
        let view : UIView = nib[0] as! UIView
        return view
    }
}