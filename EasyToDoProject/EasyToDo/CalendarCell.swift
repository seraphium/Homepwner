//
//  CalendarCell.swift
//  Easy Things
//
//  Created by Jackie Zhang on 16/6/23.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class CalendarCell : UICollectionViewCell {
    
    @IBOutlet var label: UILabel!
    
    @IBOutlet var hasDataView: UIView!
    
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet var widthConstraint: NSLayoutConstraint!
    
    @IBOutlet var markedView: UIView!
    var hasData : Bool = false
    var hasDataShapeLayer = CAShapeLayer()
    var date: Date? {
        didSet {
            if date != nil {
                label.text = "\(date!.day)"
            } else {
                label.text = ""
            }
        }
    }
    
    var disabled: Bool = false {
        didSet {
            if disabled {
                alpha = 0.4
            } else {
                alpha = 1.0
            }
        }
    }
    
    var mark: Bool = false {
        didSet {
            if mark {
                markedView!.hidden = false
            } else {
                markedView!.hidden = true
            }
        }
    }

    func createHasDataShapeLayer(){
        hasDataShapeLayer.removeFromSuperlayer()
        widthConstraint.constant = self.frame.width
        heightConstraint.constant = self.frame.height
        let w = frame.width
        let h = frame.height
        print ("\(w):\(h)")
        let minWH = min(w, h)
        let inset = CGFloat(2.0)
        let hasDataPath = UIBezierPath(arcCenter: CGPoint(x: w / 2, y: h / 2), radius: minWH / 2 - inset, startAngle: 0.0, endAngle: CGFloat(2 * M_PI), clockwise: true)
        hasDataPath.lineWidth = 1
        hasDataShapeLayer.strokeColor = UIColor.redColor().CGColor
        hasDataShapeLayer.fillColor = UIColor.clearColor().CGColor
        hasDataShapeLayer.backgroundColor = UIColor.clearColor().CGColor
        hasDataShapeLayer.path = hasDataPath.CGPath
        hasDataView.layer.addSublayer(hasDataShapeLayer)
        hasDataView.backgroundColor = UIColor.clearColor()
    }
    
    func updateViews() {
        
        createHasDataShapeLayer()
        if hasData {
            hasDataView.hidden = false
        } else {
            hasDataView.hidden = true
        }
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()

        hasDataView.layer.zPosition = -100
        markedView.layer.zPosition = -150
     
        
    }

    
}
