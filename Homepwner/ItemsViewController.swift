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
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "unDone"
        case 1:
            return "Done"
        default:
            return ""
        }
    }
    
    //MARK: - tableview actions
    override func tableView(tableView : UITableView, numberOfRowsInSection section : Int) -> Int{
        switch section {
        case 0:
            return itemStore.allItemsUnDone.count
        case 1:
            return itemStore.allItemsDone.count
        default:
            return 0
        }

        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell", forIndexPath: indexPath) as! ItemCell
        //update cell font
        cell.updateLabels()
        
        switch indexPath.section {
        case 0:
            let item = itemStore.allItemsUnDone[indexPath.row]
            cell.textField.text = item.name
        case 1:
            let item = itemStore.allItemsDone[indexPath.row]
            cell.textField.text = item.name
        default:
            break;
        }

        
    //TODO: update cell color according to notify date remaining
      /*  if (item.valueInDollars  > 50){
            
            cell.valueLabel.textColor = UIColor.redColor()
        }
        else{
            cell.valueLabel.textColor = UIColor.greenColor()
            
        }*/
        return cell
       
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        if (editing) {
            view.endEditing(true)
        }
        super.setEditing(editing, animated: animated)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //no normal selection
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            var item : Item
            if (indexPath.section == 0)
            {
                item = itemStore.allItemsUnDone[indexPath.row]
            } else {
                item = itemStore.allItemsDone[indexPath.row]

            }
            
            let title = "Delete \(item.name)?"
            let message = "Are you sure you want to delete this item?"
            
            let ac = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            ac.addAction(cancelAction)
            let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: { (action) -> Void in
            //remove from item store
            self.itemStore.RemoveItem(item)
            //remove the item from image cache
            self.imageStore.deleteImageForKey(item.itemKey)
            //delete from tableview
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                
                
            })
            ac.addAction(deleteAction)
            presentViewController(ac, animated: true, completion: nil)
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
  
    
    @IBAction func detailButtonClicked(sender: UIButton) {
            let cell = sender.superview?.superview as! ItemCell
            let indexPath = self.tableView.indexPathForCell(cell)!
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
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
    
    
    @IBAction func itemDoneClicked(sender: UIButton) {
        let cell = sender.superview?.superview as! ItemCell
        let indexPath = self.tableView.indexPathForCell(cell)!
        if (indexPath.section == 0)
        {
            let item = itemStore.allItemsUnDone[indexPath.row]
            itemStore.finishItem(item)
            tableView.reloadData()
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
        }
        
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    

    
}