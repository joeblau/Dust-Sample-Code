//
//  ViewController.swift
//  Dust
//
//  Created by Joe Blau on 9/12/14.
//  Copyright (c) 2014 joeblau. All rights reserved.
//

import UIKit
import PKHUD
import MultipeerConnectivity

enum GestureType {
    case Pan, Tap, End
}

enum DustColors: Int {
    case Red = 0, Orange, Yellow, Green, Blue, Violet
    
    func get() -> UIColor! {
        switch (self) {
        case .Red: return UIColor(red: 0.898, green: 0.302, blue: 0.259, alpha: 1.0)
        case .Orange: return UIColor(red: 0.894, green: 0.494, blue: 0.188, alpha: 1.0)
        case .Yellow: return UIColor(red: 0.941, green: 0.880, blue: 0.336, alpha: 1.0)
        case .Green: return UIColor(red: 0.224, green: 0.792, blue: 0.455, alpha: 1.0)
        case .Blue: return UIColor(red: 0.227, green: 0.600, blue: 0.847, alpha: 1.0)
        case .Violet: return UIColor(red: 0.604, green: 0.361, blue: 0.706, alpha: 1.0)
        }
    }
}

class ViewController: UIViewController, UIGestureRecognizerDelegate, MeshNetworkDelegate  {
    
    var myEmitter: CAEmitterLayer!
    var theirEmitter: CAEmitterLayer!
    
    var meshNetwork: MeshNetwork = MeshNetwork(serviceType: "Dust-Service")
    
    var peersOutputStreams: Dictionary<String, NSOutputStream>! = Dictionary<String, NSOutputStream>()
    
