//
//  ItemStore.swift
//  Homepwner
//
//  Created by Jackie Zhang on 16/2/29.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class ItemStore  {
    var allItems = [Item]()
    
    
    func CreateItem() -> Item {
        let newItem = Item(random: true)
        allItems.append(newItem)
        return newItem
    }
    
    func RemoveItem( item: Item) {
        if let index = allItems.indexOf(item) {
            allItems.removeAtIndex(index)
        }
    }
    
    func MoveItemAtIndex( fromIndex: Int, toIndex: Int) {
        if fromIndex == toIndex {
            return ;
        }
        let movedItem = allItems[fromIndex]
        allItems.removeAtIndex(fromIndex)
        allItems.insert(movedItem, atIndex: toIndex)
        
    }
    
    
}


