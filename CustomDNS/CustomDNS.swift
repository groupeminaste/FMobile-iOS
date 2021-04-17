//
//  CustomDNS.swift
//  FMobile
//
//  Created by PlugN on 19/01/2020.
//  Copyright © 2020 Groupe MINASTE. All rights reserved.
//

import Foundation
import NetworkExtension

public class CustomDNS {
    private static let vpnDescription = "FMobile custom DNS"
    private static let vpnServerDescription = "FMobile custom DNS"

    public var manager:NETunnelProviderManager = NETunnelProviderManager()
    public var dnsEndpoint1:String = "8.8.8.8"
    public var dnsEndpoint2:String = "8.8.4.4"

    public var connected:Bool {
        get {
            return self.manager.isOnDemandEnabled
        }
        set {
            if newValue != self.connected {
                update(
                    body: {
                        self.manager.isEnabled = newValue
                        self.manager.isOnDemandEnabled = newValue

                    },
                    complete: {
                        if newValue {
                                self.manager.loadFromPreferences { (error) in
                                    if let error = error {
                                        print("Error on loading: \(error)")
                                    }
                                    do {
                                        try (self.manager.connection as? NETunnelProviderSession)?.startVPNTunnel(options: nil)
                                    } catch let err as NSError {
                                        NSLog("\(err.localizedDescription)")
                                        print("VPN ERROR : \(err.localizedDescription)")
                                        print(err.localizedFailureReason ?? "UNKNOWN")
                                        print(err.localizedRecoveryOptions ?? ["UNKNOWN"])
                                    }
                                    }
                                
                        } else {
                            (self.manager.connection as? NETunnelProviderSession)?.stopVPNTunnel()
                        }
                    }
                )
            }
        }
    }

    public func refreshManager() -> Void {
        NETunnelProviderManager.loadAllFromPreferences(completionHandler: { (managers, error) in
            if nil == error {
                if let managers = managers {
                    for manager in managers {
                        if manager.localizedDescription == CustomDNS.vpnDescription {
                            self.manager = manager
                            print("VPN ALREADY SET UP!")
                            return
                        }
                    }
                }
            }
            print("VPN NOT YET SETTED UP, SETTING UP NOW!")
            self.setPreferences()
        })
    }

    private func update(body: @escaping ()->Void, complete: @escaping ()->Void) {
        manager.loadFromPreferences { error in
            if (error != nil) {
                NSLog("Load error: \(String(describing: error?.localizedDescription))")
                return
            }
            body()
            self.manager.saveToPreferences { (error) in
                if nil != error {
                    NSLog("vpn_connect: save error \(error!)")
                    print("VPN CONNECT ERROR : \(error?.localizedDescription ?? "UNKOWN")")
                } else {
                    complete()
                }
            }
        }
    }

    private func setPreferences() {
        self.manager.localizedDescription = CustomDNS.vpnDescription
        let proto = NETunnelProviderProtocol()
        proto.providerBundleIdentifier = "fr.plugn.fmobile.DNSProxyProvider"
        proto.serverAddress = CustomDNS.vpnServerDescription
        self.manager.protocolConfiguration = proto
        let evaluationRule = NEEvaluateConnectionRule(matchDomains: DomainsTLD.tld,
                                                         andAction: NEEvaluateConnectionRuleAction.connectIfNeeded)
        evaluationRule.useDNSServers = [self.dnsEndpoint1, self.dnsEndpoint2]
        let onDemandRule = NEOnDemandRuleEvaluateConnection()
        onDemandRule.connectionRules = [evaluationRule]
        onDemandRule.interfaceTypeMatch = NEOnDemandRuleInterfaceType.any
        self.manager.onDemandRules = [onDemandRule]
        connected = true
        print("VPN OD rule set up. What now?")
    }
}