    @IBOutlet weak var connectionButton: UIBarButtonItem!
    @IBOutlet weak var connectedPeerCount: UIBarButtonItem!
    @IBOutlet weak var colorSegmentControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.067, green: 0.067, blue: 0.067, alpha: 1.0)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
        
        HUDController.sharedController.userInteractionOnUnderlyingViewsEnabled = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        panGesture.minimumNumberOfTouches = 1
        panGesture.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.numberOfTapsRequired = 2
        tapGesture.delegate = self
        
        view.addGestureRecognizer(panGesture)
        view.addGestureRecognizer(tapGesture)
        
        meshNetwork.delegate = self
        meshNetwork.joinMesh()

        connectionButton.tintColor = DustColors(rawValue: colorSegmentControl.selectedSegmentIndex)?.get()
        connectedPeerCount.tintColor = DustColors(rawValue: colorSegmentControl.selectedSegmentIndex)?.get()
        colorSegmentControl.tintColor = DustColors(rawValue: colorSegmentControl.selectedSegmentIndex)?.get()
        
        let emitterColor = DustColors(rawValue: colorSegmentControl.selectedSegmentIndex)?.get()
        myEmitter = CAEmitterLayer(emitterColor: emitterColor)
        view.layer.addSublayer(myEmitter)
        
        theirEmitter = CAEmitterLayer(emitterColor: emitterColor)
        view.layer.addSublayer(theirEmitter)
    }
    
    @IBAction func selectColor(sender: UISegmentedControl) {
        connectionButton.tintColor = DustColors(rawValue: colorSegmentControl.selectedSegmentIndex)?.get()
        connectedPeerCount.tintColor = DustColors(rawValue: colorSegmentControl.selectedSegmentIndex)?.get()
        colorSegmentControl.tintColor = DustColors(rawValue: colorSegmentControl.selectedSegmentIndex)?.get()
        myEmitter.setValue(DustColors(rawValue: colorSegmentControl.selectedSegmentIndex)?.get().CGColor, forKeyPath: "emitterCells.dustCell.color")
    }

    func handlePanGesture(gestureRecognizer: UIPanGestureRecognizer) {
        let point = gestureRecognizer.locationInView(self.view)
        myEmitter.lifetime = (gestureRecognizer.state == .Ended) ? 0 : 1
        myEmitter.emitterPosition = point
        myEmitter.emitterShape = kCAEmitterLayerPoint
        
        switch gestureRecognizer.state {
        case .Began, .Changed: sendDataMessage(point, gestureType: .Pan)
        case .Ended: sendDataMessage(point, gestureType: .End)
        default: return
        }
    }
    
    func handleTapGesture(gestureRecoginzer: UITapGestureRecognizer) {
        let point = gestureRecoginzer.locationInView(self.view)
        myEmitter.lifetime = 1
        myEmitter.emitterPosition = point
        myEmitter.emitterShape = kCAEmitterLayerCircle
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            self.myEmitter.lifetime = 0
        })
        sendDataMessage(point, gestureType: .Tap)
    }
    
    func sendDataMessage(point: CGPoint, gestureType: GestureType) {
        var sendData = NSMutableData()
        var percentX = Float(point.x/view.bounds.width)
        var percentY = Float(point.y/view.bounds.height)
        var type = gestureType
        var color: DustColors = DustColors(rawValue: colorSegmentControl.selectedSegmentIndex)!
        sendData.appendBytes(&percentX, length: sizeof(Float))
        sendData.appendBytes(&percentY, length: sizeof(Float))
        sendData.appendBytes(&type, length: sizeof(GestureType))
        sendData.appendBytes(&color, length: sizeof(DustColors))
        
        var error = NSErrorPointer()
        meshNetwork.sendData(sendData, peerIDs: meshNetwork.connectedPeers, mode: .Unreliable, error: nil)
    }

    // MARK: Mesh Network Delegate
    func meshNetwork(meshNetwork: MeshNetwork, peer peerID: MCPeerID, changedState state: MCSessionState, currentPeers: [AnyObject]) {
        let (status, image) = (state == .NotConnected) ? ("Disconnected", HUDAssets.crossImage) : ("Connected", HUDAssets.checkmarkImage)
        HUDController.sharedController.contentView = HUDContentView.StatusView(title: peerID.displayName, subtitle: status, image: image)
        HUDController.sharedController.show()
        HUDController.sharedController.hide(afterDelay: 4.0)
        connectionButton.image = UIImage(named: currentPeers.count >  0 ?"connect":"disconnect")
        connectedPeerCount.title = "\(currentPeers.count)"
    }
    
    func meshNetwork(meshNetwork: MeshNetwork, failedToJoinMesh error: NSError) {
        HUDController.sharedController.contentView = HUDContentView.SubtitleView(subtitle: "Error", image: HUDAssets.crossImage)
        HUDController.sharedController.show()
        HUDController.sharedController.hide(afterDelay: 4.0)
    }
    
    func meshNetwork(meshNetwork: MeshNetwork, didReceiveData data: NSData, fromPeer peerdID: MCPeerID) {
        var (percentX, percentY, type, color) = (Float(), Float(), GestureType.Pan, DustColors.Red)
        data.getBytes(&percentX, range: NSMakeRange(0, 4))
        data.getBytes(&percentY, range: NSMakeRange(4, 4))
        data.getBytes(&type, range: NSMakeRange(8, 1))
        data.getBytes(&color, range: NSMakeRange(9, 1))

        let x = CGFloat(percentX * Float(view.bounds.width))
        let y = CGFloat(percentY * Float(view.bounds.height))
        theirEmitter.setValue(color.get().CGColor, forKeyPath: "emitterCells.dustCell.color")
        
        theirEmitter.lifetime = 1
        theirEmitter.emitterPosition = CGPointMake(x, y)
        switch type {
        case .Pan:
            theirEmitter.emitterShape = kCAEmitterLayerPoint
        case .Tap:
            theirEmitter.emitterShape = kCAEmitterLayerCircle
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                self.theirEmitter.lifetime = 0
            })
        case .End:
            theirEmitter.lifetime = 0
        }
    }
    
    @IBAction func connect(sender: UIBarButtonItem) {
        if meshNetwork.connectedPeers.count == 0 {
            meshNetwork.joinMesh()
        } else {
            meshNetwork.leaveMesh()
        }
    }
}