//
//  LaunchViewController.swift
//  Dust
//
//  Created by Joe Blau on 2/2/15.
//  Copyright (c) 2015 joeblau. All rights reserved.
//

import UIKit

final class LaunchViewController: UIViewController {
    private var emitters = [CAEmitterLayer]()
    private var dispatchToken: Int = 0
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.setStatusBarHidden(true, with: .fade)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LaunchViewController.handleTapGesture(_:)))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        
        _ = DustColors.colors.map {
            let (x,y,width,height) = (CGFloat(-20.0),CGFloat(-20.0),self.view.bounds.width+40.0,self.view.bounds.height+40.0)
            let oneSixth = CGFloat(width/6)
            
            let launchEmitter = CAEmitterLayer(emitterColor: $0.uiColor)
            launchEmitter.emitterShape = kCAEmitterLayerRectangle
            launchEmitter.emitterPosition = CGPoint(x: (CGFloat($0.rawValue) * oneSixth) + x + (oneSixth/2), y: (height/2) + y)
            launchEmitter.emitterMode = kCAEmitterLayerVolume
            launchEmitter.emitterSize = CGSize(width: width/6, height: height)
            launchEmitter.seed = arc4random()
            let emitterCell = launchEmitter.getEmitterCell(0)
            
            emitterCell.birthRate = 0.01 * Float(width/6) * Float(height) * Float(UIScreen.main.scale)
            emitterCell.lifetimeRange = 3
            emitterCell.emissionRange = CGFloat(2.000*M_PI)
            emitterCell.emissionLatitude = CGFloat(-1.000*M_PI)
            emitterCell.emissionLongitude = CGFloat(-1.000*M_PI)
            emitterCell.velocity = 40
            emitterCell.velocityRange = 70
            emitterCell.scale = 5.0/UIScreen.main.scale
            emitterCell.scaleRange = 2.0
            
            emitters.append(launchEmitter)
            view.layer.insertSublayer(launchEmitter, at: 0)
        }
    }
    
    func drawAppIcon() {
        let dustView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 250))
        
        let dPath = UIBezierPath()
        dPath.move(to: CGPoint(x: 68.73, y: 200))
        dPath.addCurve(to: CGPoint(x: 137.04, y: 174.37), controlPoint1: CGPoint(x: 98.97, y: 199.25), controlPoint2: CGPoint(x: 121.74, y: 190.71))
        dPath.addCurve(to: CGPoint(x: 160, y: 100), controlPoint1: CGPoint(x: 152.35, y: 158.03), controlPoint2: CGPoint(x: 160, y: 133.24))
        dPath.addCurve(to: CGPoint(x: 137.04, y: 25.63), controlPoint1: CGPoint(x: 160, y: 66.76), controlPoint2: CGPoint(x: 152.35, y: 41.97))
        dPath.addCurve(to: CGPoint(x: 68.73, y: 0), controlPoint1: CGPoint(x: 121.74, y: 9.29), controlPoint2: CGPoint(x: 98.97, y: 0.75))
        dPath.addLine(to: CGPoint(x: 0, y: 0))
        dPath.addLine(to: CGPoint(x: 0, y: 60))
        UIColor.black.setFill()
        dPath.fill()
        
        let danimation = createAnimation(dPath)
        let dEmitter = CAEmitterLayer(emitterColor: DustColors(rawValue: 0)?.uiColor)
        dEmitter.getEmitterCell(0).scale = 3
        
        dEmitter.add(danimation, forKey: "dkey")
        dustView.layer.addSublayer(dEmitter)
        
        dustView.center = view.center
        self.view.addSubview(dustView)
    }
    
    func createAnimation(_ path: UIBezierPath) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "emitterPosition")
        animation.duration = 3.0
        animation.path = path.cgPath
        return animation
    }
    
    func handleTapGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        UIView.animate(withDuration: 0.3, animations: {
            self.visualEffectView.alpha = 0.0
        })
        
        for emitter in emitters {
            emitter.lifetime = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(6.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.performSegue(withIdentifier: "startDust", sender: self)
        })
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        UIApplication.shared.setStatusBarHidden(true, with: .fade)
        
        for (idx, emitter) in emitters.enumerated() {
            let (x,y,width,height) = (CGFloat(-20.0),CGFloat(-20.0),size.width+40.0,size.height+40.0)
            let oneSixth = CGFloat(width/6)
            
            emitter.emitterPosition = CGPoint(x: (CGFloat(idx) * oneSixth) + x + (oneSixth/2), y: (height/2) + y)
            emitter.emitterSize = CGSize(width: width/6, height: height)
        }
    }
}
