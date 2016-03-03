//
//  FacebookSession.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 03/03/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit

class FacebookSession: NSObject {

    var sharedSession = FacebookSession()

    override init() {

    }

    var open: Bool = false
    var userInfo: AnyObject?

    func openWithAllowLoginUI(allowLoginUI: Bool, completion: (()->Void)? = nil) {
        if FBSDKAccessToken.currentAccessToken() != nil {
            return
        }
        let login = FBSDKLoginManager()
        login.logInWithReadPermissions(["public_profile", "user_friends"]) { (result, error) -> Void in
            if result.declinedPermissions.contains("public_profile") {
                // HANDLE DECLINED SHIT
            } else {
                // HANDLE WINNING
            }
        }
    }

    func close() {

    }

    private func updateUserInfo() {
        if FBSDKAccessToken.currentAccessToken() != nil {

        }
    }

    func requestWithGraphPath(path: String, parameters: [NSObject: AnyObject], HTTPMethod: String = "GET" ) {
        if FBSDKAccessToken.currentAccessToken() == nil {
            //TODO: add fb app token parameters["access_token"] =
        }

        FBSDKGraphRequest(graphPath: path, parameters: parameters, HTTPMethod: HTTPMethod).startWithCompletionHandler { (connection, obj, err) -> Void in
            if let error = err {
                //TODO: handle error
                print("An error occured")
            }
            print(obj)
        }

    }
}