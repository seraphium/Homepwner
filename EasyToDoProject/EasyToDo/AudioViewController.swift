//
//  AudioViewController.swift
//  EasyToDo
//
//  Created by Jackie Zhang on 16/6/2.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class AudioViewController : UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet var startRecordBtn: UIButton!
    @IBOutlet var stopRecordBtn: UIButton!
    @IBOutlet var startPlayBtn: UIButton!
    @IBOutlet var stopPlayBtn: UIButton!
    
    
    
    @IBAction func startRecord(sender: UIButton) {
        print ("start record")
        
    }
    
    @IBAction func stopRecord(sender: UIButton) {
        print ("stop record")
        
    }
    @IBAction func startPlay(sender: UIButton) {
        print ("start play")
    }
    
    @IBAction func stopPlay(sender: UIButton) {
        print ("stop play")
        
    }
}