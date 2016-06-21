//
//  CalendarView.swift
//  Easy Things
//
//  Created by Jackie Zhang on 16/6/21.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit


class CalendarViewController : UIViewController {
    
    override func awakeFromNib() {
        tabBarItem.title = NSLocalizedString("CalendarTabTitle", comment: "")
        tabBarItem.image = UIImage(named: "camera")

    }
    override func viewWillAppear(animated: Bool) {
        

    }
    
    override func viewDidLoad() {
           }
}