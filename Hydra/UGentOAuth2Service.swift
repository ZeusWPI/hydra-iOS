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
    
    static let sharedService = UGentOAuth2Service()
    
    let oauth2: OAuth2CodeGrant

    private override init() {
        let path = NSBundle.mainBundle().pathForResource("UGentOAuthConfig", ofType: "plist")
        let UGentOAuth2 = NSDictionary(contentsOfFile: path!)?.valueForKey("UGentOAuth2")
        let settings: OAuth2JSON =  [
            "client_id": (UGentOAuth2!.valueForKey("ClientID") as? String)!,
            "client_secret": (UGentOAuth2!.valueForKey("ClientSecret") as? String)!,
            "authorize_uri": APIConfig.OAuth + "authorize",
            "token_uri": APIConfig.OAuth + "access_token",
            "redirect_uris": ["https://zeus.UGent.be/hydra/oauth/callback", "hydra-ugent://oauth/zeus/callback"],
            "title": "UGent Authentication"
        ]
        
        oauth2 = OAuth2CodeGrant(settings: settings)
        super.init()
        
        oauth2.verbose = true
        oauth2.onAuthorize = { parameters in
            MinervaStore.sharedStore.updateUser(true)
            NSNotificationCenter.defaultCenter().postNotificationName(UGentOAuth2ServiceDidUpdateUserNotification, object: self)
        }
        oauth2.onFailure = { error in
            if let error = error {
                //TODO: do something
                print("Authorization went wrong: \(error)")
            }
        }
    }

    func handleRedirectURL(redirect: NSURL) {
        self.oauth2.handleRedirectURL(redirect)
    }

    func isAuthenticated() -> Bool{
        return oauth2.accessToken != nil
    }

    func logoff() {
        oauth2.forgetTokens()
        MinervaStore.sharedStore.logoff()

    }
}
