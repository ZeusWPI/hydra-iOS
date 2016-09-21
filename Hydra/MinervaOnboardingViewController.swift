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
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: #selector(MinervaOnboardingViewController.updateState), name: UGentOAuth2ServiceDidUpdateUserNotification, object: nil)
        center.addObserver(self, selector: #selector(MinervaOnboardingViewController.updateState), name: MinervaStoreDidUpdateUserNotification, object: nil)
        updateState()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBarHidden = true
    }

    @IBAction func login() {
        let oauthService = UGentOAuth2Service.sharedService
        let oauth2 = oauthService.oauth2
        if oauth2.accessToken == nil {
            oauth2.authConfig.authorizeEmbedded = true
            oauth2.authConfig.authorizeContext = self
            oauth2.authorize()
        }
    }

    @IBAction func showCourses() {
        if UGentOAuth2Service.sharedService.isAuthenticated() {
            self.navigationController?.pushViewController(MinervaCoursePreferenceViewController(), animated: true)
        }
    }

    func updateState() {
        loadCoursesButton?.enabled = UGentOAuth2Service.sharedService.isAuthenticated()
        if UGentOAuth2Service.sharedService.isAuthenticated() {
            if let user = MinervaStore.sharedStore.user {
                loginButton?.setTitle("Welkom \(user.name)", forState: .Normal)
            } else {
                loginButton?.setTitle("Ingelogd op Minerva", forState: .Normal)
            }
            nextButton?.setTitle("Volgende", forState: .Normal)
        }

    }
}