//
//  UGentOAuth2Service.swift
//  OAuthTest
//
//  Created by Feliciaan De Palmenaer on 09/01/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation
import p2_OAuth2
import Alamofire
import ObjectMapper
import AlamofireObjectMapper

let UGentOAuth2ServiceDidUpdateUserNotification = "UGentOAuth2ServiceDidUpdateUserNotification"

class UGentOAuth2Service: NSObject {
    
    static let sharedService: UGentOAuth2Service = UGentOAuth2Service()
    
    let oauth2: OAuth2CodeGrant
    let ugentSessionManager: SessionManager

    fileprivate override init() {
        let path = Bundle.main.path(forResource: "UGentOAuthConfig", ofType: "plist")
        let ugentOAuth2 = NSDictionary(contentsOfFile: path!)?.value(forKey: "UGentOAuth2") as! NSDictionary
        let clientId = ugentOAuth2.value(forKey: "ClientID") as! String
        let clientSecret = ugentOAuth2.value(forKey: "ClientSecret") as! String

        let settings: OAuth2JSON =  [
            "client_id": clientId,
            "client_secret": clientSecret,
            "authorize_uri": APIConfig.OAuth + "authorize",
            "token_uri": APIConfig.OAuth + "access_token",
            "redirect_uris": ["https://zeus.UGent.be/hydra/oauth/callback", "hydra-ugent://oauth/zeus/callback"],
            "title": "UGent Authentication"
        ]
        
        oauth2 = OAuth2CodeGrant(settings: settings)

        let sessionManager = SessionManager()
        let retrier = OAuth2RetryHandler(oauth2: oauth2)
        sessionManager.adapter = retrier
        sessionManager.retrier = retrier
        self.ugentSessionManager = sessionManager

        super.init()

        oauth2.verbose = true
        oauth2.onAuthorize = { parameters in
            MinervaStore.sharedStore.updateUser(true)
            PreferencesService.sharedService.userLoggedInToMinerva = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: UGentOAuth2ServiceDidUpdateUserNotification), object: self)
        }
        oauth2.onFailure = { error in
            if let error = error {
                //TODO: do something
                PreferencesService.sharedService.userLoggedInToMinerva = false
                print("Authorization went wrong: \(error)")
            }
        }
    }

    func handleRedirectURL(_ redirect: URL) {
        self.oauth2.handleRedirectURL(redirect)
    }

    func isAuthenticated() -> Bool{
        return oauth2.accessToken != nil
    }


    func isLoggedIn() -> Bool {
        if PreferencesService.sharedService.userLoggedInToMinerva {
            if oauth2.accessToken == nil {
                oauth2.authorize()
            }
            return true
        }
        return false
    }

    func logoff() {
        oauth2.forgetTokens()
        PreferencesService.sharedService.userLoggedInToMinerva = false
        MinervaStore.sharedStore.logoff()

    }
}
