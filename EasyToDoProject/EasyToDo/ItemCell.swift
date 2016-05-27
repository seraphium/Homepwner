//
//  ItemCell.swift
//  Homepwner
//
//  Created by Jackie Zhang on 16/3/8.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit


protocol PresentNotifyProtocol : NSObjectProtocol {
    func presentNotify(controller: UIViewController) -> Void;
}

class ItemCell : BaseCell , UITextFieldDelegate, UITextViewDelegate{
    
    @IBOutlet var foregroundView: UIView!
    
    @IBOutlet var foldView: UIView!

    @IBOutlet weak var foldAnimationView: UIView!
    
    @IBOutlet var indicatorView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet var notifyDateLabel: UILabel!

    @IBOutlet var doneButton: UIButton!

    //foldview content
    @IBOutlet weak var detailTextView: UITextView!
    
    @IBOutlet weak var detailNotifyDate: UITextField!
    
    @IBOutlet weak var detailAddPhoto: UIButton!

    weak var delegate: PresentNotifyProtocol?
    
    var expired : Bool = false
    
    let indicatorLayer = CAShapeLayer()
    var indicatorPath = UIBezierPath()
    
    var item:Item!
    
    var dateExpand : Bool = false
    
    var datePicker : UIDatePicker!
    
    //tag if in clear notify date status
    var cleaningItem : Bool = false
    
    
    @IBOutlet var repeatSelector: UISegmentedControl!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        

    }
    
    let dateFormatter : NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        return formatter
    }()

    
    override internal func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.tintColor = UIColor.whiteColor()
        
        foldAnimationView.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        foldAnimationView.frame = foldView.frame
        
        detailTextView.delegate = self
        detailTextView.layer.cornerRadius = 5
        
        detailNotifyDate.delegate = self
        
        datePicker = UIDatePicker()
        datePicker.locale = NSLocale(localeIdentifier: "zh_CN")
        datePicker.datePickerMode = .DateAndTime
        datePicker.date = NSDate() //initial value
        
        foregroundView.backgroundColor = AppDelegate.cellInnerColor
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let it = item {
            if let detail = it.detail {
                detailTextView.text = detail
            }
            if let date = it.dateToNotify {
                detailNotifyDate.text = dateFormatter.stringFromDate(date)  
            }
            repeatSelector.selectedSegmentIndex = item.repeatInterval

        }
        
        if let _ = AppDelegate.imageStore.imageForKey(item.itemKey) {
            detailAddPhoto.setImage(UIImage(named: "camera2"), forState: .Normal)
        }
       
    }

    //find and replace default Reorder Control view
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        for view in subviews {
            if let reorderControlView = view.findSubViewWithString("ReorderControl") {
                for subview in reorderControlView.subviews as! [UIImageView] {
                    if subview.isKindOfClass(UIImageView) {
                    subview.image = UIImage(named: "moveicon")
                        break
                    }
                }
            }

        }
    }
    
    //MARK: - textfield delegate

    func textViewDidEndEditing(textView: UITextView) {
        if textView.tag == 111 && textView.text != nil {
            item.detail = textView.text!
        }
        textView.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

    
    //handling notify date selection
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField.tag != 222 {
            if  datePicker.superview != nil {
                datePicker.removeFromSuperview()
            }
            return true
        }
        //handled the event that clear button clicked on notifyDateField
        if cleaningItem == true {
            cleaningItem = false
            return false
        }
        
        detailTextView.resignFirstResponder()
        
        let alertController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n\n", message: nil,
                              preferredStyle: .ActionSheet)
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
            let dateString = self.dateFormatter.stringFromDate(minuteDate!)
            self.detailNotifyDate.text = dateString
            self.notifyDateLabel.text = self.getNotifyFullString(minuteDate!, repeatIndex: self.item.repeatInterval)
            AppDelegate.scheduleNotifyForDate(minuteDate!,
                withRepeatInteval: self.getIntervalFromIndex(self.item.repeatInterval),
                onItem: self.item,
                withTitle: self.item.name, withBody: self.item.detail)
            
            
            })
        alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        alertController.view.addSubview(datePicker)
        
        if((delegate?.respondsToSelector(Selector("presentNotify:"))) != nil)
        {
            delegate?.presentNotify(alertController);
        }
        
        return false;
    }
    
    func getIntervalFromIndex(index: Int) -> NSCalendarUnit?
    {
       return index == 0 ? nil : AppDelegate.NSCalenderUnitFromRepeatInterval(index)

    }

    func getNotifyFullString( date: NSDate?, repeatIndex : Int) -> String {
        var updatedNotifyString = ""
        if let notif = date {
            updatedNotifyString = dateFormatter.stringFromDate(notif)
            if repeatIndex != 0 {
                updatedNotifyString += "," + AppDelegate.RepeatTime[repeatIndex]
            }
        }

        return updatedNotifyString
    }
    
    //MARK: - textfield delegate
    @IBAction func repeatSelectorValueChanged(sender: UISegmentedControl) {
        //print("selected:" + String(sender.selectedSegmentIndex))
        
        let index = sender.selectedSegmentIndex
        item?.repeatInterval = index
        notifyDateLabel.text = getNotifyFullString(item?.dateToNotify, repeatIndex: index)
        
        if let date = item?.dateToNotify, name = item?.name {
            AppDelegate.scheduleNotifyForDate(date, withRepeatInteval: getIntervalFromIndex(index), onItem: item!, withTitle: name, withBody: item?.detail)
            
        }
        
        

        
    }
    
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        if textField == self.detailNotifyDate {
            if let it = item {
                AppDelegate.cancelNotification(it)
                it.dateToNotify = nil
                notifyDateLabel.text = nil
                cleaningItem = true
            }
        }
        return true

    }
    
    //MARK: - init view
    
    //init expired item indicator view
    func initIndicatorView() {
        indicatorPath = UIBezierPath(ovalInRect: CGRect(x: 0, y: 13, width: 8, height: 8))
        indicatorLayer.backgroundColor = UIColor.clearColor().CGColor
        indicatorLayer.path = indicatorPath.CGPath
        indicatorLayer.fillColor = UIColor.redColor().CGColor
        indicatorView.layer.addSublayer(indicatorLayer)
        
    }
    
    func updateCell(expanded: Bool, finished: Bool, expired: Bool){
        
        self.foldView.hidden = !expanded

        //finished item will not be "Done"able
        if (finished) {
            doneButton.alpha = 0.0
            doneButton.enabled = false
            textField.textColor = UIColor.whiteColor()
            contentView.alpha = 0.4
        } else {
            doneButton.alpha = 0.8
            doneButton.enabled = true
            textField.textColor = UIColor.whiteColor()
            contentView.alpha = 0.8
        }
        
        if expired { //expired notify item
            indicatorView.alpha = 1.0
            self.expired = true
        } else {
            indicatorView.alpha = 0.0
        }
        
       // if item.itemKey{
        //    detailAddPhoto.backgroundImageForState(.Normal) = UIImage("camera2")
       // }

        //update font setting
        let bodyFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        textField.font = bodyFont
        notifyDateLabel.textColor = UIColor.whiteColor()
        
    }
    
    //MARK: - animation setup
    //removed existing animationViews
    private func removeImageItemsFromAnimationView(view: UIView?) {
        
        guard let animationView = view else {
            return
        }
        
        animationView.subviews.forEach({ $0.removeFromSuperview() })
    }
    
    //prepare containerView snapsho timage for animation
    func addImageItemsToAnimationView(sourceView : UIView, destView: UIView?) {
        sourceView.alpha = 1;
        let contSize    = sourceView.bounds.size
        let image       = sourceView.pb_takeSnapshot(CGRect(x: 0, y: 0, width: contSize.width, height: contSize.height))
        let imageView   = UIImageView(image: image)
        imageView.tag   = 0
        destView?.addSubview(imageView)
        
    }
    
    //MARK: open animation
    func slideAnimation(timing: String, from: CGFloat, to: CGFloat, duration: NSTimeInterval, delay:NSTimeInterval, hidden:Bool) {
        
        let slideAnimation = CABasicAnimation(keyPath: "transform.rotation.x")
        slideAnimation.timingFunction      = CAMediaTimingFunction(name: timing)
        slideAnimation.fromValue           = (from)
        slideAnimation.toValue             = (to)
        slideAnimation.duration            = duration
        slideAnimation.delegate            = self;
        slideAnimation.fillMode            = kCAFillModeForwards
        slideAnimation.removedOnCompletion = false;
        slideAnimation.beginTime           = CACurrentMediaTime() + delay
        
        animationLayer.addAnimation(slideAnimation, forKey: "rotation.x")
    }
    
    func openAnimation(delay:NSTimeInterval,completion: CompletionHandler?) {
        
        removeImageItemsFromAnimationView(animationView)
        addImageItemsToAnimationView(containerView, destView: animationView)
        
        animationView.alpha = 1;
        containerView.alpha = 0;
        
        let timing                = kCAMediaTimingFunctionEaseIn
        // let from: CGFloat         = -containerView.bounds.size.width
        //let to: CGFloat           = 0
        
        let from: CGFloat         = CGFloat(-M_PI / 2)
        let to: CGFloat           = 0
        let hidden                = true
        let duration              = NSTimeInterval(0.5)
        
        slideAnimation(timing, from: from, to: to, duration: duration, delay: delay, hidden: hidden)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64((delay + duration) * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.animationView?.alpha = 0
            self.containerView.alpha  = 1
            completion?()
        }
        
    }
    
    //MARK: - Fold animation
    func foldingAnimation(timing: String, from: CGFloat, to: CGFloat, duration: NSTimeInterval, delay:NSTimeInterval) {
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation.x")
        rotateAnimation.timingFunction      = CAMediaTimingFunction(name: timing)
        rotateAnimation.fromValue           = (from)
        rotateAnimation.toValue             = (to)
        rotateAnimation.duration            = duration
        rotateAnimation.delegate            = self;
        rotateAnimation.fillMode            = kCAFillModeForwards
        rotateAnimation.removedOnCompletion = false;
        rotateAnimation.beginTime           = CACurrentMediaTime() + delay
        
        foldAnimationView.layer.addAnimation(rotateAnimation, forKey: "folding")
    }
    
    func expandAnimation(delay:NSTimeInterval,completion: CompletionHandler?) {
        
        foldView.hidden = false
        
        removeImageItemsFromAnimationView(foldAnimationView)
        addImageItemsToAnimationView(foldView, destView: foldAnimationView)
        
        foldView.alpha = 0
      
        foldAnimationView.alpha = 1.0
        foldAnimationView.layer.shouldRasterize = true

        
        let delay: NSTimeInterval = 0
        let timing                = kCAMediaTimingFunctionEaseIn
        let from: CGFloat         = CGFloat(-M_PI / 2)
        let to: CGFloat           = 0
        let duration              = 0.5

        foldingAnimation(timing, from: from, to: to, duration: duration, delay: delay)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.foldAnimationView?.alpha = 0
            self.foldAnimationView.layer.removeAllAnimations()
            self.foldAnimationView.layer.shouldRasterize = false
            self.foldView.alpha  = 1
            completion?()
        }
    }
    
    
    func unExpandAnimation(delay:NSTimeInterval,completion: CompletionHandler?) {
        
        removeImageItemsFromAnimationView(foldAnimationView)
        addImageItemsToAnimationView(foldView, destView: foldAnimationView)
        
        foldView.alpha = 0
        foldAnimationView.alpha = 1.0
        foldAnimationView.layer.shouldRasterize = true
        let delay: NSTimeInterval = 0
        let timing                = kCAMediaTimingFunctionEaseIn
        let from: CGFloat         = 0
        let to: CGFloat           = CGFloat(-M_PI / 2)
        let duration              = 0.5
        
        foldingAnimation(timing, from: from, to: to, duration: duration, delay: delay)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.foldAnimationView?.alpha = 0
            self.foldAnimationView.layer.removeAllAnimations()
            self.foldAnimationView.layer.shouldRasterize = false
            self.foldView.alpha  = 0
            self.foldView.hidden = true

            completion?()
        }
    }

}


extension UIView {
    
    func findSubViewWithString(partialName: String) -> UIView? {
        
        if self.dynamicType.description().rangeOfString("Reorder") != nil {
            return self
        }
        
        for view in subviews as [UIView]
        {
                if let match = view.findSubViewWithString(partialName) {
                    return match
                }
                
        }
        
        return nil

    }


    func pb_takeSnapshot(frame: CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0.0)
        
        let context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, frame.origin.x * -1, frame.origin.y * -1)
        
        guard let currentContext = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        self.layer.renderInContext(currentContext)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
