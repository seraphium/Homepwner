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
    let repeatTime = [ "每天",  "每周" , "每月", "每年"]
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repeatTime.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("repeatCell", forIndexPath: indexPath) as! DetailDateRepeatCell
        cell.dateRepeatLabel.text = repeatTime[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //should back to last vc d
    }
}
    