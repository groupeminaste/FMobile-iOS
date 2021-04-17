//
//  DNSProxyProvider.swift
//  CustomDNS
//
//  Created by PlugN on 19/01/2020.
//  Copyright © 2020 Groupe MINASTE. All rights reserved.
//

import NetworkExtension

class DNSProxyProvider: NEDNSProxyProvider {

    override func startProxy(options:[String: Any]? = nil, completionHandler: @escaping (Error?) -> Void) {
        // Add code here to start the DNS proxy.
        completionHandler(nil)
    }

    override func stopProxy(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Add code here to stop the DNS proxy.
        completionHandler()
    }

    override func sleep(completionHandler: @escaping () -> Void) {
        // Add code here to get ready to sleep.
        completionHandler()
    }

    override func wake() {
        // Add code here to wake up.
    }

    override func handleNewFlow(_ flow: NEAppProxyFlow) -> Bool {
        // Add code here to handle the incoming flow.
        NSLog("DNSProxyProvider: handleFlow")
        if let tcpFlow = flow as? NEAppProxyTCPFlow {
            let remoteHost = (tcpFlow.remoteEndpoint as! NWHostEndpoint).hostname
            let remotePort = (tcpFlow.remoteEndpoint as! NWHostEndpoint).port
            NSLog("DNSProxyProvider TCP HOST : \(remoteHost)")
            NSLog("DNSProxyProvider TCP PORT : \(remotePort)")
        } else if let udpFlow = flow as? NEAppProxyUDPFlow {
            let localHost = (udpFlow.localEndpoint as! NWHostEndpoint).hostname
            let localPort = (udpFlow.localEndpoint as! NWHostEndpoint).port
            NSLog("DNSProxyProvider UDP HOST : \(localHost)")
            NSLog("DNSProxyProvider UDP PORT : \(localPort)")
        }
        return true
    }

}
