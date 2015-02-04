//
//  LaunchViewController.swift
//  Dust
//
//  Created by Joe Blau on 2/2/15.
//  Copyright (c) 2015 joeblau. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    var emitterArray = Array<CAEmitterLayer>()
    let dustLabel = UILabel(frame: CGRectMake(0, 0, 280, 280))
    var dispatchToken: dispatch_once_t = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        
        let (x,y,width,height) = (CGFloat(-20.0),CGFloat(-20.0),self.view.bounds.width+40.0,self.view.bounds.height+40.0)
        let oneSixth = CGFloat(width/6)
        
        for idx in 0..<6 {
            var launchEmitter = CAEmitterLayer(emitterColor: DustColors(rawValue: idx)?.get())
            launchEmitter.emitterShape = kCAEmitterLayerRectangle
            launchEmitter.emitterPosition = CGPointMake((CGFloat(idx) * oneSixth) + x + (oneSixth/2), (height/2) + y)
            launchEmitter.emitterMode = kCAEmitterLayerVolume
            launchEmitter.emitterSize = CGSizeMake(width/6, height)
            launchEmitter.seed = arc4random()
            let emitterCell = launchEmitter.getEmitterCell(0)
            
            emitterCell.birthRate = 0.008 * Float(width/6) * Float(height) * Float(UIScreen.mainScreen().scale)
            emitterCell.lifetimeRange = 3
            emitterCell.emissionRange = CGFloat(2.000*M_PI)
            emitterCell.emissionLatitude = CGFloat(-1.000*M_PI)
            emitterCell.emissionLongitude = CGFloat(-1.000*M_PI)
            emitterCell.velocity = 40
            emitterCell.velocityRange = 70
            emitterCell.scale = 5.0/UIScreen.mainScreen().scale
            emitterCell.scaleRange = 2.0
            
            emitterArray.append(launchEmitter)
            view.layer.insertSublayer(launchEmitter, atIndex: 0)
        }
        
        dustLabel.text = "Dust"
        dustLabel.textAlignment = .Center
        dustLabel.font = UIFont(name: "HelveticaNeue-Light", size: 100)
        dustLabel.textColor = UIColor.whiteColor()
        dustLabel.center = view.center
        view.addSubview(dustLabel)
    }
    
    func handleTapGesture(gestureRecognizer: UIPanGestureRecognizer) {
        for idx in 0..<6 {
            var launchEmitter = emitterArray[idx]
            launchEmitter.lifetime = 0
        }
        
        dispatch_once(&dispatchToken) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(6.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                self.performSegueWithIdentifier("startDust", sender: self)
            })
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
         UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
        let (x,y,width,height) = (CGFloat(-20.0),CGFloat(-20.0),size.width+40.0,size.height+40.0)
        let oneSixth = CGFloat(width/6)
        for idx in 0..<6 {
            var launchEmitter = emitterArray[idx]
            launchEmitter.emitterPosition = CGPointMake((CGFloat(idx) * oneSixth) + x + (oneSixth/2), (height/2) + y)
            launchEmitter.emitterSize = CGSizeMake(width/6, height)
        }
        dustLabel.center = CGPointMake(size.width/2, size.height/2)
    }
}
