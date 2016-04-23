//
//  PictureViewController.swift
//  Homepwner
//
//  Created by Jackie Zhang on 16/4/20.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class PictureViewController : UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIScrollViewDelegate
 {
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var doubleTapGestureRecognizer: UITapGestureRecognizer!
    
    @IBOutlet var twoFingerTapGestureRecognizer: UITapGestureRecognizer!
    
    var item:Item! {
        didSet {
            navigationItem.title = item.name
        }
    }
    
    var imageStore: ImageStore!
    

    override func viewWillAppear(animated: Bool) {
        //get the image key
         let key = item.itemKey
        //if there is associated image , display it on image view
         let imageToDisplay = imageStore.imageForKey(key)
        imageView.image = imageToDisplay
        scrollView.contentSize = imageToDisplay!.size
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height;
        let minScale = min(scaleWidth, scaleHeight);
        scrollView.minimumZoomScale = minScale;
        
        // 5
        scrollView.maximumZoomScale = 1.0;
        scrollView.zoomScale = minScale;
        
        centerScrollViewContents()
        
    }
    

    //MARK: - controller
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
    
    //MARK: - customized action
    func showCamera(){
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
    }
    
    func choosePicture(){
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
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

    //MARK: - zooming logic
    func centerScrollViewContents() {
        let boundsSize = scrollView.bounds.size;
        var contentsFrame = self.imageView.frame;
        if (contentsFrame.size.width < boundsSize.width) {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0;
        }
        else {
            contentsFrame.origin.x = 0.0;
        }
        if (contentsFrame.size.height < boundsSize.height) {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0;
        } else {
            contentsFrame.origin.y = 0.0;
        }
        
        imageView.frame = contentsFrame;
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        centerScrollViewContents()
    }
    
    //MARK: - gesture logic
    @IBAction func twoFingerTapped(sender: UITapGestureRecognizer) {
         var newZoomScale = scrollView.zoomScale / 1.5
        newZoomScale = max(newZoomScale, scrollView.minimumZoomScale);
        
        scrollView.setZoomScale(newZoomScale, animated: true)
        
    }
    
    @IBAction func doubleTapped(sender: UITapGestureRecognizer) {
        print ("double tapped");
       
        
        let pointInView = doubleTapGestureRecognizer.locationInView(imageView)
        
        // 2
        var newZoomScale = self.scrollView.zoomScale * 1.5;
        newZoomScale = min(newZoomScale, scrollView.maximumZoomScale);
        
        // 3
        let scrollViewSize = scrollView.bounds.size;
        
        let w = scrollViewSize.width / newZoomScale;
        let h = scrollViewSize.height / newZoomScale;
        let x = pointInView.x - (w / 2.0);
        let y = pointInView.y - (h / 2.0);
        
        let rectToZoomTo = CGRectMake(x, y, w, h);
        
        // 4
        scrollView.zoomToRect(rectToZoomTo, animated: true)
        
    }
    
}
