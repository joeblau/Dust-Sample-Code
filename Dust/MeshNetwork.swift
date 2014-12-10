//
//  MeshNetwork.swift
//  Dust
//
//  Created by Joe Blau on 11/26/14.
//  Copyright (c) 2014 joeblau. All rights reserved.
//

import MultipeerConnectivity

// Added @objc in order to support optional protocol methods
@objc protocol MeshNetworkDelegate {
    // Required
    func meshNetwork(meshNetwork: MeshNetwork, peer: MCPeerID, changedState state: MCSessionState, currentPeers: [AnyObject])
    func meshNetwork(meshNetwork: MeshNetwork, failedToJoinMesh error: NSError)
    
    // Optional
    optional func meshNetwork(meshNetwork: MeshNetwork, didReceiveData data: NSData, fromPeer peerdID: MCPeerID)
    optional func meshNetwork(meshNetowrk: MeshNetwork, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID)
    optional func meshNetwork(meshNetwork: MeshNetwork, didStartReceivingResourceWithName resourceName: NSString, fromPeer peerID: MCPeerID, withProgress progress: NSProgress)
    optional func meshNetwork(meshNetwork: MeshNetwork,  didFinishReceivingResourceWithName resourceName: NSString, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError)
}

class MeshNetwork: NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    
    var connected: Bool = false
    var acceptingPeers: Bool = false
    var serviceType: String = "Dust-Service"
    var displayName: String = UIDevice.currentDevice().name
    
    var delegate: MeshNetworkDelegate!
    
    var _session: MCSession!
    var _peerID: MCPeerID!
    var _serviceAdvertiser: MCNearbyServiceAdvertiser!
    var _serviceBrowser: MCNearbyServiceBrowser!
    
    // MARK: Life Cycle
    init(serviceType: String, displayName: String = UIDevice.currentDevice().name) {
        super.init()
        self.serviceType = serviceType
        self.displayName = displayName
    }
    
    func joinMesh() {
        if !acceptingPeers {
            serviceAdvertiser.startAdvertisingPeer()
            serviceBrowser.startBrowsingForPeers()
            (connected, acceptingPeers) = (true, true)
        }
    }
    
    func stopAcceptingPeers() {
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
        acceptingPeers = false
    }
    
    func leaveMesh() {
        stopAcceptingPeers()
        session.disconnect()
    }
    
    // MARK: communication
    func sendData(data: NSData, mode: MCSessionSendDataMode, error: NSErrorPointer) -> Bool {
        return session.sendData(data, toPeers: session.connectedPeers, withMode: mode, error: error)
    }
    
    func sendData(data: NSData, peerIDs: [AnyObject], mode: MCSessionSendDataMode, error: NSErrorPointer) -> Bool {
        return session.sendData(data, toPeers: peerIDs, withMode: mode, error: error)
    }
    
    func startStreamWith(name: String!, peerID: MCPeerID!, error: NSErrorPointer!) -> NSOutputStream {
        return self.session.startStreamWithName(name, toPeer: peerID, error: error)
    }
    
    func sendResourceAtURL(resourceURL: NSURL, resourceName: String, peerID: MCPeerID, completionHandler: ((NSError!) -> Void)!) -> NSProgress {
        return self.session.sendResourceAtURL(resourceURL, withName: resourceName, toPeer: peerID, withCompletionHandler: completionHandler)
    }
    
    // MARK: Properies
    var connectedPeers: [AnyObject]! {
        return self.session.connectedPeers
    }
    
    var session: MCSession! {
        _session = _session ?? MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: .None)
        _session.delegate = _session.delegate ?? self
        return _session
    }
    
    var peerID: MCPeerID! {
        _peerID = _peerID ?? MCPeerID(displayName: self.displayName)
        return _peerID
    }
    var serviceAdvertiser: MCNearbyServiceAdvertiser! {
        _serviceAdvertiser = _serviceAdvertiser ?? MCNearbyServiceAdvertiser(peer: self.peerID, discoveryInfo: nil, serviceType: self.serviceType)
        _serviceAdvertiser.delegate = _serviceAdvertiser.delegate ?? self
        return _serviceAdvertiser
    }
    
    var serviceBrowser: MCNearbyServiceBrowser! {
        _serviceBrowser = _serviceBrowser ?? MCNearbyServiceBrowser(peer: self.peerID, serviceType: self.serviceType)
        _serviceBrowser.delegate =  _serviceBrowser.delegate ?? self
        return _serviceBrowser
    }
    
    // MARK: Session Delegate
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.delegate.meshNetwork(self, peer: peerID, changedState: state, currentPeers: self.session.connectedPeers)
        })
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.delegate.meshNetwork!(self, didReceiveData: data, fromPeer: peerID)
        })
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.delegate.meshNetwork!(self, didReceiveStream: stream, withName: streamName, fromPeer: peerID)
        })
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.delegate.meshNetwork!(self, didStartReceivingResourceWithName: resourceName, fromPeer: peerID, withProgress: progress)
        })
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.delegate.meshNetwork!(self, didFinishReceivingResourceWithName: resourceName, fromPeer: peerID, atURL: localURL, withError: error)
        })
    }
    
    func session(session: MCSession!, didReceiveCertificate certificate: [AnyObject]!, fromPeer peerID: MCPeerID!, certificateHandler: ((Bool) -> Void)!) {
        certificateHandler(true)
    }
    
    // MARK: Advertiser Delegate
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
        if (peerID.displayName < self.peerID.displayName) {
            invitationHandler(true, self.session)
        }
    }

    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didNotStartAdvertisingPeer error: NSError!) {
        self.delegate.meshNetwork(self, failedToJoinMesh: error)
    }
    
    // MARK: Browser Delegate
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        if peerID.displayName > self.peerID.displayName {
            serviceBrowser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 10)
        }
    }
    
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {}
    
    func browser(browser: MCNearbyServiceBrowser!, didNotStartBrowsingForPeers error: NSError!) {
        delegate.meshNetwork(self, failedToJoinMesh: error)
    }
}
