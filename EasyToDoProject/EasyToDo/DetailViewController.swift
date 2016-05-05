//
//  DetailViewController.swift
//  Homepwner
//
//  Created by Jackie Zhang on 16/3/16.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class DetailViewController : UITableViewController, UITextFieldDelegate,  UITextViewDelegate,UINavigationControllerDelegate
{
    
    
    
    var datePicker : UIDatePicker!
    @IBOutlet var dateExpandSwitch: UISwitch!
    
    var dateExpand : Bool = false
    
    var item:Item! {
        didSet {
            navigationItem.title = item.name
        }
    }
    
    
    var repeatString : String? {
        didSet {
            tableView.reloadSections(NSIndexSet(index:2), withRowAnimation: .Automatic)
        }
    }
    
    var imageStore: ImageStore!
    
    let numberFormatter : NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    let dateFormatter : NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        formatter.locale = NSLocale(localeIdentifier: "zh_CN")
        return formatter
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        datePicker = UIDatePicker()
        datePicker.locale = NSLocale(localeIdentifier: "zh_CN")
        datePicker.datePickerMode = .DateAndTime
        datePicker.date = NSDate() //initial value
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.tag == 111 && textField.text != nil{
            //nameField
            item.name = textField.text!
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.tag == 222 && textView.text != nil {
            item.detail = textView.text!
        }
    }
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField.tag != 123 {
            if  datePicker.superview != nil {
                datePicker.removeFromSuperview()
            }
            return true
        }
        
        
        let alertController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: "确定", style: .Default) {
            (alertAction) -> Void in
            //trunc date by set sec to 0
            let date = self.datePicker.date
            var minuteDate : NSDate?
            NSCalendar.currentCalendar().rangeOfUnit(NSCalendarUnit.Minute,
                startDate: &minuteDate,
                interval: nil,
                forDate: date)
            
            self.item.dateToNotify = minuteDate!
            
            AppDelegate.scheduleNotifyForDate(minuteDate!, withRepeatInteval: nil, onItem: self.item, withTitle: self.item.name, withBody: self.item.detail)
            self.tableView.reloadData()

            })
        alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        alertController.view.addSubview(datePicker)
        self.presentViewController(alertController, animated:true, completion: nil)
        
        return false;
    }
    

    
       
    @IBAction func backgroundTapped(sender: UITapGestureRecognizer) {

        view.endEditing(true)
        
    }
  
  
    override func viewDidLoad() {
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
      override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //clear the first responder (keyboard)
        view.endEditing(true)
        
        //pass back the changed value
      /*  item.name = nameField.text ?? ""
        item.detail = detailField.text
        if let text = dateToNotifyField.text {
            item.dateToNotify = dateFormatter.dateFromString(text)
*/
        }
        
      
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - table view delegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "名称"
        case 1:
            return "详情"
        case 2:
            return "提醒"
        case 3:
            return "照片"
        default:
            return ""
        }
    }
    
    
    //MARK: - tableview actions
    override func tableView(tableView : UITableView, numberOfRowsInSection section : Int) -> Int{
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            if dateExpand {
                return 3
            }
            return 1
        case 3:
            return 1
        default:
            return 0
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //no normal selection
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("nameCell", forIndexPath: indexPath) as! DetailNameCell
            cell.nameField.text = item.name
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("detailCell", forIndexPath: indexPath) as! DetailDetailCell
                cell.detailField.text = item.detail
            return cell
        case 2:
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCellWithIdentifier("dateToNotifyCell", forIndexPath: indexPath) as! DetailDateToNotifyCell
                cell.dateExpandSwitch.setOn(dateExpand, animated: true)
                return cell
            }
            if dateExpand {
                if indexPath.row == 1{
                    let cell = tableView.dequeueReusableCellWithIdentifier("detailDateInfoCell", forIndexPath: indexPath) as! DetailDateInfoCell
                    if let date = item.dateToNotify {
                        cell.dateToNotifyField.text = dateFormatter.stringFromDate(date)
                    }
                    else {
                        cell.dateToNotifyField.text = "请选择时间"
                    }
                    return cell
                }
                if indexPath.row == 2{
                    let cell = tableView.dequeueReusableCellWithIdentifier("detailDateRepeatCell", forIndexPath: indexPath) as! DetailDateRepeatCell
                    if let str = repeatString {
                        cell.dateRepeatLabel.text = str
                    }
                    return cell
                }

            }
            //default value
            return UITableViewCell()
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("picCell", forIndexPath: indexPath) as! DetailPicCell
            cell.picField.text = "点击添加照片"
            let key = item.itemKey
            //if there is associated image , display it on image view
            if let imageToDisplay = imageStore.imageForKey(key) {
                cell.imageView!.image = imageToDisplay
            }

            return cell
        default:
            return UITableViewCell()
            
        }
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "ShowPicture" {
            let detailViewController = segue.destinationViewController as! PictureViewController
            detailViewController.item = item
            detailViewController.imageStore = imageStore
            
        }
        
        if segue.identifier == "ShowRepeat" {
            let repeatController = segue.destinationViewController as! RepeatViewController
            repeatController.item = item
        }

        
    }
    
    @IBAction func dateExpandValueChanged(sender: UISwitch) {
            dateExpand = !dateExpand
            tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .Automatic)
        
        }
    

    
    
}
