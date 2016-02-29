//
//  String.swift
//  OAuthTest
//
//  Created by Feliciaan De Palmenaer on 28/02/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

extension String {
    func contains(query: String) -> Bool {
        let opts: NSStringCompareOptions = [.CaseInsensitiveSearch, .DiacriticInsensitiveSearch]
        return self.rangeOfString(query, options: opts) != nil
    }
}