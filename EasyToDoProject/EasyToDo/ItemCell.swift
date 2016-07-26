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
    
    @IBOutlet weak var animationView: UIView!
    //layer for content view
    var animationLayer : CALayer {
        return animationView.layer
    }

    @IBOutlet var foregroundView: UIView!
    
    @IBOutlet var foldView: UIView!

    var foldAnimationView: UIView!
    
    @IBOutlet var indicatorView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet var notifyDateLabel: UILabel!

    @IBOutlet var doneButton: UIButton!

    //foldview content
    @IBOutlet weak var detailTextView: UITextView!
    
    
    @IBOutlet weak var detailTextViewPlaceholderLabel: UILabel!
    
    @IBOutlet weak var detailNotifyDate: UITextField!
    
    @IBOutlet weak var detailAddPhoto: UIButton!

    @IBOutlet weak var detailDetailLabel: UILabel!
    
    @IBOutlet weak var detailNotifyLabel: UILabel!
    
    @IBOutlet weak var detailRepeatLabel: UILabel!
    
    weak var delegate: PresentNotifyProtocol?
    
    weak var tableView: UITableView!
    weak var calendarView : CalendarView!
        
    var expired : Bool = false
    //indicator
    let indicatorLayer = CAShapeLayer()
    var indicatorPath = UIBezierPath()
    //donebutton
    var doneButtonLayer = CAShapeLayer()
    //up button
    var upButtonLayer = CAShapeLayer()
    
    //camera button
    var cameraButtonLayer = CAShapeLayer()
    
    //audio button
    var audioButtonLayer = CAShapeLayer()
    var item:Item!
    
    var expanded : Bool = false
    var datePicker : UIDatePicker!
    var initializeDate : Date?
    
    //tag if in clear notify date status
    var cleaningItem : Bool = false
    
    @IBOutlet var repeatSelector: UISegmentedControl!
    
    @IBOutlet var detailAddAudio: UIButton!
    
    
    let dateFormatter : NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        return formatter
    }()

    
    override internal func awakeFromNib() {
        super.awakeFromNib()
        
        foldView.backgroundColor = AppDelegate.cellColor
        datePicker = UIDatePicker()
        //datePicker.locale = NSLocale(localeIdentifier: "zh_CN")
        datePicker.datePickerMode = .DateAndTime
        
        detailTextView.delegate = self
        detailNotifyDate.delegate = self

        detailNotifyDate.placeholder = NSLocalizedString("ItemListDetailDateNotifyPlaceHolder", comment: "")
        
        //update font setting
        let bodyFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        textField.font = bodyFont
        textField.tintColor = AppDelegate.cellColor
        
        detailTextViewPlaceholderLabel.text = NSLocalizedString("ItemListDetailViewPlaceHolder", comment: "")
        
        //mimic default placeholder font and size/color
        detailTextViewPlaceholderLabel.font = UIFont(name: "HelveticaNeue", size: 14.0)
        detailTextViewPlaceholderLabel.textColor = UIColor(red: 199.0/255.0, green: 199.0/255.0, blue: 205.0/255, alpha: 1.0)
        
        
        doneButton.contentHorizontalAlignment = .Fill
        doneButton.contentVerticalAlignment = .Fill
        
        
        foldAnimationView = UIView()
        foldAnimationView.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        foldAnimationView.frame = foldView.frame
        
        containerView.addSubview(foldAnimationView)
        
        foregroundView.backgroundColor = AppDelegate.cellInnerColor
        
        let foregroundTextColor = AppDelegate.backColor
        let foldTextColor = AppDelegate.cellInnerColor
        contentView.tintColor = foldTextColor
        
        textField.textColor = foregroundTextColor
        notifyDateLabel.textColor = foregroundTextColor
        
        detailTextView.textColor = foldTextColor
        detailNotifyDate.textColor = foldTextColor
        detailDetailLabel.textColor = foldTextColor
        detailNotifyLabel.textColor = foldTextColor
        detailRepeatLabel.textColor = foldTextColor
        
        setCellCornerRadius(expanded, animated: false)

        //init customized path layer
        initIndicatorView()
        initDoneButtonLayer()
        initUpButtonLayer()
        initCameraButtonView()
        initAudioButtonView()
        
    }


    override func setCellCornerRadius(expanded: Bool, animated: Bool)
    {
        super.setCellCornerRadius(expanded, animated: animated)
        if (animated) {
            let from = CGFloat(expanded ? cornerRadius : 0)
            let to = CGFloat(expanded ? 0 : cornerRadius)
            foregroundView.addCornerRadiusAnimation(from, to: to, duration: 0.5)
            animationView.addCornerRadiusAnimation(from, to: to, duration: 0.5)
        } else {
            foregroundView.layer.cornerRadius = cornerRadius
            animationView.layer.cornerRadius = cornerRadius
            
        }


    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        createView(animationLayer)

        setupShadow()
        
        // init audio/pic button status
        if let it = item {
            if let _ = AppDelegate.imageStore.imageForKey(it.itemKey) {
               updateButtonLayerStatus(cameraButtonLayer, hasItem: true)
            } else {
                updateButtonLayerStatus(cameraButtonLayer, hasItem: false)
            }
            if let url = AppDelegate.audioStore.audioURLForKey(it.itemKey) {
                if AppDelegate.audioStore.hasAudioForURL(url) {
                    updateButtonLayerStatus(audioButtonLayer, hasItem: true)
                } else {
                    updateButtonLayerStatus(audioButtonLayer, hasItem: false)

                }
            }
        }
        
        
        //initialize delete button text color in editing mode
        for subview in self.subviews {
            for subview2 in subview.subviews {
                if let button = subview2 as? UIButton { button.setTitleColor(UIColor.redColor(), forState: .Normal) }
            }
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
    func textViewDidChange(textView: UITextView) {
        if textView.hasText() {
            detailTextViewPlaceholderLabel.hidden = true
        } else {
            detailTextViewPlaceholderLabel.hidden = false
        }
        
        
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        detailTextViewPlaceholderLabel.hidden = true

    }
    
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
        let okString = NSLocalizedString("ItemCellDateSelectorOK", comment: "")
        let cancelString = NSLocalizedString("ItemCellDateSelectorCancel", comment: "")
        let alertController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n\n", message: nil,
                              preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: okString, style: .Default) {
            (alertAction) -> Void in
            //trunc date by set sec to 0
            let date = self.datePicker.date
            var minuteDate : NSDate?
            NSCalendar.currentCalendar().rangeOfUnit(NSCalendarUnit.Minute,
                startDate: &minuteDate,
                interval: nil,
                forDate: date)
            var oldDate : Date? = nil
            if let date = self.item.dateToNotify  {
                oldDate = Date(date: date)
            }
            self.item.dateToNotify = minuteDate!
            let dateString = self.dateFormatter.stringFromDate(minuteDate!)
            self.detailNotifyDate.text = dateString
            self.notifyDateLabel.text = self.getNotifyFullString(minuteDate!, repeatIndex: self.item.repeatInterval)
            
            if Date(date: minuteDate!) != oldDate {  //day is changed, this cell should not show in selected date anymore,  need to reload calendar and table
                self.calendarView.reloadData()
                self.tableView.reloadData()
            }
            
            AppDelegate.scheduleNotifyForDate(minuteDate!,
                withRepeatInteval: self.getIntervalFromIndex(self.item.repeatInterval),
                onItem: self.item,
                withTitle: self.item.name, withBody: self.item.detail)
            
            
            })
        alertController.addAction(UIAlertAction(title: cancelString, style: .Cancel, handler: nil))
        //add 30 minutes frm current date as default notify date
        datePicker.date = item.dateToNotify ?? NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Minute, value: 30, toDate: NSDate(), options: NSCalendarOptions(rawValue: 0))!
        
        alertController.view.addSubview(datePicker)

        delegate?.presentNotify(alertController);
        
        return false;
    }
    
    func getIntervalFromIndex(index: Int) -> NSCalendarUnit?
    {
       return index == 0 ? nil : AppDelegate.NSCalenderUnitFromRepeatInterval(index)

    }

    func getNotifyFullString(date: NSDate?, repeatIndex : Int) -> String {
        guard let notifDate = date else {
            return ""
        }
        let currentTime = NSDate()
        let expiredString = NSLocalizedString("ItemCellDateAlreadyExpired", comment: "")
        if notifDate.earlierDate(currentTime) == notifDate {
            return expiredString
        }
        var outputString = NSLocalizedString("ItemCellDateStillLeft", comment: "")
        outputString += " "
        var outputStep = 2
        let calender = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let component = calender?.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: currentTime, toDate: notifDate, options: [])
        if outputStep > 0 && component?.year > 0 {
            outputString += String(component!.year) + NSLocalizedString("ItemCellDateLeftYear", comment: "")
            outputStep -= 1
        }
        if outputStep > 0 && component?.month > 0 {
            outputString += String(component!.month) + NSLocalizedString("ItemCellDateLeftMonth", comment: "")
            outputStep -= 1
        }
        if outputStep > 0 && component?.day > 0 {
            outputString += String(component!.day) + NSLocalizedString("ItemCellDateLeftDay", comment: "")
            outputStep -= 1
        }
        if outputStep > 0 && component?.hour > 0 {
            outputString += String(component!.hour) + NSLocalizedString("ItemCellDateLeftHour", comment: "")

            outputStep -= 1
        }
        if outputStep > 0 {
            let minutesLeft = component!.minute
            if minutesLeft > 0 {
                outputString += String(minutesLeft)
            } else {
                outputString += "<1"

            }
            outputString +=  NSLocalizedString("ItemCellDateLeftMin", comment: "")
            outputStep -= 1	
        }

        return outputString
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
    
    func initUpButtonLayer() {
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: 30.06, y: 16.3))
        bezierPath.addCurveToPoint(CGPoint(x: 29.35, y: 18.14), controlPoint1: CGPoint(x: 30.06, y: 17.34), controlPoint2: CGPoint(x: 30.06, y: 17.34))
        bezierPath.addLineToPoint(CGPoint(x: 27.9, y: 19.67))
        bezierPath.addCurveToPoint(CGPoint(x: 26.15, y: 20.44), controlPoint1: CGPoint(x: 27.17, y: 20.44), controlPoint2: CGPoint(x: 27.17, y: 20.44))
        bezierPath.addCurveToPoint(CGPoint(x: 24.42, y: 19.67), controlPoint1: CGPoint(x: 25.11, y: 20.44), controlPoint2: CGPoint(x: 25.11, y: 20.44))
        bezierPath.addLineToPoint(CGPoint(x: 18.76, y: 13.7))
        bezierPath.addLineToPoint(CGPoint(x: 18.76, y: 28.04))
        bezierPath.addCurveToPoint(CGPoint(x: 18.03, y: 29.77), controlPoint1: CGPoint(x: 18.76, y: 29.1), controlPoint2: CGPoint(x: 18.76, y: 29.1))
        bezierPath.addCurveToPoint(CGPoint(x: 16.29, y: 30.43), controlPoint1: CGPoint(x: 17.31, y: 30.43), controlPoint2: CGPoint(x: 17.31, y: 30.43))
        bezierPath.addLineToPoint(CGPoint(x: 13.83, y: 30.43))
        bezierPath.addCurveToPoint(CGPoint(x: 12.08, y: 29.77), controlPoint1: CGPoint(x: 12.81, y: 30.43), controlPoint2: CGPoint(x: 12.81, y: 30.43))
        bezierPath.addCurveToPoint(CGPoint(x: 11.36, y: 28.04), controlPoint1: CGPoint(x: 11.36, y: 29.1), controlPoint2: CGPoint(x: 11.36, y: 29.1))
        bezierPath.addLineToPoint(CGPoint(x: 11.36, y: 13.7))
        bezierPath.addLineToPoint(CGPoint(x: 5.7, y: 19.67))
        bezierPath.addCurveToPoint(CGPoint(x: 3.97, y: 20.44), controlPoint1: CGPoint(x: 5.01, y: 20.44), controlPoint2: CGPoint(x: 5.01, y: 20.44))
        bezierPath.addCurveToPoint(CGPoint(x: 2.23, y: 19.67), controlPoint1: CGPoint(x: 2.93, y: 20.44), controlPoint2: CGPoint(x: 2.93, y: 20.44))
        bezierPath.addLineToPoint(CGPoint(x: 0.79, y: 18.14))
        bezierPath.addCurveToPoint(CGPoint(x: 0.06, y: 16.3), controlPoint1: CGPoint(x: 0.06, y: 17.36), controlPoint2: CGPoint(x: 0.06, y: 17.36))
        bezierPath.addCurveToPoint(CGPoint(x: 0.79, y: 14.45), controlPoint1: CGPoint(x: 0.06, y: 15.22), controlPoint2: CGPoint(x: 0.06, y: 15.22))
        bezierPath.addLineToPoint(CGPoint(x: 13.33, y: 1.18))
        bezierPath.addCurveToPoint(CGPoint(x: 15.06, y: 0.43), controlPoint1: CGPoint(x: 14, y: 0.43), controlPoint2: CGPoint(x: 14, y: 0.43))
        bezierPath.addCurveToPoint(CGPoint(x: 16.81, y: 1.18), controlPoint1: CGPoint(x: 16.1, y: 0.43), controlPoint2: CGPoint(x: 16.1, y: 0.43))
        bezierPath.addLineToPoint(CGPoint(x: 29.35, y: 14.45))
        bezierPath.addCurveToPoint(CGPoint(x: 30.06, y: 16.3), controlPoint1: CGPoint(x: 30.06, y: 15.25), controlPoint2: CGPoint(x: 30.06, y: 15.25))
        bezierPath.closePath()
        bezierPath.miterLimit = 4;

        upButtonLayer.backgroundColor = UIColor.clearColor().CGColor
        upButtonLayer.path = bezierPath.CGPath
        upButtonLayer.fillColor = AppDelegate.cellColor.CGColor
        upButtonLayer.fillRule = kCAFillRuleEvenOdd
        

    }
    
    func initDoneButtonLayer() {
        
        //// Bezier Drawing
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 13.99, y: 26.22))
        path.addLineToPoint(CGPoint(x: 13.99, y: 26.22))
        path.addCurveToPoint(CGPoint(x: 26.25, y: 13.97), controlPoint1: CGPoint(x: 20.76, y: 26.22), controlPoint2: CGPoint(x: 26.25, y: 20.74))
        path.addCurveToPoint(CGPoint(x: 13.99, y: 1.71), controlPoint1: CGPoint(x: 26.25, y: 7.2), controlPoint2: CGPoint(x: 20.76, y: 1.71))
        path.addCurveToPoint(CGPoint(x: 1.74, y: 13.97), controlPoint1: CGPoint(x: 7.23, y: 1.71), controlPoint2: CGPoint(x: 1.74, y: 7.2))
        path.addCurveToPoint(CGPoint(x: 13.99, y: 26.22), controlPoint1: CGPoint(x: 1.74, y: 20.74), controlPoint2: CGPoint(x: 7.23, y: 26.22))
        path.addLineToPoint(CGPoint(x: 13.99, y: 26.22))
        path.closePath()
        path.moveToPoint(CGPoint(x: 13.99, y: 27.97))
        path.addLineToPoint(CGPoint(x: 13.99, y: 27.97))
        path.addCurveToPoint(CGPoint(x: -0.01, y: 13.97), controlPoint1: CGPoint(x: 6.26, y: 27.97), controlPoint2: CGPoint(x: -0.01, y: 21.7))
        path.addCurveToPoint(CGPoint(x: 13.99, y: -0.04), controlPoint1: CGPoint(x: -0.01, y: 6.23), controlPoint2: CGPoint(x: 6.26, y: -0.04))
        path.addCurveToPoint(CGPoint(x: 28, y: 13.97), controlPoint1: CGPoint(x: 21.73, y: -0.04), controlPoint2: CGPoint(x: 28, y: 6.23))
        path.addCurveToPoint(CGPoint(x: 13.99, y: 27.97), controlPoint1: CGPoint(x: 28, y: 21.7), controlPoint2: CGPoint(x: 21.73, y: 27.97))
        path.addLineToPoint(CGPoint(x: 13.99, y: 27.97))
        path.closePath()
        path.moveToPoint(CGPoint(x: 22.03, y: 10.52))
        path.addLineToPoint(CGPoint(x: 12.97, y: 19.58))
        path.addLineToPoint(CGPoint(x: 12.97, y: 19.58))
        path.addCurveToPoint(CGPoint(x: 11.43, y: 19.77), controlPoint1: CGPoint(x: 12.55, y: 20), controlPoint2: CGPoint(x: 11.92, y: 20.06))
        path.addCurveToPoint(CGPoint(x: 11.18, y: 19.58), controlPoint1: CGPoint(x: 11.34, y: 19.72), controlPoint2: CGPoint(x: 11.25, y: 19.66))
        path.addLineToPoint(CGPoint(x: 11.18, y: 19.58))
        path.addLineToPoint(CGPoint(x: 5.96, y: 14.36))
        path.addCurveToPoint(CGPoint(x: 5.96, y: 12.57), controlPoint1: CGPoint(x: 5.47, y: 13.87), controlPoint2: CGPoint(x: 5.47, y: 13.07))
        path.addCurveToPoint(CGPoint(x: 7.75, y: 12.57), controlPoint1: CGPoint(x: 6.46, y: 12.08), controlPoint2: CGPoint(x: 7.26, y: 12.08))
        path.addLineToPoint(CGPoint(x: 12.07, y: 16.89))
        path.addLineToPoint(CGPoint(x: 20.24, y: 8.73))
        path.addCurveToPoint(CGPoint(x: 22.03, y: 8.73), controlPoint1: CGPoint(x: 20.73, y: 8.23), controlPoint2: CGPoint(x: 21.53, y: 8.23))
        path.addCurveToPoint(CGPoint(x: 22.03, y: 10.52), controlPoint1: CGPoint(x: 22.52, y: 9.22), controlPoint2: CGPoint(x: 22.52, y: 10.03))
        path.addLineToPoint(CGPoint(x: 22.03, y: 10.52))
        path.closePath()
        path.miterLimit = 4;
        
        doneButtonLayer.backgroundColor = UIColor.clearColor().CGColor
        doneButtonLayer.path = path.CGPath
        doneButtonLayer.fillColor = AppDelegate.cellColor.CGColor
        doneButtonLayer.fillRule = kCAFillRuleEvenOdd


    }
    
    func setupDoneButton(done: Bool) {
        doneButton.layer.sublayers?.removeAll()
        if !done {
            doneButton.layer.addSublayer(doneButtonLayer)

        } else {
            doneButton.layer.addSublayer(upButtonLayer)
        }}
    
    func initCameraButtonView()
    {
        
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: 8.33, y: 0))
        bezierPath.addLineToPoint(CGPoint(x: 16.67, y: 0))
        bezierPath.addLineToPoint(CGPoint(x: 18.75, y: 3))
        bezierPath.addLineToPoint(CGPoint(x: 21.88, y: 3))
        bezierPath.addCurveToPoint(CGPoint(x: 24.08, y: 3.9), controlPoint1: CGPoint(x: 23.17, y: 3), controlPoint2: CGPoint(x: 23.17, y: 3))
        bezierPath.addCurveToPoint(CGPoint(x: 25, y: 6.03), controlPoint1: CGPoint(x: 25, y: 4.79), controlPoint2: CGPoint(x: 25, y: 4.79))
        bezierPath.addLineToPoint(CGPoint(x: 25, y: 17.02))
        bezierPath.addCurveToPoint(CGPoint(x: 24.08, y: 19.13), controlPoint1: CGPoint(x: 25, y: 18.26), controlPoint2: CGPoint(x: 25, y: 18.26))
        bezierPath.addCurveToPoint(CGPoint(x: 21.88, y: 20), controlPoint1: CGPoint(x: 23.17, y: 20), controlPoint2: CGPoint(x: 23.17, y: 20))
        bezierPath.addLineToPoint(CGPoint(x: 3.12, y: 20))
        bezierPath.addCurveToPoint(CGPoint(x: 0.92, y: 19.12), controlPoint1: CGPoint(x: 1.83, y: 20), controlPoint2: CGPoint(x: 1.83, y: 20))
        bezierPath.addCurveToPoint(CGPoint(x: 0, y: 17), controlPoint1: CGPoint(x: 0, y: 18.24), controlPoint2: CGPoint(x: -0, y: 18.24))
        bezierPath.addLineToPoint(CGPoint(x: 0, y: 6.02))
        bezierPath.addCurveToPoint(CGPoint(x: 0.92, y: 3.89), controlPoint1: CGPoint(x: 0, y: 4.77), controlPoint2: CGPoint(x: 0, y: 4.77))
        bezierPath.addCurveToPoint(CGPoint(x: 3.12, y: 3), controlPoint1: CGPoint(x: 1.83, y: 3), controlPoint2: CGPoint(x: 1.83, y: 3))
        bezierPath.addLineToPoint(CGPoint(x: 6.25, y: 3))
        bezierPath.addLineToPoint(CGPoint(x: 8.33, y: 0))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 12.5, y: 6))
        bezierPath.addCurveToPoint(CGPoint(x: 14.52, y: 6.4), controlPoint1: CGPoint(x: 13.56, y: 6), controlPoint2: CGPoint(x: 13.56, y: 6))
        bezierPath.addCurveToPoint(CGPoint(x: 16.18, y: 7.46), controlPoint1: CGPoint(x: 15.49, y: 6.8), controlPoint2: CGPoint(x: 15.49, y: 6.8))
        bezierPath.addCurveToPoint(CGPoint(x: 17.29, y: 9.06), controlPoint1: CGPoint(x: 16.88, y: 8.13), controlPoint2: CGPoint(x: 16.88, y: 8.13))
        bezierPath.addCurveToPoint(CGPoint(x: 17.71, y: 11), controlPoint1: CGPoint(x: 17.71, y: 9.98), controlPoint2: CGPoint(x: 17.71, y: 9.98))
        bezierPath.addCurveToPoint(CGPoint(x: 17.29, y: 12.94), controlPoint1: CGPoint(x: 17.71, y: 12.01), controlPoint2: CGPoint(x: 17.71, y: 12.01))
        bezierPath.addCurveToPoint(CGPoint(x: 16.18, y: 14.53), controlPoint1: CGPoint(x: 16.88, y: 13.87), controlPoint2: CGPoint(x: 16.88, y: 13.87))
        bezierPath.addCurveToPoint(CGPoint(x: 14.52, y: 15.6), controlPoint1: CGPoint(x: 15.49, y: 15.2), controlPoint2: CGPoint(x: 15.49, y: 15.2))
        bezierPath.addCurveToPoint(CGPoint(x: 12.5, y: 16), controlPoint1: CGPoint(x: 13.56, y: 16), controlPoint2: CGPoint(x: 13.56, y: 16))
        bezierPath.addCurveToPoint(CGPoint(x: 10.48, y: 15.6), controlPoint1: CGPoint(x: 11.44, y: 16), controlPoint2: CGPoint(x: 11.44, y: 16))
        bezierPath.addCurveToPoint(CGPoint(x: 8.82, y: 14.53), controlPoint1: CGPoint(x: 9.51, y: 15.2), controlPoint2: CGPoint(x: 9.51, y: 15.2))
        bezierPath.addCurveToPoint(CGPoint(x: 7.71, y: 12.94), controlPoint1: CGPoint(x: 8.12, y: 13.87), controlPoint2: CGPoint(x: 8.12, y: 13.87))
        bezierPath.addCurveToPoint(CGPoint(x: 7.29, y: 11), controlPoint1: CGPoint(x: 7.29, y: 12.01), controlPoint2: CGPoint(x: 7.29, y: 12.01))
        bezierPath.addCurveToPoint(CGPoint(x: 7.71, y: 9.06), controlPoint1: CGPoint(x: 7.29, y: 9.98), controlPoint2: CGPoint(x: 7.29, y: 9.98))
        bezierPath.addCurveToPoint(CGPoint(x: 8.82, y: 7.46), controlPoint1: CGPoint(x: 8.12, y: 8.13), controlPoint2: CGPoint(x: 8.12, y: 8.13))
        bezierPath.addCurveToPoint(CGPoint(x: 10.48, y: 6.4), controlPoint1: CGPoint(x: 9.51, y: 6.8), controlPoint2: CGPoint(x: 9.51, y: 6.8))
        bezierPath.addCurveToPoint(CGPoint(x: 12.5, y: 6), controlPoint1: CGPoint(x: 11.44, y: 6), controlPoint2: CGPoint(x: 11.44, y: 6))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 12.5, y: 8))
        bezierPath.addCurveToPoint(CGPoint(x: 10.29, y: 8.88), controlPoint1: CGPoint(x: 11.21, y: 8), controlPoint2: CGPoint(x: 11.21, y: 8))
        bezierPath.addCurveToPoint(CGPoint(x: 9.38, y: 11), controlPoint1: CGPoint(x: 9.38, y: 9.76), controlPoint2: CGPoint(x: 9.38, y: 9.76))
        bezierPath.addCurveToPoint(CGPoint(x: 10.29, y: 13.12), controlPoint1: CGPoint(x: 9.38, y: 12.24), controlPoint2: CGPoint(x: 9.38, y: 12.24))
        bezierPath.addCurveToPoint(CGPoint(x: 12.5, y: 14), controlPoint1: CGPoint(x: 11.21, y: 14), controlPoint2: CGPoint(x: 11.21, y: 14))
        bezierPath.addCurveToPoint(CGPoint(x: 14.71, y: 13.12), controlPoint1: CGPoint(x: 13.79, y: 14), controlPoint2: CGPoint(x: 13.79, y: 14))
        bezierPath.addCurveToPoint(CGPoint(x: 15.63, y: 11), controlPoint1: CGPoint(x: 15.63, y: 12.24), controlPoint2: CGPoint(x: 15.63, y: 12.24))
        bezierPath.addCurveToPoint(CGPoint(x: 14.71, y: 8.88), controlPoint1: CGPoint(x: 15.63, y: 9.76), controlPoint2: CGPoint(x: 15.63, y: 9.76))
        bezierPath.addCurveToPoint(CGPoint(x: 12.5, y: 8), controlPoint1: CGPoint(x: 13.79, y: 8), controlPoint2: CGPoint(x: 13.79, y: 8))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 17.64, y: 5))
        bezierPath.addLineToPoint(CGPoint(x: 15.59, y: 2))
        bezierPath.addLineToPoint(CGPoint(x: 9.45, y: 2))
        bezierPath.addLineToPoint(CGPoint(x: 7.37, y: 5))
        bezierPath.addLineToPoint(CGPoint(x: 3.13, y: 5))
        bezierPath.addCurveToPoint(CGPoint(x: 2.39, y: 5.3), controlPoint1: CGPoint(x: 2.69, y: 5), controlPoint2: CGPoint(x: 2.69, y: 5))
        bezierPath.addCurveToPoint(CGPoint(x: 2.08, y: 6.02), controlPoint1: CGPoint(x: 2.08, y: 5.59), controlPoint2: CGPoint(x: 2.08, y: 5.59))
        bezierPath.addLineToPoint(CGPoint(x: 2.08, y: 17))
        bezierPath.addCurveToPoint(CGPoint(x: 2.39, y: 17.71), controlPoint1: CGPoint(x: 2.08, y: 17.41), controlPoint2: CGPoint(x: 2.08, y: 17.41))
        bezierPath.addCurveToPoint(CGPoint(x: 3.13, y: 18), controlPoint1: CGPoint(x: 2.69, y: 18), controlPoint2: CGPoint(x: 2.69, y: 18))
        bezierPath.addLineToPoint(CGPoint(x: 21.88, y: 18))
        bezierPath.addCurveToPoint(CGPoint(x: 22.62, y: 17.71), controlPoint1: CGPoint(x: 22.32, y: 18), controlPoint2: CGPoint(x: 22.32, y: 18))
        bezierPath.addCurveToPoint(CGPoint(x: 22.92, y: 17.02), controlPoint1: CGPoint(x: 22.92, y: 17.43), controlPoint2: CGPoint(x: 22.92, y: 17.43))
        bezierPath.addLineToPoint(CGPoint(x: 22.92, y: 6.03))
        bezierPath.addCurveToPoint(CGPoint(x: 22.61, y: 5.3), controlPoint1: CGPoint(x: 22.92, y: 5.61), controlPoint2: CGPoint(x: 22.92, y: 5.61))
        bezierPath.addCurveToPoint(CGPoint(x: 21.88, y: 5), controlPoint1: CGPoint(x: 22.3, y: 5), controlPoint2: CGPoint(x: 22.3, y: 5))
        bezierPath.addLineToPoint(CGPoint(x: 17.64, y: 5))

        bezierPath.closePath()
        bezierPath.miterLimit = 4;
        
        
        cameraButtonLayer.backgroundColor = UIColor.clearColor().CGColor
        cameraButtonLayer.path = bezierPath.CGPath
        cameraButtonLayer.fillColor = AppDelegate.cellInnerColor.CGColor
        cameraButtonLayer.fillRule = kCAFillRuleEvenOdd
        detailAddPhoto.layer.addSublayer(cameraButtonLayer)

    }
    
    func initAudioButtonView () {

        //// Group 2
        //// Group 3
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: 6.3, y: 14.15))
        bezierPath.addCurveToPoint(CGPoint(x: 10.56, y: 9.91), controlPoint1: CGPoint(x: 8.68, y: 14.15), controlPoint2: CGPoint(x: 10.56, y: 12.27))
        bezierPath.addLineToPoint(CGPoint(x: 10.56, y: 3.84))
        bezierPath.addCurveToPoint(CGPoint(x: 6.3, y: -0.4), controlPoint1: CGPoint(x: 10.56, y: 1.48), controlPoint2: CGPoint(x: 8.68, y: -0.4))
        bezierPath.addCurveToPoint(CGPoint(x: 2.04, y: 3.84), controlPoint1: CGPoint(x: 3.92, y: -0.4), controlPoint2: CGPoint(x: 2.04, y: 1.48))
        bezierPath.addLineToPoint(CGPoint(x: 2.04, y: 9.91))
        bezierPath.addCurveToPoint(CGPoint(x: 6.3, y: 14.15), controlPoint1: CGPoint(x: 2.04, y: 12.27), controlPoint2: CGPoint(x: 3.92, y: 14.15))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 13, y: 11.12))
        bezierPath.addLineToPoint(CGPoint(x: 11.78, y: 11.12))
        bezierPath.addCurveToPoint(CGPoint(x: 6.3, y: 15.36), controlPoint1: CGPoint(x: 11.23, y: 13.54), controlPoint2: CGPoint(x: 8.92, y: 15.36))
        bezierPath.addCurveToPoint(CGPoint(x: 0.82, y: 11.12), controlPoint1: CGPoint(x: 3.68, y: 15.36), controlPoint2: CGPoint(x: 1.37, y: 13.54))
        bezierPath.addLineToPoint(CGPoint(x: -0.4, y: 11.12))
        bezierPath.addCurveToPoint(CGPoint(x: 5.69, y: 16.58), controlPoint1: CGPoint(x: 0.15, y: 14.03), controlPoint2: CGPoint(x: 2.71, y: 16.27))
        bezierPath.addLineToPoint(CGPoint(x: 5.69, y: 17.79))
        bezierPath.addLineToPoint(CGPoint(x: 5.08, y: 17.79))
        bezierPath.addCurveToPoint(CGPoint(x: 4.47, y: 18.39), controlPoint1: CGPoint(x: 4.72, y: 17.79), controlPoint2: CGPoint(x: 4.47, y: 18.03))
        bezierPath.addCurveToPoint(CGPoint(x: 5.08, y: 19), controlPoint1: CGPoint(x: 4.47, y: 18.76), controlPoint2: CGPoint(x: 4.72, y: 19))
        bezierPath.addLineToPoint(CGPoint(x: 7.52, y: 19))
        bezierPath.addCurveToPoint(CGPoint(x: 8.13, y: 18.39), controlPoint1: CGPoint(x: 7.88, y: 19), controlPoint2: CGPoint(x: 8.13, y: 18.76))
        bezierPath.addCurveToPoint(CGPoint(x: 7.52, y: 17.79), controlPoint1: CGPoint(x: 8.13, y: 18.03), controlPoint2: CGPoint(x: 7.88, y: 17.79))
        bezierPath.addLineToPoint(CGPoint(x: 6.91, y: 17.79))
        bezierPath.addLineToPoint(CGPoint(x: 6.91, y: 16.58))
        bezierPath.addCurveToPoint(CGPoint(x: 13, y: 11.12), controlPoint1: CGPoint(x: 9.89, y: 16.27), controlPoint2: CGPoint(x: 12.45, y: 14.03))
        bezierPath.closePath()
        bezierPath.miterLimit = 4;

        audioButtonLayer.backgroundColor = UIColor.clearColor().CGColor
        audioButtonLayer.path = bezierPath.CGPath
        audioButtonLayer.fillColor = AppDelegate.cellInnerColor.CGColor
        audioButtonLayer.fillRule = kCAFillRuleEvenOdd
        detailAddAudio.layer.addSublayer(audioButtonLayer)

    }
    
    func updateButtonLayerStatus(layer: CAShapeLayer, hasItem: Bool) {
        if hasItem {
            layer.fillColor = AppDelegate.cellInnerColor.CGColor

        } else {
            layer.fillColor = UIColor.lightGrayColor().CGColor
        }
    }
    
    
    func updateCell(expanded: Bool, finished: Bool, expired: Bool){
        
        self.foldView.hidden = !expanded
        
        //finished item will not be "Done"able
        if (finished) {
            textField.userInteractionEnabled = false
            foldView.userInteractionEnabled = false
            contentView.alpha = 0.8
            setupDoneButton(true)
        } else {
            textField.userInteractionEnabled = true
            contentView.alpha = 1.0
            foldView.userInteractionEnabled = true
            setupDoneButton(false)

        }
        
        if expired { //expired notify item
            indicatorView.alpha = 1.0
            self.expired = true
        } else {
            indicatorView.alpha = 0.0
        }
        
        if detailTextView.hasText() {
            detailTextViewPlaceholderLabel.hidden = true
        } else {
            detailTextViewPlaceholderLabel.hidden = false
        }

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
        self.expanded = true

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

        setCellCornerRadius(expanded,animated: true)

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
        self.expanded = false
        foldView.alpha = 0
        foldAnimationView.alpha = 1.0
        foldAnimationView.layer.shouldRasterize = true
        let delay: NSTimeInterval = 0
        let timing                = kCAMediaTimingFunctionEaseIn
        let from: CGFloat         = 0
        let to: CGFloat           = CGFloat(-M_PI / 2)
        let duration              = 0.5
        
        setCellCornerRadius(expanded, animated: true)

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


extension UIView
{
    func addCornerRadiusAnimation(from: CGFloat, to: CGFloat, duration: CFTimeInterval)
    {
        let animation = CABasicAnimation(keyPath:"cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        animation.removedOnCompletion = true
        self.layer.addAnimation(animation, forKey: "cornerRadius")
        self.layer.cornerRadius = to
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
