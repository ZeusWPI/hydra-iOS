//
//  InitialOnboardingViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 12/09/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

class InitialOnboardingViewController: UIViewController {

    @IBAction func skip() {
        #if RELEASE
            PreferencesService.sharedService.firstLaunch = false
        #endif
        let vc = UIStoryboard(name: "MainStoryboard", bundle: nil).instantiateInitialViewController()!
        UIApplication.sharedApplication().windows[0].rootViewController = vc
    }
}