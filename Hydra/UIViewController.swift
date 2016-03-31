//
//  UIViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 31/03/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

extension UIViewController {

    func GAI_track(title: String) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: title)

        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
}