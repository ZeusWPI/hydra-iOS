//
//  UIViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 31/03/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation
import FirebaseAnalytics

extension UIViewController {

    func GAI_track(title: String) {
        FIRAnalytics.logEventWithName("screen", parameters: ["screenName": title])
        
    }
}