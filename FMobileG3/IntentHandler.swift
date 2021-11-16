//
//  IntentHandler.swift
//  FMobileG3
//
//  Created by PlugN on 03/07/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import Intents

@available(iOS 12.0, *)
class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return CarrierIntentHandler()
    }
    
}
