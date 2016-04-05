//
//  DetailViewController.swift
//  Homepwner
//
//  Created by Jackie Zhang on 16/3/16.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class DetailViewController : UIViewController, UITextFieldDelegate,  UINavigationControllerDelegate,
    UIImagePickerControllerDelegate
{
    
    @IBOutlet var nameField: UITextField!
    @IBOutlet var detailField: UITextField!
    @IBOutlet var dateToNotifyField: UITextField!
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var imageView: UIImageView!
    
    var datePicker : UIDatePicker!

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        datePicker = UIDatePicker()
        datePicker.locale = NSLocale(localeIdentifier: "zh_CN")
        datePicker.datePickerMode = .DateAndTime
        datePicker.date = NSDate() //initial value
       

    }
    
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField.tag != 123 {
            if  datePicker.superview != nil {
                datePicker.removeFromSuperview()
            }
            return true
        }

        nameField.resignFirstResponder()
        detailField.resignFirstResponder()
        let alertController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: "确定", style: .Default) {
            (alertAction) -> Void in
            let selectedDateTime = self.datePicker.date;
            self.dateToNotifyField.text = self.dateFormatter.stringFromDate(selectedDateTime)
            })
        alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        alertController.view.addSubview(datePicker)
        self.presentViewController(alertController, animated:true, completion: nil)
    
        return false;
    }
    
    @IBAction func backgroundTapped(sender: UITapGestureRecognizer) {

        view.endEditing(true)
        
    }
    
    @IBAction func takePicture(sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        
        //see if camera supported, if not , pick from library
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            imagePicker.sourceType  = .Camera
        }
        else {
            imagePicker.sourceType = .PhotoLibrary
        }
        
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    
    
    var item:Item! {
        didSet {
            navigationItem.title = item.name
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
        formatter.timeStyle = .MediumStyle
        formatter.locale = NSLocale(localeIdentifier: "zh_CN")
        return formatter
    }()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        nameField.text = item.name
        detailField.text = item.detail
        dateToNotifyField.text = dateFormatter.stringFromDate(item.dateToNotify)
        dateLabel.text = dateFormatter.stringFromDate(item.dateCreated)
        
        
        //get the image key
        let key = item.itemKey
        //if there is associated image , display it on image view
        let imageToDisplay = imageStore.imageForKey(key)
        imageView.image = imageToDisplay
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //clear the first responder (keyboard)
        view.endEditing(true)
        
        //pass back the changed value
        item.name = nameField.text ?? ""
        item.detail = detailField.text
        item.dateToNotify = dateFormatter.dateFromString(dateToNotifyField.text!)!
        
      
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        //get image from info directory
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        //put image into cache
        imageStore.setImage(image, forKey: item.itemKey)
        
        //put the image into imageview
        imageView.image = image
        
        //take imagePicker off screen
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
