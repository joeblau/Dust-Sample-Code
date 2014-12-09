//
//  LaunchScreenView.swift
//  Dust
//
//  Created by Joe Blau on 9/22/14.
//  Copyright (c) 2014 joeblau. All rights reserved.
//

import UIKit

class LaunchScreenView: UIView {

  // Only override drawRect: if you perform custom drawing.
  // An empty implementation adversely affects performance during animation.
//  override func drawRect(rect: CGRect) {
//    backgroundColor = UIColor.blackColor()
//    
//    var dustView = UIView(frame: CGRectMake(0, 0, 240, 120))
//    
//    //// d Drawing
//    var dPath = UIBezierPath()
//    // Hack so that the particle emitter doesn't create a big ball at the starting location
//    dPath.moveToPoint(CGPointMake(-100.0, -100.0))
//    dPath.addLineToPoint(CGPointMake(-101.0, -101.0))
//    dPath.moveToPoint(CGPointMake(6.12, 82))
//    dPath.addLineToPoint(CGPointMake(6.12, 26.8))
//    dPath.addCurveToPoint(CGPointMake(29.72, 26), controlPoint1: CGPointMake(15.51, 26.27), controlPoint2: CGPointMake(23.37, 26))
//    dPath.addCurveToPoint(CGPointMake(44.96, 28.44), controlPoint1: CGPointMake(36.28, 26), controlPoint2: CGPointMake(41.36, 26.81))
//    dPath.addCurveToPoint(CGPointMake(52.92, 37), controlPoint1: CGPointMake(48.56, 30.07), controlPoint2: CGPointMake(51.21, 32.92))
//    dPath.addCurveToPoint(CGPointMake(55.48, 54.4), controlPoint1: CGPointMake(54.63, 41.08), controlPoint2: CGPointMake(55.48, 46.88))
//    dPath.addCurveToPoint(CGPointMake(52.92, 71.8), controlPoint1: CGPointMake(55.48, 61.92), controlPoint2: CGPointMake(54.63, 67.72))
//    dPath.addCurveToPoint(CGPointMake(44.96, 80.36), controlPoint1: CGPointMake(51.21, 75.88), controlPoint2: CGPointMake(48.56, 78.73))
//    dPath.addCurveToPoint(CGPointMake(29.72, 82.8), controlPoint1: CGPointMake(41.36, 81.99), controlPoint2: CGPointMake(36.28, 82.8))
//    dPath.addCurveToPoint(CGPointMake(6.12, 82), controlPoint1: CGPointMake(21.72, 82.8), controlPoint2: CGPointMake(13.85, 82.53))
//    dPath.closePath()
//    dPath.moveToPoint(CGPointMake(23.48, 70.16))
//    dPath.addLineToPoint(CGPointMake(29.72, 70.24))
//    dPath.addCurveToPoint(CGPointMake(35.68, 67.08), controlPoint1: CGPointMake(32.71, 70.24), controlPoint2: CGPointMake(34.69, 69.19))
//    dPath.addCurveToPoint(CGPointMake(37.16, 54.4), controlPoint1: CGPointMake(36.67, 64.97), controlPoint2: CGPointMake(37.16, 60.75))
//    dPath.addCurveToPoint(CGPointMake(35.68, 41.72), controlPoint1: CGPointMake(37.16, 48.05), controlPoint2: CGPointMake(36.67, 43.83))
//    dPath.addCurveToPoint(CGPointMake(29.72, 38.56), controlPoint1: CGPointMake(34.69, 39.61), controlPoint2: CGPointMake(32.71, 38.56))
//    dPath.addLineToPoint(CGPointMake(23.48, 38.56))
//    dPath.addLineToPoint(CGPointMake(23.48, 70.16))
//    // End hack
//    dPath.moveToPoint(CGPointMake(-100.0, -100.0))
//    dPath.addLineToPoint(CGPointMake(-101.0, -101.0))
//    dPath.closePath()
//    UIColor.blackColor().setFill()
//    dPath.fill()
//    
//    
//    //// u Drawing
//    var uPath = UIBezierPath()
//    // Start hack
//    uPath.moveToPoint(CGPointMake(-100.0, -100.0))
//    uPath.addLineToPoint(CGPointMake(-101.0, -101.0))
//    uPath.moveToPoint(CGPointMake(111.16, 42))
//    uPath.addLineToPoint(CGPointMake(111.16, 82))
//    uPath.addLineToPoint(CGPointMake(97.96, 82))
//    uPath.addLineToPoint(CGPointMake(96.44, 76.16))
//    uPath.addCurveToPoint(CGPointMake(80.44, 83.12), controlPoint1: CGPointMake(91.32, 80.8), controlPoint2: CGPointMake(85.99, 83.12))
//    uPath.addCurveToPoint(CGPointMake(68.6, 71.92), controlPoint1: CGPointMake(72.55, 83.12), controlPoint2: CGPointMake(68.6, 79.39))
//    uPath.addLineToPoint(CGPointMake(68.6, 42))
//    uPath.addLineToPoint(CGPointMake(85.4, 42))
//    uPath.addLineToPoint(CGPointMake(85.4, 66.56))
//    uPath.addCurveToPoint(CGPointMake(88.36, 69.04), controlPoint1: CGPointMake(85.4, 68.21), controlPoint2: CGPointMake(86.39, 69.04))
//    uPath.addCurveToPoint(CGPointMake(94.28, 68.08), controlPoint1: CGPointMake(90.28, 69.04), controlPoint2: CGPointMake(92.25, 68.72))
//    uPath.addLineToPoint(CGPointMake(94.28, 42))
//    uPath.addLineToPoint(CGPointMake(111.16, 42))
//    // End hack
//    uPath.moveToPoint(CGPointMake(-100.0, -100.0))
//    uPath.addLineToPoint(CGPointMake(-101.0, -101.0))
//    uPath.closePath()
//    UIColor.blackColor().setFill()
//    uPath.fill()
//    
//    
//    //// s Drawing
//    var sPath = UIBezierPath()
//    // Start hack
//    sPath.moveToPoint(CGPointMake(-100.0, -100.0))
//    sPath.addLineToPoint(CGPointMake(-101.0, -101.0))
//    sPath.moveToPoint(CGPointMake(149.08, 68.08))
//    sPath.addLineToPoint(CGPointMake(140.28, 65.68))
//    sPath.addCurveToPoint(CGPointMake(131.96, 60.8), controlPoint1: CGPointMake(136.17, 64.51), controlPoint2: CGPointMake(133.4, 62.88))
//    sPath.addCurveToPoint(CGPointMake(129.8, 52.56), controlPoint1: CGPointMake(130.52, 58.72), controlPoint2: CGPointMake(129.8, 55.97))
//    sPath.addCurveToPoint(CGPointMake(134.04, 43.84), controlPoint1: CGPointMake(129.8, 48.72), controlPoint2: CGPointMake(131.21, 45.81))
//    sPath.addCurveToPoint(CGPointMake(148.36, 40.88), controlPoint1: CGPointMake(136.87, 41.87), controlPoint2: CGPointMake(141.64, 40.88))
//    sPath.addCurveToPoint(CGPointMake(168.84, 42.64), controlPoint1: CGPointMake(156.31, 40.88), controlPoint2: CGPointMake(163.13, 41.47))
//    sPath.addLineToPoint(CGPointMake(167.8, 52.4))
//    sPath.addLineToPoint(CGPointMake(152.04, 52.4))
//    sPath.addCurveToPoint(CGPointMake(146.88, 52.52), controlPoint1: CGPointMake(149.16, 52.4), controlPoint2: CGPointMake(147.44, 52.44))
//    sPath.addCurveToPoint(CGPointMake(146.04, 53.36), controlPoint1: CGPointMake(146.32, 52.6), controlPoint2: CGPointMake(146.04, 52.88))
//    sPath.addCurveToPoint(CGPointMake(148.76, 54.72), controlPoint1: CGPointMake(146.04, 53.84), controlPoint2: CGPointMake(146.95, 54.29))
//    sPath.addCurveToPoint(CGPointMake(150.76, 55.28), controlPoint1: CGPointMake(149.56, 54.93), controlPoint2: CGPointMake(150.23, 55.12))
//    sPath.addLineToPoint(CGPointMake(159.96, 57.6))
//    sPath.addCurveToPoint(CGPointMake(168, 61.88), controlPoint1: CGPointMake(163.64, 58.61), controlPoint2: CGPointMake(166.32, 60.04))
//    sPath.addCurveToPoint(CGPointMake(170.52, 69.68), controlPoint1: CGPointMake(169.68, 63.72), controlPoint2: CGPointMake(170.52, 66.32))
//    sPath.addCurveToPoint(CGPointMake(166.16, 80.04), controlPoint1: CGPointMake(170.52, 74.69), controlPoint2: CGPointMake(169.07, 78.15))
//    sPath.addCurveToPoint(CGPointMake(151.16, 82.88), controlPoint1: CGPointMake(163.25, 81.93), controlPoint2: CGPointMake(158.25, 82.88))
//    sPath.addCurveToPoint(CGPointMake(130.36, 81.2), controlPoint1: CGPointMake(143.8, 82.88), controlPoint2: CGPointMake(136.87, 82.32))
//    sPath.addLineToPoint(CGPointMake(131.4, 71.44))
//    sPath.addLineToPoint(CGPointMake(145.64, 71.44))
//    sPath.addCurveToPoint(CGPointMake(152.92, 71.28), controlPoint1: CGPointMake(149.59, 71.44), controlPoint2: CGPointMake(152.01, 71.39))
//    sPath.addCurveToPoint(CGPointMake(154.28, 70.24), controlPoint1: CGPointMake(153.83, 71.17), controlPoint2: CGPointMake(154.28, 70.83))
//    sPath.addCurveToPoint(CGPointMake(154.24, 69.96), controlPoint1: CGPointMake(154.28, 70.13), controlPoint2: CGPointMake(154.27, 70.04))
//    sPath.addCurveToPoint(CGPointMake(154.08, 69.72), controlPoint1: CGPointMake(154.21, 69.88), controlPoint2: CGPointMake(154.16, 69.8))
//    sPath.addCurveToPoint(CGPointMake(153.84, 69.52), controlPoint1: CGPointMake(154, 69.64), controlPoint2: CGPointMake(153.92, 69.57))
//    sPath.addCurveToPoint(CGPointMake(153.48, 69.32), controlPoint1: CGPointMake(153.76, 69.47), controlPoint2: CGPointMake(153.64, 69.4))
//    sPath.addCurveToPoint(CGPointMake(152.96, 69.16), controlPoint1: CGPointMake(153.32, 69.24), controlPoint2: CGPointMake(153.15, 69.19))
//    sPath.addCurveToPoint(CGPointMake(152.24, 68.96), controlPoint1: CGPointMake(152.77, 69.13), controlPoint2: CGPointMake(152.53, 69.07))
//    sPath.addCurveToPoint(CGPointMake(151.4, 68.72), controlPoint1: CGPointMake(151.95, 68.85), controlPoint2: CGPointMake(151.67, 68.77))
//    sPath.addCurveToPoint(CGPointMake(150.36, 68.44), controlPoint1: CGPointMake(151.13, 68.67), controlPoint2: CGPointMake(150.79, 68.57))
//    sPath.addCurveToPoint(CGPointMake(149.08, 68.08), controlPoint1: CGPointMake(149.93, 68.31), controlPoint2: CGPointMake(149.51, 68.19))
//    // End hack
//    sPath.moveToPoint(CGPointMake(-100.0, -100.0))
//    sPath.addLineToPoint(CGPointMake(-101.0, -101.0))
//    sPath.closePath()
//    UIColor.blackColor().setFill()
//    sPath.fill()
//    
//    
//    //// t Drawing
//    var tPath = UIBezierPath()
//    // Start hack
//    tPath.moveToPoint(CGPointMake(-100.0, -100.0))
//    tPath.addLineToPoint(CGPointMake(-101.0, -101.0))
//    tPath.moveToPoint(CGPointMake(216.88, 52.08))
//    tPath.addLineToPoint(CGPointMake(216.88, 67.44))
//    tPath.addCurveToPoint(CGPointMake(217.68, 69.64), controlPoint1: CGPointMake(216.88, 68.45), controlPoint2: CGPointMake(217.15, 69.19))
//    tPath.addCurveToPoint(CGPointMake(220.32, 70.32), controlPoint1: CGPointMake(218.21, 70.09), controlPoint2: CGPointMake(219.09, 70.32))
//    tPath.addLineToPoint(CGPointMake(224.56, 70.32))
//    tPath.addLineToPoint(CGPointMake(226.4, 81.04))
//    tPath.addCurveToPoint(CGPointMake(212.8, 83.12), controlPoint1: CGPointMake(223.09, 82.43), controlPoint2: CGPointMake(218.56, 83.12))
//    tPath.addCurveToPoint(CGPointMake(203.52, 80.16), controlPoint1: CGPointMake(208.91, 83.12), controlPoint2: CGPointMake(205.81, 82.13))
//    tPath.addCurveToPoint(CGPointMake(200.08, 71.92), controlPoint1: CGPointMake(201.23, 78.19), controlPoint2: CGPointMake(200.08, 75.44))
//    tPath.addLineToPoint(CGPointMake(200.08, 52.08))
//    tPath.addLineToPoint(CGPointMake(193.28, 52.08))
//    tPath.addLineToPoint(CGPointMake(193.28, 42.4))
//    tPath.addLineToPoint(CGPointMake(200, 42.08))
//    tPath.addLineToPoint(CGPointMake(200, 31.52))
//    tPath.addLineToPoint(CGPointMake(216.88, 31.52))
//    tPath.addLineToPoint(CGPointMake(216.88, 42))
//    tPath.addLineToPoint(CGPointMake(226.56, 42))
//    tPath.addLineToPoint(CGPointMake(226.56, 52.08))
//    tPath.addLineToPoint(CGPointMake(216.88, 52.08))
//    // End hack
//    tPath.moveToPoint(CGPointMake(-100.0, -100.0))
//    tPath.addLineToPoint(CGPointMake(-101.0, -101.0))
//    tPath.closePath()
//    UIColor.blackColor().setFill()
//    tPath.fill()
//    
//    var danimation = createAnimation(dPath)
//    var uanimation = createAnimation(uPath)
//    var sanimation = createAnimation(sPath)
//    var tanimation = createAnimation(tPath)
//    
//    var dEmitter = createEmitter()
//    var uEmitter = createEmitter()
//    var sEmitter = createEmitter()
//    var tEmitter = createEmitter()
//    
//    dEmitter.addAnimation(danimation, forKey: "test")
//    uEmitter.addAnimation(uanimation, forKey: "test")
//    sEmitter.addAnimation(sanimation, forKey: "test")
//    tEmitter.addAnimation(tanimation, forKey: "test")
//    
//    dustView.layer.addSublayer(dEmitter)
//    dustView.layer.addSublayer(uEmitter)
//    dustView.layer.addSublayer(sEmitter)
//    dustView.layer.addSublayer(tEmitter)
//    
//    dustView.center = center
//    addSubview(dustView)
//  }
//
//  func createAnimation(path: UIBezierPath) -> CAKeyframeAnimation {
//    var animation = CAKeyframeAnimation(keyPath: "emitterPosition")
//    animation.duration = 6.0
//    //    animation.timingFunction = CAMediaTimingFunction(name: "linear")
//    //    animation.repeatCount = MAXFLOAT
//    animation.path = path.CGPath
//    return animation
//  }
//  
//  func createEmitter() -> CAEmitterLayer {
//    var newEmitterLayer = CAEmitterLayer()
//    newEmitterLayer.emitterPosition = CGPointMake(-100.0,-100.0)
//    newEmitterLayer.emitterSize = CGSizeMake(1.0,1)
//    newEmitterLayer.emitterMode = kCAEmitterLayerOutline
//    newEmitterLayer.emitterShape = kCAEmitterLayerPoint
//    newEmitterLayer.renderMode = kCAEmitterLayerAdditive
//    newEmitterLayer.shadowOpacity = 0.0
//    newEmitterLayer.shadowRadius = 0.0
//    newEmitterLayer.shadowOffset = CGSizeMake(0,0)
//    newEmitterLayer.shadowColor = UIColor.whiteColor().CGColor
//    
//    var newEmitterCell = CAEmitterCell()
//    newEmitterCell.name = "dustCell"
//    newEmitterCell.birthRate = 1000
//    newEmitterCell.lifetime = 6.0
//    newEmitterCell.lifetimeRange = 6.0
//    
//    newEmitterCell.color = UIColor(red: 1.0, green: 0.17, blue: 0.10, alpha: 1.0).CGColor
//    newEmitterCell.redSpeed = 0.000
//    newEmitterCell.greenSpeed = 0.000
//    newEmitterCell.blueSpeed = 0.000
//    newEmitterCell.alphaSpeed = 0.000
//    newEmitterCell.redRange = 0.0
//    newEmitterCell.greenRange = 0.000
//    newEmitterCell.blueRange = 0.000
//    newEmitterCell.alphaRange = 0.000
//    newEmitterCell.contents = UIImage(named: "particle").CGImage
//    newEmitterCell.emissionRange = CGFloat(2.000*M_PI)
//    newEmitterCell.emissionLatitude = CGFloat(0.000*M_PI)
//    newEmitterCell.emissionLongitude = CGFloat(0.000*M_PI)
//    newEmitterCell.velocity = 0.4
//    newEmitterCell.velocityRange = 0.4
//    newEmitterCell.xAcceleration = 0
//    newEmitterCell.yAcceleration = 0
//    newEmitterCell.spin = CGFloat(0.02*M_PI)
//    newEmitterCell.spinRange = CGFloat(0.02*M_PI)
//    newEmitterCell.scale = 0.8/UIScreen.mainScreen().scale
//    newEmitterCell.scaleSpeed = 0.05
//    newEmitterCell.scaleRange = 0.4
//    
//    newEmitterLayer.emitterCells = [newEmitterCell]
//    return newEmitterLayer
//  }

}
