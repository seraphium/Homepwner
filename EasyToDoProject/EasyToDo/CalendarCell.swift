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
    
    @IBOutlet var markedView: UIView!
    @IBOutlet weak var hasDataView: UIView!
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
    
    func initViews() {
        if hasData {
            let w = hasDataView.bounds.width
            let h = hasDataView.bounds.height
            let minWH = min(w, h)
            let inset = CGFloat(2.0)
            let hasDataPath = UIBezierPath(arcCenter: CGPoint(x: w/2, y: h/2), radius: minWH / 2 - inset, startAngle: 0.0, endAngle: CGFloat(2 * M_PI), clockwise: true)
            hasDataPath.lineWidth = 1
            hasDataShapeLayer.strokeColor = UIColor.redColor().CGColor
            hasDataShapeLayer.fillColor = UIColor.clearColor().CGColor
            hasDataShapeLayer.backgroundColor = UIColor.clearColor().CGColor
            hasDataShapeLayer.path = hasDataPath.CGPath
            hasDataView.layer.addSublayer(hasDataShapeLayer)

        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        initViews()
    }

    
}
