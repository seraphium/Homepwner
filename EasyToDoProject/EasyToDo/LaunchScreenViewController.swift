//
//  LaunchScreenViewController.swift
//  EasyToDo
//
//  Created by Jackie Zhang on 16/6/17.
//  Copyright © 2016年 Jackie Zhang. All rights reserved.
//

import UIKit

class LaunchScreenViewController : UIViewController {
        
    var launchView : UIView!
    var launchImageView : UIView!
        
    override func viewWillAppear(animated: Bool) {
        initLaunchView()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        showLaunchAnimation() {
            let sb = UIStoryboard(name: "Main", bundle: nil)

            let nav = sb.instantiateViewControllerWithIdentifier("222") as! UINavigationController
            self.view.window?.rootViewController = nav
        }
        
    }
    
    func initLaunchView() {
        launchView = UIView(frame: view.frame)
        
        let image = UIImage(named: "AppIcon60x60")
        launchImageView = UIImageView(image: image)
        launchImageView.center = launchView.center
        launchView.addSubview(launchImageView)
        launchView.center = view.center
        launchView.backgroundColor = AppDelegate.cellInnerColor
        view.addSubview(launchView)
        
    }
    
    func showLaunchAnimation(completion: (() -> Void)?)
    {
   
        UIView.animateWithDuration(0.4,delay: 0.0, options: [.CurveEaseInOut], animations: {
            self.launchImageView.frame = CGRectMake(0,0,50,50)
            self.launchImageView.center = self.view.center
            }, completion: { (done) -> Void in
                UIView.animateWithDuration(0.6, delay: 0.6, options: [.CurveEaseIn],animations: {
                    self.launchImageView.frame = CGRectMake(0, 0, 500, 500)
                    self.launchImageView.center = self.view.center
                    self.launchImageView.alpha = 0.0
                    }, completion:  { (done) -> Void in
                        self.launchImageView.removeFromSuperview()
                        completion?()
                })

        })


    }

}
