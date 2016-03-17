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
    @IBOutlet var serialField: UITextField!
    @IBOutlet var valueField: UITextField!
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var imageView: UIImageView!
    
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
    
    @IBAction func backgroundTapped(sender: AnyObject) {
        
        view.endEditing(true)
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
        formatter.timeStyle = .NoStyle
        return formatter
    }()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        nameField.text = item.name
        serialField.text = item.serialNumber
        valueField.text = numberFormatter.stringFromNumber(item.valueInDollars)
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
        item.serialNumber = serialField.text
        
        if let valueText = valueField.text,
            value =  numberFormatter.numberFromString(valueText) {
                item.valueInDollars = value.integerValue
        } else {
            item.valueInDollars = 0
        }
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
