//
//  ItemsViewController.swift
//  Homepwner
//
//  Created by Jackie Zhang on 16/2/29.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class ItemsViewController : UITableViewController {
    
    var itemStore : ItemStore!
    
    var imageStore : ImageStore!
    
    
    let dateFormatter : NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .NoStyle
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 65
        
    }
    
    //MARK: - tableview actions
    override func tableView(tableView : UITableView, numberOfRowsInSection section : Int) -> Int{
        return itemStore.allItems.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell", forIndexPath: indexPath) as! ItemCell
        //update cell font
        cell.updateLabels()
        
        let item = itemStore.allItems[indexPath.row]
       
        cell.nameLabel.text = item.name
        cell.detailLabel.text = item.detail
        cell.dateToNotifyLabel.text = dateFormatter.stringFromDate(item.dateToNotify)
        
    //TODO: update cell color according to notify date remaining
      /*  if (item.valueInDollars  > 50){
            
            cell.valueLabel.textColor = UIColor.redColor()
        }
        else{
            cell.valueLabel.textColor = UIColor.greenColor()
            
        }*/
        return cell
       
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let item = itemStore.allItems[indexPath.row]
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
        itemStore.MoveItemAtIndex(sourceIndexPath.row, toIndex: destinationIndexPath.row)
    }
  
    
  //MARK: - segue actions
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //pass the value to the detailed view
        if segue.identifier == "ShowItem" {
            if let row = tableView.indexPathForSelectedRow?.row {
                let item = itemStore.allItems[row]
                let detailViewController = segue.destinationViewController as! DetailViewController
                detailViewController.item = item
                detailViewController.imageStore = imageStore
                
            }
            
        }
        
        
    }
    
    //MARK: - other actions
    @IBAction func addNewItem(sender: AnyObject) {
       let newItem = itemStore.CreateItem(random: false)
        if let index = itemStore.allItems.indexOf(newItem) {
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        
    }
    
    
    
}