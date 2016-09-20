//
//  InitialOnboardingViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 12/09/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

class InitialOnboardingViewController: UIViewController {

    @IBOutlet weak var skoView: UIView?

    @IBAction func openSKOClicked() {
        let vc = UIStoryboard(name: "sko", bundle: nil).instantiateInitialViewController()!
        UIApplication.sharedApplication().windows[0].rootViewController = vc
    }

    @IBAction func skip() {
        #if RELEASE
            PreferencesService.sharedService.firstLaunch = false
        #endif
        let vc = UIStoryboard(name: "MainStoryboard", bundle: nil).instantiateInitialViewController()!
        UIApplication.sharedApplication().windows[0].rootViewController = vc
    }

    override func viewDidLoad() {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let skoDate = calendar?.dateWithEra(1, year: 2016, month: 9, day: 28, hour: 14, minute: 0, second: 0, nanosecond: 0)!
        if NSDate().isLaterThanDate(skoDate?.dateByAddingDays(1)) {
            skoView?.hidden = true
        }
    }
}