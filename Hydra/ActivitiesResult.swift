//
//  ActivitiesResult.swift
//  Hydra
//
//  Created by Ieben Smessaert on 13/09/2020.
//  Copyright © 2020 Zeus WPI. All rights reserved.
//

import Foundation

struct ActivitiesResult: Codable {
    var page: ActivityPage
    
    private enum CodingKeys: String, CodingKey {
        case page
    }
}
