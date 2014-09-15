//
//  ViewController.swift
//  Dust
//
//  Created by Joe Blau on 9/12/14.
//  Copyright (c) 2014 joeblau. All rights reserved.
//

import UIKit
import MultipeerConnectivity

enum GestureType {
  case Pan, Tap
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

class ViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate, UIGestureRecognizerDelegate, MCAdvertiserAssistantDelegate, NSStreamDelegate {
  var session: MCSession!
  var myEmitter: CAEmitterLayer!
  var theirEmitter: CAEmitterLayer!
  var outputStream: NSOutputStream!
  var advertiserAssistant: MCAdvertiserAssistant!
  var browserViewController: MCBrowserViewController!
  var localPeerID: MCPeerID! = MCPeerID(displayName: UIDevice.currentDevice().name)
  
  let dustServiceType: String! = "dust-service"
  
  @IBOutlet var searchButton: UIBarButtonItem!
  @IBOutlet var connectionButton: UIBarButtonItem!
  @IBOutlet var colorSegmentControl: UISegmentedControl!

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.blackColor()
    let panGesture = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
    panGesture.minimumNumberOfTouches = 1
    panGesture.delegate = self
    
    let tapGesture = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
    tapGesture.numberOfTouchesRequired = 1
    tapGesture.numberOfTapsRequired = 2
    tapGesture.delegate = self
    
    view.addGestureRecognizer(panGesture)
    view.addGestureRecognizer(tapGesture)
    
    // Create the session that peers will be invited/join into.
    session = MCSession(peer: self.localPeerID, securityIdentity: nil, encryptionPreference: .None)
    session.delegate = self
    
    browserViewController = MCBrowserViewController(serviceType: dustServiceType, session: session)
    browserViewController.delegate = self
    
    advertiserAssistant = MCAdvertiserAssistant(serviceType: dustServiceType, discoveryInfo: nil, session: session)
    advertiserAssistant.delegate = self
    advertiserAssistant.start()
    
    searchButton.tintColor = DustColors.fromRaw(colorSegmentControl.selectedSegmentIndex)?.get()
    connectionButton.tintColor = DustColors.fromRaw(colorSegmentControl.selectedSegmentIndex)?.get()
    colorSegmentControl.tintColor = DustColors.fromRaw(colorSegmentControl.selectedSegmentIndex)?.get()

    myEmitter = createEmmitter()
    theirEmitter = createEmmitter()
  }
  
  func createEmmitter() -> CAEmitterLayer {
    var newEmitterLayer = CAEmitterLayer()
    newEmitterLayer.emitterPosition = CGPointMake(-100,-100)
    newEmitterLayer.emitterSize = CGSizeMake(60.0,1)
    newEmitterLayer.emitterMode = kCAEmitterLayerOutline
    newEmitterLayer.emitterShape = kCAEmitterLayerPoint
    newEmitterLayer.renderMode = kCAEmitterLayerAdditive
    newEmitterLayer.shadowOpacity = 0.0
    newEmitterLayer.shadowRadius = 0.0
    newEmitterLayer.shadowOffset = CGSizeMake(0,0)
    newEmitterLayer.shadowColor = UIColor.whiteColor().CGColor

    var newEmitterCell = CAEmitterCell()
    newEmitterCell.name = "dustCell"
    newEmitterCell.birthRate = 1000
    newEmitterCell.lifetime = 6.0
    newEmitterCell.lifetimeRange = 0.5
    newEmitterCell.color = DustColors.fromRaw(colorSegmentControl.selectedSegmentIndex)?.get().CGColor
    newEmitterCell.redSpeed = 0.000
    newEmitterCell.greenSpeed = 0.000
    newEmitterCell.blueSpeed = 0.000
    newEmitterCell.alphaSpeed = 0.000
    newEmitterCell.redRange = 0.581
    newEmitterCell.greenRange = 0.000
    newEmitterCell.blueRange = 0.000
    newEmitterCell.alphaRange = 0.000
    newEmitterCell.contents = UIImage(named: "particle").CGImage
    newEmitterCell.emissionRange = CGFloat(2.000*M_PI)
    newEmitterCell.emissionLatitude = CGFloat(0.000*M_PI)
    newEmitterCell.emissionLongitude = CGFloat(0.000*M_PI)
    newEmitterCell.velocity = 1
    newEmitterCell.velocityRange = 1
    newEmitterCell.xAcceleration = 0
    newEmitterCell.yAcceleration = 0
    newEmitterCell.spin = CGFloat(0.0*M_PI)
    newEmitterCell.spinRange = CGFloat(0.01*M_PI)
    newEmitterCell.scale = 3.0/UIScreen.mainScreen().scale
    newEmitterCell.scaleSpeed = 0.0
    newEmitterCell.scaleRange = 5.0
    
    newEmitterLayer.emitterCells = [newEmitterCell]
    view.layer.addSublayer(newEmitterLayer)
    return newEmitterLayer
  }
  
