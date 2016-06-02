//
//  AudioViewController.swift
//  EasyToDo
//
//  Created by Jackie Zhang on 16/6/2.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit
import AVFoundation

class AudioViewController : UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet var startRecordBtn: UIButton!
    @IBOutlet var stopRecordBtn: UIButton!
    @IBOutlet var startPlayBtn: UIButton!
    @IBOutlet var stopPlayBtn: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    var audioSession : AVAudioSession!
    
    override func viewDidLoad() {
        let recordSettings = [
            AVSampleRateKey : NSNumber(float: Float(44100.0)),
            AVFormatIDKey : NSNumber(int: Int32(kAudioFormatMPEG4AAC)),
            AVNumberOfChannelsKey : NSNumber(int: 1),
            AVEncoderAudioQualityKey : NSNumber(int: Int32(AVAudioQuality.Medium.rawValue))
        ]
        audioSession = AVAudioSession.sharedInstance()
       /* do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioRecorder = AVAudioRecorder(URL: self.directoryURL(), settings: recordSettings)
            audioRecorder.prepareToRecord()
        } catch {
            print ("audio recorder prepare failed")
        }
        */
    }
    
    func directoryURL() -> NSURL {
        
        
        return NSURL()
    }
    
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