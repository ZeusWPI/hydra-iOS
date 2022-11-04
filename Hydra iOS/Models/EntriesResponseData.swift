//
//  EntriesResponse.swift
//  Hydra iOS
//
//  Created by Jan Lecoutere on 26/10/2022.
//

import Foundation

struct EntriesResponseData<T: Decodable>: Decodable {
    let entries: [T]?
}
