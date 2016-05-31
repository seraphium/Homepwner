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

    var foldAnimationView: UIView!
    
    @IBOutlet var indicatorView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet var notifyDateLabel: UILabel!

    @IBOutlet var doneButton: UIButton!

    //foldview content
    @IBOutlet weak var detailTextView: UITextView!
    
    @IBOutlet weak var detailNotifyDate: UITextField!
    
    @IBOutlet weak var detailAddPhoto: UIButton!

    @IBOutlet weak var detailDetailLabel: UILabel!
    
    @IBOutlet weak var detailNotifyLabel: UILabel!
    
    @IBOutlet weak var detailRepeatLabel: UILabel!
    weak var delegate: PresentNotifyProtocol?
    
    var expired : Bool = false
    //indicator
    let indicatorLayer = CAShapeLayer()
    var indicatorPath = UIBezierPath()
    //donebutton
    var doneButtonLayer = CAShapeLayer()
    var doneButtonPath = UIBezierPath()
    //
    var cameraButtonLayer = CAShapeLayer()
    var cameraButtonPath = UIBezierPath()
    
    var item:Item!
    
    var expanded : Bool = false
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
        
        datePicker = UIDatePicker()
        datePicker.locale = NSLocale(localeIdentifier: "zh_CN")
        datePicker.datePickerMode = .DateAndTime
        datePicker.date = NSDate() //initial value
        
        detailTextView.delegate = self
        detailNotifyDate.delegate = self

        
        //update font setting
        let bodyFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        textField.font = bodyFont
        textField.tintColor = AppDelegate.cellColor
        
        doneButton.contentHorizontalAlignment = .Fill
        doneButton.contentVerticalAlignment = .Fill
        
        
        foldAnimationView = UIView()
        foldAnimationView.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        foldAnimationView.frame = foldView.frame
        
        containerView.addSubview(foldAnimationView)
        
        foregroundView.backgroundColor = AppDelegate.cellInnerColor
        containerView.backgroundColor = AppDelegate.backColor
        
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
        initDoneButtonView()
        initCameraButtonView()
    }

    func setCellCornerRadius(expanded: Bool, animated: Bool)
    {
        let cornerRadius = CGFloat(5.0)
        print ("set corner radius")
        if (animated) {
            let from = CGFloat(expanded ? cornerRadius : 0)
            let to = CGFloat(expanded ? 0 : cornerRadius)
            contentView.addCornerRadiusAnimation(from, to: to, duration: 0.5)
            containerView.addCornerRadiusAnimation(from, to: to, duration: 0.5)
            foregroundView.addCornerRadiusAnimation(from, to: to, duration: 0.5)
            animationView.addCornerRadiusAnimation(from, to: to, duration: 0.5)
        } else {
            contentView.layer.cornerRadius = cornerRadius
            containerView.layer.cornerRadius = cornerRadius
            foregroundView.layer.cornerRadius = cornerRadius
            animationView.layer.cornerRadius = cornerRadius
            
        }


    }
    
    func setupShadow()
    {
        
        //setup Shadow
        containerView.layer.shadowOffset = CGSizeMake(1, 1)
        containerView.layer.shadowColor = AppDelegate.cellInnerColor.CGColor
        containerView.layer.shadowRadius = 5
        containerView.layer.shadowOpacity = 0.5
       // let shadowFrame = foregroundView.layer.bounds;
       // let shadowPath = UIBezierPath(rect: shadowFrame).CGPath
       // containerView.layer.shadowPath = shadowPath;
        // Maybe just me, but I had to add it to work:
        clipsToBounds = false

    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupShadow()
        
        if let it = item {
            if let detail = it.detail {
                detailTextView.text = detail
            }
            if let date = it.dateToNotify {
                detailNotifyDate.text = dateFormatter.stringFromDate(date)  
            }
            repeatSelector.selectedSegmentIndex = item.repeatInterval

        }
        if let it = item {
            if let _ = AppDelegate.imageStore.imageForKey(it.itemKey) {
               updateCameraButtonStatus(true)
            } else {
                updateCameraButtonStatus(false)
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
        if notifDate.earlierDate(currentTime) == notifDate {
            return "已过期"
        }
        var outputString = "还剩"
        var outputStep = 2
        let calender = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let component = calender?.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: currentTime, toDate: notifDate, options: [])
        if outputStep > 0 && component?.year > 0 {
            outputString += String(component!.year) + "年"
            outputStep -= 1
        }
        if outputStep > 0 && component?.month > 0 {
            outputString += String(component!.month) + "个月"
            outputStep -= 1
        }
        if outputStep > 0 && component?.day > 0 {
            outputString += String(component!.day) + "天"
            outputStep -= 1
        }
        if outputStep > 0 && component?.hour > 0 {
            outputString += String(component!.hour) + "小时"
            outputStep -= 1
        }
        if outputStep > 0 && component?.minute > 0 {
            outputString += String(component!.minute) + "分钟"
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
    
    func initDoneButtonView() {
        
        //// Bezier Drawing
        doneButtonPath = UIBezierPath()
        doneButtonPath.moveToPoint(CGPoint(x: 13.99, y: 26.22))
        doneButtonPath.addLineToPoint(CGPoint(x: 13.99, y: 26.22))
        doneButtonPath.addCurveToPoint(CGPoint(x: 26.25, y: 13.97), controlPoint1: CGPoint(x: 20.76, y: 26.22), controlPoint2: CGPoint(x: 26.25, y: 20.74))
        doneButtonPath.addCurveToPoint(CGPoint(x: 13.99, y: 1.71), controlPoint1: CGPoint(x: 26.25, y: 7.2), controlPoint2: CGPoint(x: 20.76, y: 1.71))
        doneButtonPath.addCurveToPoint(CGPoint(x: 1.74, y: 13.97), controlPoint1: CGPoint(x: 7.23, y: 1.71), controlPoint2: CGPoint(x: 1.74, y: 7.2))
        doneButtonPath.addCurveToPoint(CGPoint(x: 13.99, y: 26.22), controlPoint1: CGPoint(x: 1.74, y: 20.74), controlPoint2: CGPoint(x: 7.23, y: 26.22))
        doneButtonPath.addLineToPoint(CGPoint(x: 13.99, y: 26.22))
        doneButtonPath.closePath()
        doneButtonPath.moveToPoint(CGPoint(x: 13.99, y: 27.97))
        doneButtonPath.addLineToPoint(CGPoint(x: 13.99, y: 27.97))
        doneButtonPath.addCurveToPoint(CGPoint(x: -0.01, y: 13.97), controlPoint1: CGPoint(x: 6.26, y: 27.97), controlPoint2: CGPoint(x: -0.01, y: 21.7))
        doneButtonPath.addCurveToPoint(CGPoint(x: 13.99, y: -0.04), controlPoint1: CGPoint(x: -0.01, y: 6.23), controlPoint2: CGPoint(x: 6.26, y: -0.04))
        doneButtonPath.addCurveToPoint(CGPoint(x: 28, y: 13.97), controlPoint1: CGPoint(x: 21.73, y: -0.04), controlPoint2: CGPoint(x: 28, y: 6.23))
        doneButtonPath.addCurveToPoint(CGPoint(x: 13.99, y: 27.97), controlPoint1: CGPoint(x: 28, y: 21.7), controlPoint2: CGPoint(x: 21.73, y: 27.97))
        doneButtonPath.addLineToPoint(CGPoint(x: 13.99, y: 27.97))
        doneButtonPath.closePath()
        doneButtonPath.moveToPoint(CGPoint(x: 22.03, y: 10.52))
        doneButtonPath.addLineToPoint(CGPoint(x: 12.97, y: 19.58))
        doneButtonPath.addLineToPoint(CGPoint(x: 12.97, y: 19.58))
        doneButtonPath.addCurveToPoint(CGPoint(x: 11.43, y: 19.77), controlPoint1: CGPoint(x: 12.55, y: 20), controlPoint2: CGPoint(x: 11.92, y: 20.06))
        doneButtonPath.addCurveToPoint(CGPoint(x: 11.18, y: 19.58), controlPoint1: CGPoint(x: 11.34, y: 19.72), controlPoint2: CGPoint(x: 11.25, y: 19.66))
        doneButtonPath.addLineToPoint(CGPoint(x: 11.18, y: 19.58))
        doneButtonPath.addLineToPoint(CGPoint(x: 5.96, y: 14.36))
        doneButtonPath.addCurveToPoint(CGPoint(x: 5.96, y: 12.57), controlPoint1: CGPoint(x: 5.47, y: 13.87), controlPoint2: CGPoint(x: 5.47, y: 13.07))
        doneButtonPath.addCurveToPoint(CGPoint(x: 7.75, y: 12.57), controlPoint1: CGPoint(x: 6.46, y: 12.08), controlPoint2: CGPoint(x: 7.26, y: 12.08))
        doneButtonPath.addLineToPoint(CGPoint(x: 12.07, y: 16.89))
        doneButtonPath.addLineToPoint(CGPoint(x: 20.24, y: 8.73))
        doneButtonPath.addCurveToPoint(CGPoint(x: 22.03, y: 8.73), controlPoint1: CGPoint(x: 20.73, y: 8.23), controlPoint2: CGPoint(x: 21.53, y: 8.23))
        doneButtonPath.addCurveToPoint(CGPoint(x: 22.03, y: 10.52), controlPoint1: CGPoint(x: 22.52, y: 9.22), controlPoint2: CGPoint(x: 22.52, y: 10.03))
        doneButtonPath.addLineToPoint(CGPoint(x: 22.03, y: 10.52))
        doneButtonPath.closePath()
        doneButtonPath.miterLimit = 4;
        
        doneButtonLayer.backgroundColor = UIColor.clearColor().CGColor
        doneButtonLayer.path = doneButtonPath.CGPath
        doneButtonLayer.fillColor = AppDelegate.backColor.CGColor
        doneButtonLayer.fillRule = kCAFillRuleEvenOdd
        doneButton.layer.addSublayer(doneButtonLayer)


    }
    
    func initCameraButtonView()
    {
        
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: 5.33, y: 1.33))
        bezierPath.addLineToPoint(CGPoint(x: 10.67, y: 1.33))
        bezierPath.addLineToPoint(CGPoint(x: 12, y: 3.33))
        bezierPath.addLineToPoint(CGPoint(x: 14, y: 3.33))
        bezierPath.addCurveToPoint(CGPoint(x: 15.41, y: 3.93), controlPoint1: CGPoint(x: 14.83, y: 3.33), controlPoint2: CGPoint(x: 14.83, y: 3.33))
        bezierPath.addCurveToPoint(CGPoint(x: 16, y: 5.35), controlPoint1: CGPoint(x: 16, y: 4.53), controlPoint2: CGPoint(x: 16, y: 4.53))
        bezierPath.addLineToPoint(CGPoint(x: 16, y: 12.68))
        bezierPath.addCurveToPoint(CGPoint(x: 15.41, y: 14.09), controlPoint1: CGPoint(x: 16, y: 13.51), controlPoint2: CGPoint(x: 16, y: 13.51))
        bezierPath.addCurveToPoint(CGPoint(x: 14, y: 14.67), controlPoint1: CGPoint(x: 14.83, y: 14.67), controlPoint2: CGPoint(x: 14.83, y: 14.67))
        bezierPath.addLineToPoint(CGPoint(x: 2, y: 14.67))
        bezierPath.addCurveToPoint(CGPoint(x: 0.59, y: 14.08), controlPoint1: CGPoint(x: 1.17, y: 14.67), controlPoint2: CGPoint(x: 1.17, y: 14.67))
        bezierPath.addCurveToPoint(CGPoint(x: -0, y: 12.67), controlPoint1: CGPoint(x: -0, y: 13.49), controlPoint2: CGPoint(x: -0, y: 13.49))
        bezierPath.addLineToPoint(CGPoint(x: -0, y: 5.34))
        bezierPath.addCurveToPoint(CGPoint(x: 0.59, y: 3.92), controlPoint1: CGPoint(x: -0, y: 4.52), controlPoint2: CGPoint(x: -0, y: 4.52))
        bezierPath.addCurveToPoint(CGPoint(x: 2, y: 3.33), controlPoint1: CGPoint(x: 1.17, y: 3.33), controlPoint2: CGPoint(x: 1.17, y: 3.33))
        bezierPath.addLineToPoint(CGPoint(x: 4, y: 3.33))
        bezierPath.addLineToPoint(CGPoint(x: 5.33, y: 1.33))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 8, y: 5.33))
        bezierPath.addCurveToPoint(CGPoint(x: 9.29, y: 5.6), controlPoint1: CGPoint(x: 8.68, y: 5.33), controlPoint2: CGPoint(x: 8.68, y: 5.33))
        bezierPath.addCurveToPoint(CGPoint(x: 10.36, y: 6.31), controlPoint1: CGPoint(x: 9.91, y: 5.86), controlPoint2: CGPoint(x: 9.91, y: 5.86))
        bezierPath.addCurveToPoint(CGPoint(x: 11.07, y: 7.37), controlPoint1: CGPoint(x: 10.8, y: 6.75), controlPoint2: CGPoint(x: 10.8, y: 6.75))
        bezierPath.addCurveToPoint(CGPoint(x: 11.33, y: 8.67), controlPoint1: CGPoint(x: 11.33, y: 7.99), controlPoint2: CGPoint(x: 11.33, y: 7.99))
        bezierPath.addCurveToPoint(CGPoint(x: 11.07, y: 9.96), controlPoint1: CGPoint(x: 11.33, y: 9.34), controlPoint2: CGPoint(x: 11.33, y: 9.34))
        bezierPath.addCurveToPoint(CGPoint(x: 10.36, y: 11.02), controlPoint1: CGPoint(x: 10.8, y: 10.58), controlPoint2: CGPoint(x: 10.8, y: 10.58))
        bezierPath.addCurveToPoint(CGPoint(x: 9.29, y: 11.73), controlPoint1: CGPoint(x: 9.91, y: 11.47), controlPoint2: CGPoint(x: 9.91, y: 11.47))
        bezierPath.addCurveToPoint(CGPoint(x: 8, y: 12), controlPoint1: CGPoint(x: 8.68, y: 12), controlPoint2: CGPoint(x: 8.68, y: 12))
        bezierPath.addCurveToPoint(CGPoint(x: 6.71, y: 11.73), controlPoint1: CGPoint(x: 7.32, y: 12), controlPoint2: CGPoint(x: 7.32, y: 12))
        bezierPath.addCurveToPoint(CGPoint(x: 5.64, y: 11.02), controlPoint1: CGPoint(x: 6.09, y: 11.47), controlPoint2: CGPoint(x: 6.09, y: 11.47))
        bezierPath.addCurveToPoint(CGPoint(x: 4.93, y: 9.96), controlPoint1: CGPoint(x: 5.2, y: 10.58), controlPoint2: CGPoint(x: 5.2, y: 10.58))
        bezierPath.addCurveToPoint(CGPoint(x: 4.67, y: 8.67), controlPoint1: CGPoint(x: 4.67, y: 9.34), controlPoint2: CGPoint(x: 4.67, y: 9.34))
        bezierPath.addCurveToPoint(CGPoint(x: 4.93, y: 7.37), controlPoint1: CGPoint(x: 4.67, y: 7.99), controlPoint2: CGPoint(x: 4.67, y: 7.99))
        bezierPath.addCurveToPoint(CGPoint(x: 5.64, y: 6.31), controlPoint1: CGPoint(x: 5.2, y: 6.75), controlPoint2: CGPoint(x: 5.2, y: 6.75))
        bezierPath.addCurveToPoint(CGPoint(x: 6.71, y: 5.6), controlPoint1: CGPoint(x: 6.09, y: 5.86), controlPoint2: CGPoint(x: 6.09, y: 5.86))
        bezierPath.addCurveToPoint(CGPoint(x: 8, y: 5.33), controlPoint1: CGPoint(x: 7.32, y: 5.33), controlPoint2: CGPoint(x: 7.32, y: 5.33))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 8, y: 6.67))
        bezierPath.addCurveToPoint(CGPoint(x: 6.59, y: 7.25), controlPoint1: CGPoint(x: 7.17, y: 6.67), controlPoint2: CGPoint(x: 7.17, y: 6.67))
        bezierPath.addCurveToPoint(CGPoint(x: 6, y: 8.67), controlPoint1: CGPoint(x: 6, y: 7.84), controlPoint2: CGPoint(x: 6, y: 7.84))
        bezierPath.addCurveToPoint(CGPoint(x: 6.59, y: 10.08), controlPoint1: CGPoint(x: 6, y: 9.49), controlPoint2: CGPoint(x: 6, y: 9.49))
        bezierPath.addCurveToPoint(CGPoint(x: 8, y: 10.67), controlPoint1: CGPoint(x: 7.17, y: 10.67), controlPoint2: CGPoint(x: 7.17, y: 10.67))
        bezierPath.addCurveToPoint(CGPoint(x: 9.41, y: 10.08), controlPoint1: CGPoint(x: 8.83, y: 10.67), controlPoint2: CGPoint(x: 8.83, y: 10.67))
        bezierPath.addCurveToPoint(CGPoint(x: 10, y: 8.67), controlPoint1: CGPoint(x: 10, y: 9.49), controlPoint2: CGPoint(x: 10, y: 9.49))
        bezierPath.addCurveToPoint(CGPoint(x: 9.41, y: 7.25), controlPoint1: CGPoint(x: 10, y: 7.84), controlPoint2: CGPoint(x: 10, y: 7.84))
        bezierPath.addCurveToPoint(CGPoint(x: 8, y: 6.67), controlPoint1: CGPoint(x: 8.83, y: 6.67), controlPoint2: CGPoint(x: 8.83, y: 6.67))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 11.29, y: 4.67))
        bezierPath.addLineToPoint(CGPoint(x: 9.98, y: 2.67))
        bezierPath.addLineToPoint(CGPoint(x: 6.05, y: 2.67))
        bezierPath.addLineToPoint(CGPoint(x: 4.71, y: 4.67))
        bezierPath.addLineToPoint(CGPoint(x: 2, y: 4.67))
        bezierPath.addCurveToPoint(CGPoint(x: 1.53, y: 4.86), controlPoint1: CGPoint(x: 1.72, y: 4.67), controlPoint2: CGPoint(x: 1.72, y: 4.67))
        bezierPath.addCurveToPoint(CGPoint(x: 1.33, y: 5.34), controlPoint1: CGPoint(x: 1.33, y: 5.06), controlPoint2: CGPoint(x: 1.33, y: 5.06))
        bezierPath.addLineToPoint(CGPoint(x: 1.33, y: 12.67))
        bezierPath.addCurveToPoint(CGPoint(x: 1.53, y: 13.14), controlPoint1: CGPoint(x: 1.33, y: 12.94), controlPoint2: CGPoint(x: 1.33, y: 12.94))
        bezierPath.addCurveToPoint(CGPoint(x: 2, y: 13.33), controlPoint1: CGPoint(x: 1.72, y: 13.33), controlPoint2: CGPoint(x: 1.72, y: 13.33))
        bezierPath.addLineToPoint(CGPoint(x: 14, y: 13.33))
        bezierPath.addCurveToPoint(CGPoint(x: 14.47, y: 13.14), controlPoint1: CGPoint(x: 14.28, y: 13.33), controlPoint2: CGPoint(x: 14.28, y: 13.33))
        bezierPath.addCurveToPoint(CGPoint(x: 14.67, y: 12.68), controlPoint1: CGPoint(x: 14.67, y: 12.95), controlPoint2: CGPoint(x: 14.67, y: 12.95))
        bezierPath.addLineToPoint(CGPoint(x: 14.67, y: 5.35))
        bezierPath.addCurveToPoint(CGPoint(x: 14.47, y: 4.87), controlPoint1: CGPoint(x: 14.67, y: 5.07), controlPoint2: CGPoint(x: 14.67, y: 5.07))
        bezierPath.addCurveToPoint(CGPoint(x: 14, y: 4.67), controlPoint1: CGPoint(x: 14.27, y: 4.67), controlPoint2: CGPoint(x: 14.27, y: 4.67))
        bezierPath.addLineToPoint(CGPoint(x: 11.29, y: 4.67))
        bezierPath.closePath()
        bezierPath.miterLimit = 4;
        
        cameraButtonPath = bezierPath
        
        cameraButtonLayer.backgroundColor = UIColor.clearColor().CGColor
        cameraButtonLayer.path = cameraButtonPath.CGPath
        cameraButtonLayer.fillColor = AppDelegate.cellInnerColor.CGColor
        cameraButtonLayer.fillRule = kCAFillRuleEvenOdd
        detailAddPhoto.layer.addSublayer(cameraButtonLayer)

    }
    
    func updateCameraButtonStatus(hasPhoto: Bool) {
        if hasPhoto {
            cameraButtonLayer.fillColor = AppDelegate.cellInnerColor.CGColor

        } else {
            cameraButtonLayer.fillColor = UIColor.lightGrayColor().CGColor
        }
    }
    
    func updateCell(expanded: Bool, finished: Bool, expired: Bool){
        
        self.foldView.hidden = !expanded
        
        //finished item will not be "Done"able
        if (finished) {
            doneButton.alpha = 0.0
            doneButton.enabled = false
          //  foregroundView.userInteractionEnabled = false
           // foldView.userInteractionEnabled = false
            contentView.alpha = 0.2
        } else {
            doneButton.alpha = 0.8
            doneButton.enabled = true
            contentView.alpha = 1.0
        }
        
        if expired { //expired notify item
            indicatorView.alpha = 1.0
            self.expired = true
        } else {
            indicatorView.alpha = 0.0
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
