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
    
    var audioStore : AudioStore!
    
    var item: Item!
    
    override func viewDidLoad() {
        let recordSettings = [
            AVSampleRateKey : NSNumber(float: Float(44100.0)),
            AVFormatIDKey : NSNumber(int: Int32(kAudioFormatMPEG4AAC)),
            AVNumberOfChannelsKey : NSNumber(int: 1),
            AVEncoderAudioQualityKey : NSNumber(int: Int32(AVAudioQuality.Medium.rawValue))
        ]
        audioSession = AVAudioSession.sharedInstance()
        do {
            if let url = self.directoryURL() {
                try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                try audioRecorder = AVAudioRecorder(URL: url, settings: recordSettings)
                audioRecorder.prepareToRecord()
                
                audioPlayer = try AVAudioPlayer(contentsOfURL: url)
                
            } else {
                print ("cannot get proper audio url")
            }
        } catch {
            print ("audio recorder prepare failed")
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
        if !audioRecorder.recording
        {
            do {
                try audioSession.setActive(true)
                audioRecorder.record()
            } catch {
                print ("start recording failed")
            }
        }
        
    }
    
    @IBAction func stopRecord(sender: UIButton) {
        print ("stop record")
        audioRecorder.stop()
        do {
            try audioSession.setActive(false)
        } catch {
            print ("stop recording failed")
        }
    }
    
    @IBAction func startPlay(sender: UIButton) {
        if !audioRecorder.recording {
            audioPlayer.play()
            print ("started play")
        }
    }
    
    @IBAction func stopPlay(sender: UIButton) {
        if !audioRecorder.recording {
            audioPlayer.stop()
            print ("stopped play")

        }
    }
}