  @IBAction func selectColor(sender: UISegmentedControl) {
    searchButton.tintColor = DustColors.fromRaw(colorSegmentControl.selectedSegmentIndex)?.get()
    connectionButton.tintColor = DustColors.fromRaw(colorSegmentControl.selectedSegmentIndex)?.get()
    colorSegmentControl.tintColor = DustColors.fromRaw(colorSegmentControl.selectedSegmentIndex)?.get()
    myEmitter.setValue(DustColors.fromRaw(colorSegmentControl.selectedSegmentIndex)?.get().CGColor, forKeyPath: "emitterCells.dustCell.color")
    
    if session.connectedPeers.count == 0 { return }
    sendDataColor()
  }
  
  @IBAction func searchPeers(sender: UIBarButtonItem) {
    presentViewController(browserViewController, animated: true, completion: nil)
  }
  
  // MCNearbyServiceAdvertiserDelegate Methods
  func handlePanGesture(gestureRecognizer: UIPanGestureRecognizer) {
    let point = gestureRecognizer.locationInView(self.view)
    
    myEmitter.emitterPosition = (gestureRecognizer.state == .Ended) ?CGPointMake(-100,-100):point
    myEmitter.emitterShape = kCAEmitterLayerPoint
    
    if session.connectedPeers.count == 0 { return }
    switch gestureRecognizer.state {
    case .Began:
      var start = true
      var sendData = NSData(bytes: &start, length:  sizeof(Bool))
      outputStream.write(UnsafePointer<UInt8>(sendData.bytes), maxLength: sendData.length)
    case .Changed:
      self.sendDataMessage(point, gestureType: .Pan)
    case .Ended:
      var start = false
      var sendData = NSData(bytes: &start, length:  sizeof(Bool))
      outputStream.write(UnsafePointer<UInt8>(sendData.bytes), maxLength: sendData.length)
    default: return
    }
  }
  
