//
//  RepeatViewController.swift
//  EasyToDo
//
//  Created by Jackie Zhang on 16/5/4.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class RepeatViewController : UITableViewController, UITextFieldDelegate,  UITextViewDelegate,UINavigationControllerDelegate
{
    var item : Item?
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppDelegate.RepeatTime.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("repeatCell", forIndexPath: indexPath) as! DetailDateRepeatCell
        cell.dateRepeatLabel.text = AppDelegate.RepeatTime[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

      
    }
}
    