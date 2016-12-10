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
    case pan, tap, end
}

enum DustColors: Int {
    case red, orange, yellow, green, blue, violet
    
    var uiColor: UIColor {
        switch (self) {
        case .red: return UIColor(red: 0.898, green: 0.302, blue: 0.259, alpha: 1.0)
        case .orange: return UIColor(red: 0.894, green: 0.494, blue: 0.188, alpha: 1.0)
        case .yellow: return UIColor(red: 0.941, green: 0.880, blue: 0.336, alpha: 1.0)
        case .green: return UIColor(red: 0.224, green: 0.792, blue: 0.455, alpha: 1.0)
        case .blue: return UIColor(red: 0.227, green: 0.600, blue: 0.847, alpha: 1.0)
        case .violet: return UIColor(red: 0.604, green: 0.361, blue: 0.706, alpha: 1.0)
        }
    }
    
    static var colors: [DustColors] {
        return [.red, .orange, .yellow, .green, .blue, .violet]
    }
}

struct DustMessage {
    var percentX: Float
    var percentY: Float
    var gestureType: GestureType
    var color: DustColors
}

extension Data {
    init<T>(from value: T) {
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.pointee }
    }
}

final class ViewController: UIViewController, UIGestureRecognizerDelegate, MeshNetworkDelegate  {
    
    private var myEmitter: CAEmitterLayer!
    private var theirEmitter: CAEmitterLayer!
    
    private let meshNetwork = MeshNetwork(serviceType: "Dust-Service")
    
    private var peersOutputStreams: Dictionary<String, OutputStream>! = Dictionary<String, OutputStream>()
    
    @IBOutlet weak var connectionButton: UIBarButtonItem!
    @IBOutlet weak var connectedPeerCount: UIBarButtonItem!
    @IBOutlet weak var colorSegmentControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.067, green: 0.067, blue: 0.067, alpha: 1.0)
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
        
        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.handlePanGesture(_:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTapGesture(_:)))
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.numberOfTapsRequired = 2
        tapGesture.delegate = self
        
        view.addGestureRecognizer(panGesture)
        view.addGestureRecognizer(tapGesture)
        
        meshNetwork.delegate = self
        meshNetwork.joinMesh()

        connectionButton.tintColor = DustColors(rawValue: colorSegmentControl.selectedSegmentIndex)?.uiColor
        connectedPeerCount.tintColor = DustColors(rawValue: colorSegmentControl.selectedSegmentIndex)?.uiColor
        colorSegmentControl.tintColor = DustColors(rawValue: colorSegmentControl.selectedSegmentIndex)?.uiColor
        
        let emitterColor = DustColors(rawValue: colorSegmentControl.selectedSegmentIndex)?.uiColor
        myEmitter = CAEmitterLayer(emitterColor: emitterColor)
        view.layer.addSublayer(myEmitter)
        
        theirEmitter = CAEmitterLayer(emitterColor: emitterColor)
        view.layer.addSublayer(theirEmitter)
    }
    
    @IBAction func selectColor(_ sender: UISegmentedControl) {
        connectionButton.tintColor = DustColors(rawValue: colorSegmentControl.selectedSegmentIndex)?.uiColor
        connectedPeerCount.tintColor = DustColors(rawValue: colorSegmentControl.selectedSegmentIndex)?.uiColor
        colorSegmentControl.tintColor = DustColors(rawValue: colorSegmentControl.selectedSegmentIndex)?.uiColor
        myEmitter.setValue(DustColors(rawValue: colorSegmentControl.selectedSegmentIndex)?.uiColor.cgColor, forKeyPath: "emitterCells.dustCell.color")
    }

    func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        let point = gestureRecognizer.location(in: self.view)
        myEmitter.lifetime = (gestureRecognizer.state == .ended) ? 0 : 1
        myEmitter.emitterPosition = point
        myEmitter.emitterShape = kCAEmitterLayerPoint
        
        switch gestureRecognizer.state {
        case .began, .changed: sendDataMessage(point, gestureType: .pan)
        case .ended: sendDataMessage(point, gestureType: .end)
        default: return
        }
    }
    
    func handleTapGesture(_ gestureRecoginzer: UITapGestureRecognizer) {
        let point = gestureRecoginzer.location(in: self.view)
        myEmitter.lifetime = 1
        myEmitter.emitterPosition = point
        myEmitter.emitterShape = kCAEmitterLayerCircle
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.myEmitter.lifetime = 0
        })
        sendDataMessage(point, gestureType: .tap)
    }
    
    func sendDataMessage(_ point: CGPoint, gestureType: GestureType) {
        
        
        let message = DustMessage(percentX: Float(point.x/view.bounds.width),
                                  percentY: Float(point.y/view.bounds.height),
                                  gestureType: gestureType,
                                  color: DustColors(rawValue: colorSegmentControl.selectedSegmentIndex)!)
        
        meshNetwork.sendData(Data(from: message), peerIDs: meshNetwork.connectedPeers, mode: .unreliable)
    }

    // MARK: Mesh Network Delegate
    func meshNetwork(_ meshNetwork: MeshNetwork, peer peerID: MCPeerID, changedState state: MCSessionState, currentPeers: [AnyObject]) {
        switch state {
        case .notConnected:
            PKHUD.sharedHUD.contentView = PKHUDSquareBaseView.init(image: PKHUDAssets.crossImage, title: "Disconnected", subtitle: peerID.displayName)
        case .connected:
            PKHUD.sharedHUD.contentView = PKHUDSquareBaseView.init(image: PKHUDAssets.checkmarkImage, title: "Connected", subtitle: peerID.displayName)
        case .connecting:
            PKHUD.sharedHUD.contentView = PKHUDSquareBaseView.init(image: PKHUDAssets.checkmarkImage, title: "Connecting", subtitle: peerID.displayName)
        }
        PKHUD.sharedHUD.show()
        PKHUD.sharedHUD.hide(afterDelay: 4.0)
        connectionButton.image = UIImage(named: currentPeers.count >  0 ? "connect" : "disconnect")
        connectedPeerCount.title = "\(currentPeers.count)"
    }
    
    func meshNetwork(_ meshNetwork: MeshNetwork, failedToJoinMesh error: Error) {
        PKHUD.sharedHUD.contentView = PKHUDSquareBaseView.init(image: PKHUDAssets.crossImage, title: "Error", subtitle: nil)
        PKHUD.sharedHUD.show()
        PKHUD.sharedHUD.hide(afterDelay: 4.0)
    }
    
    func meshNetwork(_ meshNetwork: MeshNetwork, didReceiveData data: Data, fromPeer peerdID: MCPeerID) {

        
        let message = data.to(type: DustMessage.self)
        

        let x = CGFloat(message.percentX * Float(view.bounds.width))
        let y = CGFloat(message.percentY * Float(view.bounds.height))
        theirEmitter.setValue(message.color.uiColor.cgColor, forKeyPath: "emitterCells.dustCell.color")
        theirEmitter.lifetime = 1
        theirEmitter.emitterPosition = CGPoint(x: x, y: y)
        switch message.gestureType {
        case .pan:
            theirEmitter.emitterShape = kCAEmitterLayerPoint
        case .tap:
            theirEmitter.emitterShape = kCAEmitterLayerCircle
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                self.theirEmitter.lifetime = 0
            })
        case .end:
            theirEmitter.lifetime = 0
        }
    }
    
    @IBAction func connect(_ sender: UIBarButtonItem) {
        if meshNetwork.connectedPeers.count == 0 {
            meshNetwork.joinMesh()
        } else {
            meshNetwork.leaveMesh()
        }
    }
}
