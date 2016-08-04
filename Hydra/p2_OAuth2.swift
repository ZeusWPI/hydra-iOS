//
//  p2_OAut2.swift
//  OAuthTest
//
//  Created by Feliciaan De Palmenaer on 23/02/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Alamofire
import p2_OAuth2

extension OAuth2 {
    public func request(
        method: Alamofire.Method,
        _ URLString: URLStringConvertible,
        parameters: [String: AnyObject]? = nil,
        encoding: Alamofire.ParameterEncoding = .URL,
        headers: [String: String]? = [String: String]())
        -> Alamofire.Request
    {
        var hdrs = headers
        if let accessToken = accessToken {
            hdrs!["Authorization"] = "Bearer \(accessToken)"
            #if DEBUG
                print("Token \(accessToken)")
            #endif
        }
        return Alamofire.request(
            method,
            URLString,
            parameters: parameters,
            encoding: encoding,
            headers: hdrs)
    }

}