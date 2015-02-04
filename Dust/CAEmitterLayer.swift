//
//  CAEmitterLayer.swift
//  Dust
//
//  Created by Joe Blau on 12/10/14.
//  Copyright (c) 2014 joeblau. All rights reserved.
//

import UIKit

extension CAEmitterLayer {
    convenience init(emitterColor: UIColor!) {
        self.init()
        emitterPosition = CGPointMake(-100,-100)
        emitterSize = CGSizeMake(60.0,1)
        emitterMode = kCAEmitterLayerOutline
        emitterShape = kCAEmitterLayerPoint
        renderMode = kCAEmitterLayerAdditive
        shadowOpacity = 0.0
        shadowRadius = 0.0
        shadowOffset = CGSizeMake(0,0)
        shadowColor = UIColor.whiteColor().CGColor
        
        var emitterCell = CAEmitterCell()
        emitterCell.name = "dustCell"
        emitterCell.beginTime = CACurrentMediaTime()
        emitterCell.birthRate = 1000
        emitterCell.lifetime = 6.0
        emitterCell.lifetimeRange = 0.5
        emitterCell.color = emitterColor.CGColor
        emitterCell.redSpeed = 0.000
        emitterCell.greenSpeed = 0.000
        emitterCell.blueSpeed = 0.000
        emitterCell.alphaSpeed = 0.000
        emitterCell.redRange = 0.581
        emitterCell.greenRange = 0.000
        emitterCell.blueRange = 0.000
        emitterCell.alphaRange = 0.000
        emitterCell.contents = UIImage(named: "particle")?.CGImage
        emitterCell.emissionRange = CGFloat(2.000*M_PI)
        emitterCell.emissionLatitude = CGFloat(0.000*M_PI)
        emitterCell.emissionLongitude = CGFloat(0.000*M_PI)
        emitterCell.velocity = 1
        emitterCell.velocityRange = 1
        emitterCell.xAcceleration = 0
        emitterCell.yAcceleration = 0
        emitterCell.spin = CGFloat(0.0*M_PI)
        emitterCell.spinRange = CGFloat(0.01*M_PI)
        emitterCell.scale = 3.0/UIScreen.mainScreen().scale
        emitterCell.scaleSpeed = 0.0
        emitterCell.scaleRange = 5.0
    
        emitterCells = [emitterCell]
    }
    
    func getEmitterCell(idx: Int) -> CAEmitterCell {
        return emitterCells[idx] as CAEmitterCell
    }
}
