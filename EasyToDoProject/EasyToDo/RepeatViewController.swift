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
    
    override func viewWillAppear(animated: Bool) {
        tableView.backgroundColor = UIColor(red: 206.0/255.0, green: 203.0/255.0, blue: 188.0/255.0, alpha: 1.0)
        tableView.sectionIndexColor = UIColor.whiteColor()
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let c = cell as! BaseCell
        c.InitCellViews()
        //  c.openAnimation(0.0,completion: nil)
        
        
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("repeatCell", forIndexPath: indexPath) as! DetailDateRepeatCell
        cell.dateRepeatLabel.text = AppDelegate.RepeatTime[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let interval = AppDelegate.NSCalenderUnitFromRepeatInterval(indexPath.row)
        if let date = item?.dateToNotify, name = item?.name {
                AppDelegate.scheduleNotifyForDate(date, withRepeatInteval: interval, onItem: item!, withTitle: name, withBody: item?.detail)

            }
        
        
        item?.repeatInterval = indexPath.row
        //return to last viewcontroller with selected repeat string
        navigationController?.popViewControllerAnimated(true)
  
        
      
    }
}
    