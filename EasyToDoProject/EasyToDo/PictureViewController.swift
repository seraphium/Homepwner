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
    
    @IBOutlet var scrollView: ImageScrollView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var doubleTapGestureRecognizer: UITapGestureRecognizer!
    
    @IBOutlet var twoFingerTapGestureRecognizer: UITapGestureRecognizer!
    
    var item:Item! {
        didSet {
            navigationItem.title = item.name
        }
    }
    
    var imageStore: ImageStore!
    

    override func viewDidLayoutSubviews() {
        //need to put code to use scrollview frame here due to it will be 600x600 in viewwillappear
        if imageView.image != nil {
            scrollView.contentSize = imageView.image!.size
            let scrollViewFrame = scrollView.frame
            let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
            let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height;
            let minScale = min(scaleWidth, scaleHeight);
            scrollView.minimumZoomScale = minScale;
            
            scrollView.maximumZoomScale = 1.0;
            scrollView.setZoomScale(minScale, animated: true)

        }
       
    }

    override func viewWillAppear(animated: Bool) {
        //hide tabbar
        tabBarController?.tabBar.hidden = true

        
        //get the image key
         let key = item.itemKey
        //if there is associated image , display it on image view
        scrollView.imageView = imageView

        if let imageToDisplay = imageStore.imageForKey(key) {
            imageView.image = imageToDisplay
        } else {
            takePic()
        }
      

    }
    
    override func viewWillDisappear(animated: Bool) {
            tabBarController?.tabBar.hidden = false
    
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
//TODO: why popViewController doesn't work ?
        navigationController?.popToRootViewControllerAnimated(true)
        
    }
    
    //MARK: - controller
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        //get image from info directory
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        //put image into cache
        imageStore.setImage(image, forKey: item.itemKey)
        
        //put the image into imageview
        imageView.image = image
        scrollView.imageView.image = image
        
        //take imagePicker off screen
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        let choosePictureString = NSLocalizedString("PictureViewChoosePicture", comment: "")
        if(imagePicker.sourceType == UIImagePickerControllerSourceType.Camera){
            let button = UIBarButtonItem(title: choosePictureString, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(choosePicture))
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
    
    func takePic(){
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
    
    @IBAction func takePicture(sender: UIBarButtonItem) {
        takePic()
        
    }

    //MARK: - zooming logic
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
 
 }
    
    //MARK: - gesture logic
    @IBAction func twoFingerTapped(sender: UITapGestureRecognizer) {
         var newZoomScale = scrollView.zoomScale / 1.5
        newZoomScale = max(newZoomScale, scrollView.minimumZoomScale);
        //imageView.alpha = 0
        scrollView.setZoomScale(newZoomScale, animated: true)
        
    }
    
    @IBAction func doubleTapped(sender: UITapGestureRecognizer) {
        print ("double tapped");
       
        let pointInView = doubleTapGestureRecognizer.locationInView(imageView)
        
        var newZoomScale = self.scrollView.zoomScale * 1.5;
        newZoomScale = min(newZoomScale, scrollView.maximumZoomScale);
        
        let scrollViewSize = scrollView.bounds.size;
        
        let w = scrollViewSize.width / newZoomScale;
        let h = scrollViewSize.height / newZoomScale;
        let x = pointInView.x - (w / 2.0);
        let y = pointInView.y - (h / 2.0);
        
        let rectToZoomTo = CGRectMake(x, y, w, h);
        
        //imageView.alpha = 0
        scrollView.zoomToRect(rectToZoomTo, animated: true)
        
    }
    
}
