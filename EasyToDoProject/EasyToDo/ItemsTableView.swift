//
//  ItemsTableView.swift
//  EasyToDo
//
//  Created by Jackie Zhang on 16/5/11.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class ItemsTableView: UITableView {
    
    func animate(cell: UITableViewCell) {
        if let view = cell.contentView.viewWithTag(234) {
            UIView.animateWithDuration(1,
                                       delay:0,
                                       options:[],
                                       animations: {
                                        view.center.x += view.bounds.width
                }, completion:nil)
            
        }

        
    }
    
    
    override func insertRowsAtIndexPaths(indexPaths: [NSIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
        
        super.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
        for index in indexPaths {
            if let cell = cellForRowAtIndexPath(index) {
                animate(cell)
            }

        }
    }
    
}
