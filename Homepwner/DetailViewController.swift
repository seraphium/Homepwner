//
//  DetailViewController.swift
//  Homepwner
//
//  Created by Jackie Zhang on 16/3/16.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class DetailViewController : UIViewController, UITextFieldDelegate {
    
    @IBOutlet var nameField: UITextField!
    @IBOutlet var serialField: UITextField!
    @IBOutlet var valueField: UITextField!
    @IBOutlet var dateLabel: UILabel!
    
    @IBAction func backgroundTapped(sender: AnyObject) {
        
        view.endEditing(true)
    }

    var item:Item! {
        didSet {
            navigationItem.title = item.name
        }
    }
    
    let numberFormatter : NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    let dateFormatter : NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .NoStyle
        return formatter
    }()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        nameField.text = item.name
        serialField.text = item.serialNumber
        valueField.text = numberFormatter.stringFromNumber(item.valueInDollars)
        dateLabel.text = dateFormatter.stringFromDate(item.dateCreated)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //clear the first responder (keyboard)
        view.endEditing(true)
        
        //pass back the changed value
        item.name = nameField.text ?? ""
        item.serialNumber = serialField.text
        
        if let valueText = valueField.text,
            value =  numberFormatter.numberFromString(valueText) {
                item.valueInDollars = value.integerValue
        } else {
            item.valueInDollars = 0
        }
        
    
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
