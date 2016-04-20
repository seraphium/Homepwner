//
//  PictureViewController.swift
//  Homepwner
//
//  Created by Jackie Zhang on 16/4/20.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class PictureViewController : UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate
 {
    
    let imagePicker = UIImagePickerController()
    @IBOutlet var imageView: UIImageView!
    
    var item:Item! {
        didSet {
            navigationItem.title = item.name
        }
    }
    
    var imageStore: ImageStore!
    
    func showCamera(){
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
    }
    
    func choosePicture(){
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
    }
    
    override func viewWillAppear(animated: Bool) {
        //get the image key
         let key = item.itemKey
        //if there is associated image , display it on image view
         let imageToDisplay = imageStore.imageForKey(key)
        imageView.image = imageToDisplay
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

    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if(imagePicker.sourceType == UIImagePickerControllerSourceType.Camera){
            let button = UIBarButtonItem(title: "Choose picture", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(choosePicture))
            viewController.navigationItem.rightBarButtonItem = button
            viewController.navigationController?.navigationBarHidden = false
            viewController.navigationController?.navigationBar.translucent = true
        }
    }
    
    @IBAction func takePicture(sender: UIBarButtonItem) {
        
        
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

    
}
