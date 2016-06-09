//
//  AudioViewController.swift
//  EasyToDo
//
//  Created by Jackie Zhang on 16/6/2.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit
import AVFoundation

class AudioViewController : UIViewController, UINavigationControllerDelegate,
            AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet var controllerView: UIView!
    @IBOutlet var startRecordBtn: UIButton!
    @IBOutlet var startPlayBtn: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    @IBOutlet var meteringView: UIView!
    
    var audioMeteringInitPositionY : CGFloat = 0
    let audioDbMaxNegativeValue : Float = 80.0
    let audioMeterInstanceWidth = 50
    let audioMeterIntancelengthMultiplier : CGFloat = 0.1
    let audioMeterInstanceOffset = 10
    let audioMeteringInstanceMaxCount = 10
    
    var audioMeteringInstanceHeightIncludeInterval = 0
    
    var audioSession : AVAudioSession!
    
    var audioStore : AudioStore!
    
    var item: Item!
    
    var isPlaying: Bool = false
    var isRecording: Bool = false
    
    //metering path
    var meteringPath = UIBezierPath()
    var meteringInstanceLayer = CALayer()
    var meteringReplicatorLayer = CAReplicatorLayer()
    var meteringLayer : CALayer {
        return meteringView.layer
    }
    
    //audio button
    var audioPlayLayer = CAShapeLayer()
    var audioPlayPath = UIBezierPath()
    var audioPausePath = UIBezierPath()
    
    var audioRecordLayer = CAShapeLayer()
    var audioRecordPath = UIBezierPath()
    var audioStopRecordPath = UIBezierPath()
    
    //nstimer used to show audio recording/playing metering
    var timer : NSTimer?
    
    let recordSettings = [
        AVSampleRateKey : NSNumber(float: Float(44100.0)),
        AVFormatIDKey : NSNumber(int: Int32(kAudioFormatMPEG4AAC)),
        AVNumberOfChannelsKey : NSNumber(int: 1),
        AVEncoderAudioQualityKey : NSNumber(int: Int32(AVAudioQuality.Medium.rawValue))
    ]
    
    
    var directoryURL : NSURL? {
        if let it = item {
            return audioStore.audioURLForKey(it.itemKey)
        }
        return nil
        
    }
    
    //MARK: - Initializing
    
    override func viewDidLoad() {
        
        audioSession = AVAudioSession.sharedInstance()
        do {
            
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            
        } catch {
            print ("audio recorder prepare failed: \(error)")
        }
        
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        view.backgroundColor = AppDelegate.backColor
        
        initAudioPlayPath()
        initAudioPausePath()
        initAudioRecordPath()
        initAudioStopRecordPath()
        initMeteringView()
        initControllerView()
        initPlayButtonView(true)
        initRecordButtonView(true)
        
        if let url = AppDelegate.audioStore.audioURLForKey(item.itemKey) {
            if AppDelegate.audioStore.hasAudioForURL(url) {
             setupButtonEnable(startPlayBtn, enable: true)
            } else {
                setupButtonEnable(startPlayBtn, enable: false)
            }
        }
    }
    
    func setupButtonEnable(button: UIButton, enable: Bool) {
        if !enable {
            button.enabled = false
            button.alpha = 0.3
        } else {
            button.enabled = true
            button.alpha = 1.0
        }
    }
    
    
    
    //MARK: - Audio metering
    func startAudioMetering() {
      //  meteringView.hidden = false
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(updateMetering), userInfo: nil, repeats: true)
    }
    
    func stopAudioMetering() {
        timer?.invalidate()
        stopMeteringUI()
    }
    
    func updateMetering() {
        
        var dbLevel : Float = 0.0
        
        if isRecording {
            self.audioRecorder.updateMeters()
            dbLevel = self.audioRecorder.averagePowerForChannel(0)
        } else if isPlaying {
            self.audioPlayer.updateMeters()
            dbLevel = self.audioPlayer.averagePowerForChannel(0)
        }
        
        performSelectorOnMainThread(#selector(updateMeteringUI), withObject: dbLevel, waitUntilDone: false)
        
    }
    
    func setUpInstanceLayer() {
        let layerWidth = CGFloat(audioMeterInstanceWidth)
        let midX = CGRectGetMidX(meteringView.bounds) - layerWidth / 2.0
        let instanceHeight = layerWidth * audioMeterIntancelengthMultiplier
        meteringInstanceLayer.frame = CGRect(x: midX, y: meteringView.bounds.height, width: layerWidth, height: instanceHeight)
        meteringInstanceLayer.backgroundColor = AppDelegate.cellInnerColor.CGColor

    }
    
    func setUpReplicatorLayer() {
        meteringReplicatorLayer.frame = meteringView.bounds
        meteringReplicatorLayer.instanceCount = 1
        meteringReplicatorLayer.preservesDepth = false
        meteringReplicatorLayer.addSublayer(meteringInstanceLayer)
        meteringReplicatorLayer.instanceTransform = CATransform3DMakeTranslation(CGFloat(0), CGFloat(-audioMeterInstanceOffset), CGFloat(0))
        
    }
    
    func initControllerView(){
        controllerView.backgroundColor = UIColor.clearColor()
        startRecordBtn.backgroundColor = UIColor.clearColor()
        startPlayBtn.backgroundColor = UIColor.clearColor()
        controllerView.layer.borderColor = AppDelegate.cellInnerColor.CGColor
        controllerView.layer.borderWidth = 2
        controllerView.layer.cornerRadius = 10

    }
    func initMeteringView() {
        let rectanglePath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 50, height: 100))
        meteringPath = rectanglePath
        meteringView.backgroundColor = UIColor.clearColor()
        setUpInstanceLayer()
        setUpReplicatorLayer()
        meteringLayer.borderColor = AppDelegate.cellInnerColor.CGColor
        meteringLayer.borderWidth = 2
        meteringLayer.cornerRadius = 2
        meteringLayer.addSublayer(meteringReplicatorLayer)
       // meteringView.hidden = true
       
        
    }
    
    func stopMeteringUI() {
        meteringReplicatorLayer.instanceCount = 1

    }
    
    func updateMeteringUI(obj: AnyObject) {
            let dbLevel = obj as! Float
            var heightPercentage = CGFloat((dbLevel + audioDbMaxNegativeValue) / audioDbMaxNegativeValue)
            if heightPercentage < 0
            {
                heightPercentage = 0
            }
            print (heightPercentage)
        
            var count = Int(CGFloat(audioMeteringInstanceMaxCount) * heightPercentage)
        
            let rand = Int(arc4random() % UInt32(3))
            count += rand

            if count > audioMeteringInstanceMaxCount {
                count = audioMeteringInstanceMaxCount
            }
            meteringReplicatorLayer.instanceCount = count
        
    }

    
    //MARK: - View initializing
    func initPlayButtonView(canPlay : Bool)
    {
        
        audioPlayLayer.removeFromSuperlayer()
        audioPlayLayer.backgroundColor = UIColor.clearColor().CGColor
        audioPlayLayer.path = canPlay ? audioPlayPath.CGPath : audioStopRecordPath.CGPath
        audioPlayLayer.fillColor = AppDelegate.cellInnerColor.CGColor
        audioPlayLayer.fillRule = kCAFillRuleEvenOdd
        startPlayBtn.layer.addSublayer(audioPlayLayer)
    }
    
    func initRecordButtonView(canRecord : Bool) {
        
        audioRecordLayer.removeFromSuperlayer()
        audioRecordLayer.backgroundColor = UIColor.clearColor().CGColor
        audioRecordLayer.path = canRecord ? audioRecordPath.CGPath : audioStopRecordPath.CGPath
        audioRecordLayer.fillColor = AppDelegate.cellInnerColor.CGColor
        audioRecordLayer.fillRule = kCAFillRuleEvenOdd
        startRecordBtn.layer.addSublayer(audioRecordLayer)

    }
    
    func initAudioPlayPath() {
        //// Group 2
        //// Group 3
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: 0.08, y: 5.89))
        bezierPath.addCurveToPoint(CGPoint(x: 8.82, y: 0.97), controlPoint1: CGPoint(x: 0.08, y: 0.45), controlPoint2: CGPoint(x: 4.05, y: -1.75))
        bezierPath.addLineToPoint(CGPoint(x: 43.42, y: 20.52))
        bezierPath.addCurveToPoint(CGPoint(x: 43.42, y: 30.36), controlPoint1: CGPoint(x: 48.19, y: 23.24), controlPoint2: CGPoint(x: 48.19, y: 27.64))
        bezierPath.addLineToPoint(CGPoint(x: 8.82, y: 49.91))
        bezierPath.addCurveToPoint(CGPoint(x: 0.08, y: 44.99), controlPoint1: CGPoint(x: 4.05, y: 52.5), controlPoint2: CGPoint(x: 0.08, y: 50.3))
        bezierPath.addLineToPoint(CGPoint(x: 0.08, y: 5.89))
        bezierPath.closePath()
        bezierPath.miterLimit = 4;

        
        audioPlayPath = bezierPath
    }
    
    func initAudioPausePath() {
        //// Group 3
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: 0.06, y: 0.5))
        bezierPath.addLineToPoint(CGPoint(x: 18.75, y: 0.5))
        bezierPath.addLineToPoint(CGPoint(x: 18.75, y: 62))
        bezierPath.addLineToPoint(CGPoint(x: 0.06, y: 62))
        bezierPath.addLineToPoint(CGPoint(x: 0.06, y: 0.5))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPoint(x: 30.31, y: 0.5))
        bezierPath.addLineToPoint(CGPoint(x: 49, y: 0.5))
        bezierPath.addLineToPoint(CGPoint(x: 49, y: 62))
        bezierPath.addLineToPoint(CGPoint(x: 30.31, y: 62))
        bezierPath.addLineToPoint(CGPoint(x: 30.31, y: 0.5))
        bezierPath.closePath()
        bezierPath.miterLimit = 4;
    
        audioPausePath = bezierPath
    }
    
    func initAudioRecordPath() {
        let ovalPath = UIBezierPath(ovalInRect: CGRect(x: -0.25, y: -0.25, width: 51.5, height: 51.5))
        audioRecordPath = ovalPath
    }
    
    func initAudioStopRecordPath() {
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: 45.5, y: -0))
        bezierPath.addLineToPoint(CGPoint(x: 3.5, y: -0))
        bezierPath.addCurveToPoint(CGPoint(x: 0, y: 3.5), controlPoint1: CGPoint(x: 1.58, y: -0), controlPoint2: CGPoint(x: 0, y: 1.57))
        bezierPath.addLineToPoint(CGPoint(x: 0, y: 45.5))
        bezierPath.addCurveToPoint(CGPoint(x: 3.5, y: 49), controlPoint1: CGPoint(x: 0, y: 47.42), controlPoint2: CGPoint(x: 1.58, y: 49))
        bezierPath.addLineToPoint(CGPoint(x: 45.5, y: 49))
        bezierPath.addCurveToPoint(CGPoint(x: 49, y: 45.5), controlPoint1: CGPoint(x: 47.43, y: 49), controlPoint2: CGPoint(x: 49, y: 47.42))
        bezierPath.addLineToPoint(CGPoint(x: 49, y: 3.5))
        bezierPath.addCurveToPoint(CGPoint(x: 45.5, y: -0), controlPoint1: CGPoint(x: 49, y: 1.57), controlPoint2: CGPoint(x: 47.43, y: -0))
        bezierPath.closePath()
        bezierPath.miterLimit = 4;
        
        audioStopRecordPath = bezierPath
    }
    
    //MARK: - Animation initializing
    func addBtnPathAnimation(duration: NSTimeInterval, delay:NSTimeInterval, from: CGPath, to: CGPath,onLayer layer: CAShapeLayer,completion: (() -> Void)?) {
            let animation = CABasicAnimation(keyPath: "path")
            animation.timingFunction      = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            animation.fromValue           = from
            animation.toValue             = to
            animation.duration            = duration
            animation.delegate            = self
            animation.fillMode            = kCAFillModeForwards
            animation.removedOnCompletion = false;
            animation.beginTime           = CACurrentMediaTime() + delay
            
            layer.addAnimation(animation, forKey: "btn.path")
        
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64((delay + duration) * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                completion?()
            }
    }

    //MARK: - Recording controler

    @IBAction func startRecord(sender: UIButton) {
        if !isRecording {
            print ("start record")
            
            do {
                if let url = self.directoryURL {
                    try audioSession.setActive(true)
                    try audioRecorder = AVAudioRecorder(URL: url, settings: recordSettings)
                    audioRecorder.delegate = self
                    audioRecorder.prepareToRecord()
                    audioRecorder.meteringEnabled = true
                }
                 startAudioMetering()
                 audioRecorder.record()
                 isRecording = true
               //  let duration = NSTimeInterval(0.5)
               //  let delay = 0.0
               //  addBtnPathAnimation(duration, delay: delay, from: audioRecordPath.CGPath, to:// audioStopRecordPath.CGPath, onLayer: audioRecordLayer) {
                    self.initRecordButtonView(false)
                    self.setupButtonEnable(startPlayBtn, enable: false)
               // }
            } catch {
                print ("start recording failed: \(error)")
            }

        } else {
            guard audioRecorder != nil else {
                print ("cannot stop recording")
                return
            }
            audioRecorder.stop()
            stopAudioMetering()
            isRecording = false
            self.initRecordButtonView(true)
            self.setupButtonEnable(startPlayBtn, enable: true)
            do {
                try audioSession.setActive(false)
            } catch {
                print ("stop recording failed: \(error)")
            }

        }
        
        
    }
    
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print ("record finished successfully")
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        handlingStop()
    }
    
    
    //MARK: - Playing control
    
    
    func handlingStop() {
        if let ap = audioPlayer {
            ap.stop()
            print ("stopped play")
            self.initPlayButtonView(true)
            self.setupButtonEnable(startRecordBtn, enable: true)
            isPlaying = false
            stopAudioMetering()
        } else {
            print ("audio player stopping failed")
        }

    }
    @IBAction func startPlay(sender: UIButton) {
        if !isPlaying {
            if let url = self.directoryURL {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOfURL: url)
                    audioPlayer.delegate = self
                    audioPlayer.prepareToPlay()
                    audioPlayer.meteringEnabled = true
                    audioPlayer.play()
                } catch  {
                    print ("playing failed: \(error)")
                }
                
                print ("started play")
                isPlaying = true
                // let duration = NSTimeInterval(0.5)
                // let delay = 0.0
                // addPlayBtnPathAnimation(duration, delay: delay) {
                self.initPlayButtonView(false)
                self.setupButtonEnable(startRecordBtn, enable: false)
                // }
                startAudioMetering()
                
            } else  {
                print ("Cannot get url")
            }

        } else {
            handlingStop()
        }
        
        
    }
   
}