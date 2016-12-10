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
    func meshNetwork(_ meshNetwork: MeshNetwork, peer: MCPeerID, changedState state: MCSessionState, currentPeers: [AnyObject])
    func meshNetwork(_ meshNetwork: MeshNetwork, failedToJoinMesh error: Error)
    
    // Optional
    @objc optional func meshNetwork(_ meshNetwork: MeshNetwork, didReceiveData data: Data, fromPeer peerdID: MCPeerID)
    @objc optional func meshNetwork(_ meshNetowrk: MeshNetwork, didReceiveStream stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID)
    @objc optional func meshNetwork(_ meshNetwork: MeshNetwork, didStartReceivingResourceWithName resourceName: NSString, fromPeer peerID: MCPeerID, withProgress progress: Progress)
    @objc optional func meshNetwork(_ meshNetwork: MeshNetwork,  didFinishReceivingResourceWithName resourceName: NSString, fromPeer peerID: MCPeerID, atURL localURL: URL, withError error: NSError)
}

final class MeshNetwork: NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    
    var delegate: MeshNetworkDelegate!

    private var connected = false
    private var acceptingPeers = false
    private let serviceType: String
    private let displayName: String
    private var _session: MCSession!
    private var _peerID: MCPeerID!
    private var _serviceAdvertiser: MCNearbyServiceAdvertiser!
    private var _serviceBrowser: MCNearbyServiceBrowser!
    
    // MARK: - Life Cycle
    
    init(serviceType: String = "Dust-Service", displayName: String = UIDevice.current.name) {
        self.serviceType = serviceType
        self.displayName = displayName
        super.init()
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
    
    // MARK: - Communication
    func sendData(_ data: Data, peerIDs: [MCPeerID], mode: MCSessionSendDataMode) {
        do {
            try session.send(data, toPeers: peerIDs, with: .reliable)
        } catch {
            debugPrint(error)
        }
    }

    func startStreamWith(_ name: String!, peerID: MCPeerID!, error: NSErrorPointer!) -> OutputStream {
        return try! self.session.startStream(withName: name, toPeer: peerID)
    }
    
    func sendResourceAtURL(_ resourceURL: URL, resourceName: String, peerID: MCPeerID, completionHandler: ((NSError?) -> Void)!) -> Progress {
        return self.session.sendResource(at: resourceURL, withName: resourceName, toPeer: peerID, withCompletionHandler: completionHandler as! ((Error?) -> Void)?)!
    }
    
    // MARK: - Properties
    var connectedPeers: [MCPeerID] {
        return self.session.connectedPeers
    }
    
    var session: MCSession! {
        _session = _session ?? MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: .none)
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
    
    // MARK: - Session Delegate
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async(execute: { () -> Void in
            self.delegate.meshNetwork(self, peer: peerID, changedState: state, currentPeers: self.session.connectedPeers)
        })
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async(execute: { () -> Void in
            self.delegate.meshNetwork!(self, didReceiveData: data, fromPeer: peerID)
        })
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async(execute: { () -> Void in
            self.delegate.meshNetwork!(self, didReceiveStream: stream, withName: streamName, fromPeer: peerID)
        })

    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        DispatchQueue.main.async(execute: { () -> Void in
            self.delegate.meshNetwork!(self, didStartReceivingResourceWithName: resourceName as NSString, fromPeer: peerID, withProgress: progress)
        })
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        DispatchQueue.main.async(execute: { () -> Void in
            self.delegate.meshNetwork!(self, didFinishReceivingResourceWithName: resourceName as NSString, fromPeer: peerID, atURL: localURL, withError: error as! NSError)
        })
    }

    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }

    // MARK: - Advertiser Delegate
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        if (peerID.displayName < self.peerID.displayName) {
            invitationHandler(true, self.session)
        }
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        self.delegate.meshNetwork(self, failedToJoinMesh: error)

    }

    // MARK: - Browser Delegate
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if peerID.displayName > self.peerID.displayName {
            serviceBrowser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        delegate.meshNetwork(self, failedToJoinMesh: error)

    }
}
