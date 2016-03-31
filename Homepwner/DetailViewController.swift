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