  func handleTapGesture(gestureRecoginzer: UITapGestureRecognizer) {
    let point = gestureRecoginzer.locationInView(self.view)

    myEmitter.emitterPosition = point
    myEmitter.emitterShape = kCAEmitterLayerCircle

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
      self.myEmitter.emitterPosition = CGPointMake(-100,-100)
    })
    
    if session.connectedPeers.count == 0 { return }
    self.sendDataMessage(point, gestureType: .Tap)
  }
  
  func sendDataMessage(point: CGPoint, gestureType: GestureType) {
    var sendData = NSMutableData()
    var percentX = Float(point.x/view.bounds.width)
    var percentY = Float(point.y/view.bounds.height)
    var type = gestureType

    sendData.appendBytes(&percentX, length: sizeof(Float))
    sendData.appendBytes(&percentY, length: sizeof(Float))
    sendData.appendBytes(&type, length: sizeof(GestureType))
    
    if session.connectedPeers.count == 0 { return }
    outputStream.write(UnsafePointer<UInt8>(sendData.bytes), maxLength: sendData.length)
  }
  
  func sendDataColor() {
    var sendData = NSMutableData()
    var color: DustColors = DustColors.fromRaw(colorSegmentControl.selectedSegmentIndex)!
    sendData.appendBytes(&color, length: 2)
    outputStream.write(UnsafePointer<UInt8>(sendData.bytes), maxLength: sendData.length)
  }
  
  // MCSessionDelegate Methods
  func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {}
  
  func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {}
  
  func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {}
  
  func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
    stream.delegate = self;
    stream.scheduleInRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    stream.open()
  }
  
  func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
    switch state {
    case .Connected:
      connectionButton.image = UIImage(named: "connect")
      outputStream = session.startStreamWithName("dust-stream", toPeer: peerID, error: nil)
      outputStream.delegate = self;
      outputStream.scheduleInRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
      outputStream.open()
      sendDataColor()
    case MCSessionState.Connecting:
      connectionButton.image = UIImage(named: "disconnect")
    case MCSessionState.NotConnected:
      connectionButton.image = UIImage(named: "disconnect")
      if outputStream != nil { outputStream.close() }
      session.disconnect()
    }
  }
  
  func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
    switch eventCode {
    case NSStreamEvent.EndEncountered:
      aStream.close()
    case NSStreamEvent.HasBytesAvailable:
      if aStream.isKindOfClass(NSInputStream) {
        var inputStream = aStream as NSInputStream
        
        var buffer = [UInt8](count: 9, repeatedValue: 0)
        let result: Int = inputStream.read(&buffer, maxLength: buffer.count)
        
        switch result {
        case 9:
          var data = NSData(bytes: buffer, length: result)
          var (percentX, percentY, type) = (Float(), Float(), GestureType.Pan)
          data.getBytes(&percentX, range: NSMakeRange(0, 4))
          data.getBytes(&percentY, range: NSMakeRange(4, 4))
          data.getBytes(&type, range: NSMakeRange(8, 1))
          
          let x = CGFloat(percentX * Float(view.bounds.width))
          let y = CGFloat(percentY * Float(view.bounds.height))
          
          switch type {
          case GestureType.Pan:
            theirEmitter.emitterShape = kCAEmitterLayerPoint
          case GestureType.Tap:
            theirEmitter.emitterShape = kCAEmitterLayerCircle
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
              self.theirEmitter.emitterPosition = CGPointMake(-100,-100)
            })
          }
          theirEmitter.emitterPosition = CGPointMake(x, y)
        case 2:
          var data = NSData(bytes: buffer, length: result)
          var color: DustColors = DustColors.Red
          data.getBytes(&color, length: 2)
          theirEmitter.setValue(color.get().CGColor, forKeyPath: "emitterCells.dustCell.color")
        case 1:
          var data = NSData(bytes: buffer, length: result)
          var start: Bool = Bool()
          data.getBytes(&start, length: 1)
          theirEmitter.emitterPosition = CGPointMake(-100,-100)
        default: return
        }
      }
    default: return
    }
  }
  
  // MCBrowserViewControllerDelegate Methods
  func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
    browserViewController.dismissViewControllerAnimated(true, completion: { () -> Void in
      self.connectionButton.image = UIImage(named: self.session.connectedPeers.count >  0 ?"connect":"disconnect")
    })
  }
  
  func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
    browserViewController.dismissViewControllerAnimated(true, completion: { () -> Void in
      self.connectionButton.image = UIImage(named: self.session.connectedPeers.count >  0 ?"connect":"disconnect")
    })
  }
  
  // MCAdvertiserAssistantDelegate Methods
  func advertiserAssistantDidDismissInvitation(advertiserAssistant: MCAdvertiserAssistant!) {
    self.connectionButton.image = UIImage(named: self.session.connectedPeers.count >  0 ?"connect":"disconnect")
  }
  
  func advertiserAssistantWillPresentInvitation(advertiserAssistant: MCAdvertiserAssistant!) {
    self.connectionButton.image = UIImage(named: self.session.connectedPeers.count >  0 ?"connect":"disconnect")
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
}