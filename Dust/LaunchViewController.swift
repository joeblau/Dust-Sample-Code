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
    var dispatchToken: dispatch_once_t = 0
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.067, green: 0.067, blue: 0.067, alpha: 1.0)
        titleLabel.textColor = UIColor(red: 0.067, green: 0.067, blue: 0.067, alpha: 1.0)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
        
//        self.drawAppIcon()
        
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
            
            emitterCell.birthRate = 0.01 * Float(width/6) * Float(height) * Float(UIScreen.mainScreen().scale)
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
    }
    
    func drawAppIcon() {
        
        var dustView = UIView(frame: CGRectMake(0, 0, 200, 250))
        
        //// d Drawing
        var dPath = UIBezierPath()
        dPath.moveToPoint(CGPointMake(68.73, 200))
        dPath.addCurveToPoint(CGPointMake(137.04, 174.37), controlPoint1: CGPointMake(98.97, 199.25), controlPoint2: CGPointMake(121.74, 190.71))
        dPath.addCurveToPoint(CGPointMake(160, 100), controlPoint1: CGPointMake(152.35, 158.03), controlPoint2: CGPointMake(160, 133.24))
        dPath.addCurveToPoint(CGPointMake(137.04, 25.63), controlPoint1: CGPointMake(160, 66.76), controlPoint2: CGPointMake(152.35, 41.97))
        dPath.addCurveToPoint(CGPointMake(68.73, 0), controlPoint1: CGPointMake(121.74, 9.29), controlPoint2: CGPointMake(98.97, 0.75))
        dPath.addLineToPoint(CGPointMake(0, 0))
        dPath.addLineToPoint(CGPointMake(0, 60))
        UIColor.blackColor().setFill()
        dPath.fill()
        
        var danimation = createAnimation(dPath)
        var dEmitter = CAEmitterLayer(emitterColor: DustColors(rawValue: 0)?.get())
        dEmitter.getEmitterCell(0).scale = 3
        
        dEmitter.addAnimation(danimation, forKey: "dkey")
        dustView.layer.addSublayer(dEmitter)
        
        dustView.center = view.center
        self.view.addSubview(dustView)
    }
    
    func createAnimation(path: UIBezierPath) -> CAKeyframeAnimation {
        var animation = CAKeyframeAnimation(keyPath: "emitterPosition")
        animation.duration = 3.0
        animation.path = path.CGPath
        return animation
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
    }
}
