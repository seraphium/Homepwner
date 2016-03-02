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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //get the height of the status bar
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        let insets = UIEdgeInsets(top: statusBarHeight, left : 0, bottom: 0, right: 0)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
        
    }
    
    //tableview related override
    //////////////
    override func tableView(tableView : UITableView, numberOfRowsInSection section : Int) -> Int{
        return itemStore.allItems.count + 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell", forIndexPath: indexPath)
        if indexPath.row < itemStore.allItems.count {
            let item = itemStore.allItems[indexPath.row]
            cell.textLabel?.text = item.name
            cell.detailTextLabel?.text = "$\(item.valueInDollars)"

        } else {
            
            cell.textLabel?.text = "No more items..."
            cell.detailTextLabel?.text = nil
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let item = itemStore.allItems[indexPath.row]
            itemStore.RemoveItem(item)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        itemStore.MoveItemAtIndex(sourceIndexPath.row, toIndex: destinationIndexPath.row)
    }
    /////////////
    
    
    
    @IBAction func addNewItem(sender: AnyObject) {
       let newItem = itemStore.CreateItem()
        if let index = itemStore.allItems.indexOf(newItem) {
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        
    }
    
    
    @IBAction func toggleEditingMode(sender : AnyObject) {
        if editing {
            sender.setTitle("Edit", forState: .Normal)
            setEditing(false, animated: true)
        } else {
            sender.setTitle("Done", forState: .Normal)
            setEditing(true, animated: true)
        }
    }
    
    
    
    
    
    
    
}