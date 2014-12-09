//
//  MeshNetwork.swift
//  Dust
//
//  Created by Joe Blau on 11/26/14.
//  Copyright (c) 2014 joeblau. All rights reserved.
//

import UIKit
import MultipeerConnectivity

// Added @objc in order to support optional protocol methods
@objc protocol MeshNetworkProtocol {
  // Required
  func meshNetwork(meshNetwork: MeshNetwork, peer peerID: MCPeerID, changedState state: MCSessionState, connectedPeers: [AnyObject])
  func meshNetwork(meshNetwork: MeshNetwork, failedToJoinParty error: NSError)
  
  // Optional
  optional func meshNetwork(meshNetwork: MeshNetwork, didReceiveData data: NSData, fromPeer peerdID: MCPeerID)
  optional func meshNetwork(meshNetowrk: MeshNetwork, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID)
  optional func meshNetwork(meshNetwork: MeshNetwork, didStartReceivingResourceWithName resourceName: NSString, fromPeer peerID: MCPeerID, withProgress progress: NSProgress)
  optional func meshNetwork(meshNetwork: MeshNetwork,  didFinishReceivingResourceWithName resourceName: NSString, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError)
}

class MeshNetwork: NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
  
  var connected: Bool!
  var acceptingPeers: Bool!
  var serviceType: String!
  var displayName: String!
  
  var delegate: MeshNetworkProtocol!
  
  // MARK: communication
  
  func sendData(data: NSData, mode: MCSessionSendDataMode, error: NSErrorPointer) -> Bool {
    if let session = self.session {
      return session.sendData(data, toPeers: session.connectedPeers, withMode: mode, error: error)
    }
    return false
  }
  
  func sendData(data: NSData, peerIDs: [AnyObject], mode: MCSessionSendDataMode, error: NSErrorPointer) -> Bool {
    if let session = self.session {
      return session.sendData(data, toPeers: peerIDs, withMode: mode, error: error)
    }
    return false
  }
  
  // MARK: Properies
  var connectedPeers: [AnyObject]? {
    return self.session?.connectedPeers
  }
  
  var session: MCSession? {
    var newSession = self.session
    if newSession == nil {
      newSession = MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: .None)
      newSession?.delegate = self
    }
    return newSession
  }
  
  var peerID: MCPeerID? {
    var newPeerID = self.peerID
    if newPeerID == nil {
      var newPeerID = MCPeerID(displayName: self.displayName)
    }
    return newPeerID
  }
  var advertiser: MCNearbyServiceAdvertiser? {
    var newAdvertiser = self.advertiser
    if newAdvertiser == nil {
      newAdvertiser = MCNearbyServiceAdvertiser(peer: self.peerID, discoveryInfo: nil, serviceType: self.serviceType)
      newAdvertiser?.delegate = self
    }
    return newAdvertiser
  }
  var browser: MCNearbyServiceBrowser? {
    var newBrowser = self.browser
    if newBrowser == nil {
      newBrowser = MCNearbyServiceBrowser(peer: self.peerID, serviceType: self.serviceType)
      newBrowser?.delegate = self
    }
    return newBrowser
  }
  
  // MARK: Session Delegate
  func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
    self.delegate.meshNetwork(self, peer: peerID, changedState: state, connectedPeers: self.session!.connectedPeers)
  }
  
  func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
    self.delegate.meshNetwork?(self, didReceiveData: data, fromPeer: peerID)
  }
  
  func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
    self.delegate.meshNetwork?(self, didReceiveStream: stream, withName: streamName, fromPeer: peerID)
  }
  
  func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
    self.delegate.meshNetwork?(self, didStartReceivingResourceWithName: resourceName, fromPeer: peerID, withProgress: progress)
  }
  
  func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
      self.delegate.meshNetwork?(self, didFinishReceivingResourceWithName: resourceName, fromPeer: peerID, atURL: localURL, withError: error)
  }
  
  func session(session: MCSession!, didReceiveCertificate certificate: [AnyObject]!, fromPeer peerID: MCPeerID!, certificateHandler: ((Bool) -> Void)!) {
    certificateHandler(true)
  }
  
  // MARK: Advertiser Delegate
  
  func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
    if (peerID.displayName < self.peerID?.displayName) {
      invitationHandler(true, self.session)
    }
  }
  
  func advertiser(advertiser: MCNearbyServiceAdvertiser!, didNotStartAdvertisingPeer error: NSError!) {
    self.delegate.meshNetwork(self, failedToJoinParty: error)
  }
  
  // MARK: Browser Delegate
  func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
    if peerID.displayName > self.peerID?.displayName {
      println("Sending invite: Self: \(self.peerID?.displayName)")
      browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 10)
    }
  }
  
  func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {}
  
  func browser(browser: MCNearbyServiceBrowser!, didNotStartBrowsingForPeers error: NSError!) {
    self.delegate.meshNetwork(self, failedToJoinParty: error)
  }
   
}
