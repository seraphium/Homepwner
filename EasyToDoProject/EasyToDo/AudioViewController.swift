//
//  AudioViewController.swift
//  EasyToDo
//
//  Created by Jackie Zhang on 16/6/2.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit
import AVFoundation

class AudioViewController : UIViewController, UINavigationControllerDelegate, AVAudioRecorderDelegate {
    
    @IBOutlet var startRecordBtn: UIButton!
    @IBOutlet var stopRecordBtn: UIButton!
    @IBOutlet var startPlayBtn: UIButton!
    @IBOutlet var stopPlayBtn: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    var audioSession : AVAudioSession!
    
    var audioStore : AudioStore!
    
    var item: Item!
    
    let recordSettings = [
        AVSampleRateKey : NSNumber(float: Float(44100.0)),
        AVFormatIDKey : NSNumber(int: Int32(kAudioFormatMPEG4AAC)),
        AVNumberOfChannelsKey : NSNumber(int: 1),
        AVEncoderAudioQualityKey : NSNumber(int: Int32(AVAudioQuality.Medium.rawValue))
    ]
    
    override func viewDidLoad() {
        
        audioSession = AVAudioSession.sharedInstance()
        do {
                try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            
        } catch {
            print ("audio recorder prepare failed: \(error)")
        }
        
    }
    
    func directoryURL() -> NSURL? {
        if let it = item {
            return audioStore.audioURLForKey(it.itemKey)
        }
        return nil
        
    }

    
    @IBAction func startRecord(sender: UIButton) {
        print ("start record")
     
            do {
                if let url = self.directoryURL() {
                    try audioSession.setActive(true)
                    try audioRecorder = AVAudioRecorder(URL: url, settings: recordSettings)
                    audioRecorder.delegate = self
                    audioRecorder.prepareToRecord()
                }
                audioRecorder.record()
            } catch {
                print ("start recording failed: \(error)")
            }
        
        
    }
    
    @IBAction func stopRecord(sender: UIButton) {
        print ("stop record")
        guard audioRecorder != nil else {
            print ("cannot stop recording")
            return
        }
        audioRecorder.stop()
        do {
            try audioSession.setActive(false)
        } catch {
            print ("stop recording failed: \(error)")
        }
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print ("record finished successfully")
        }
    }
    
    @IBAction func startPlay(sender: UIButton) {
        if let url = self.directoryURL() {
            do {
                audioPlayer = try AVAudioPlayer(contentsOfURL: url)
                audioPlayer.play()
            } catch  {
                print ("playing failed: \(error)")
            }
            
            print ("started play")
        } else  {
            print ("Cannot get url")
        }
        
        
    }
    
    @IBAction func stopPlay(sender: UIButton) {
            if let ap = audioPlayer {
                ap.stop()
                print ("stopped play")
            }
        
    }
}