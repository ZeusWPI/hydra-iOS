//
//  MinervaOnboardingViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 12/09/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

class MinervaOnboardingViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton?
    @IBOutlet weak var loadCoursesButton: UIButton?
    @IBOutlet weak var nextButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(MinervaOnboardingViewController.updateState), name: NSNotification.Name(rawValue: UGentOAuth2ServiceDidUpdateUserNotification), object: nil)
        center.addObserver(self, selector: #selector(MinervaOnboardingViewController.updateState), name: NSNotification.Name(rawValue: MinervaStoreDidUpdateUserNotification), object: nil)
        updateState()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.isNavigationBarHidden = true
    }

    @IBAction func login() {
        let oauthService = UGentOAuth2Service.sharedService
        if !oauthService.isLoggedIn() {
            oauthService.login(context: self)
        }
    }

    @IBAction func showCourses() {
        if UGentOAuth2Service.sharedService.isAuthenticated() {
            self.navigationController?.pushViewController(MinervaCoursePreferenceViewController(), animated: true)
        }
    }

    @objc func updateState() {
        loadCoursesButton?.isEnabled = UGentOAuth2Service.sharedService.isAuthenticated()
        if UGentOAuth2Service.sharedService.isAuthenticated() {
            if let user = MinervaStore.shared.user {
                loginButton?.setTitle("Welkom \(user.name)", for: UIControl.State())
            } else {
                loginButton?.setTitle("Ingelogd op Minerva", for: UIControl.State())
            }
            nextButton?.setTitle("Volgende", for: UIControl.State())
        }

    }
}
