//
//  UrgentPlayer.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 04/06/2019.
//  Copyright © 2019 Zeus WPI. All rights reserved.
//

import Foundation

class UrgentPlayer: NSObject {
    static let shared: UrgentPlayer = UrgentPlayer()
    
    var currentSong: String = ""
    var previousSong: String = ""
    var currentShow: String = ""
    
    fileprivate override init() {
        
    }
    
    func play() {
        
    }
    
    func pause() {
        
    }
    
    func stop() {
        
    }
    
    func isPlaying() -> Bool {
        return false
    }
    
    func isPaused() -> Bool {
        return true
    }
    
    func handleRemoteEvent(event: UIEvent) {
        
    }
    
}
