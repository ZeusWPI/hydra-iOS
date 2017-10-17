//
//  UIViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 31/03/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation
import FirebaseAnalytics
import Firebase

extension UIViewController {

    func GAI_track(_ title: String) {
        Analytics.logEvent("screen", parameters: ["screenName": title as NSObject])
    }
}
