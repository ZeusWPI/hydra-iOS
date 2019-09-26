//
//  ApplicationWithRemoteSupport.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 11/06/2017.
//  Copyright © 2017 Zeus WPI. All rights reserved.
//

import Foundation

class ApplicationWithRemoteSupport: UIApplication {
    
    override init() {
        super.init()
        self.becomeFirstResponder()
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        
    }
}
