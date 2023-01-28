//
//  NewsItemData.swift
//  Hydra iOS
//
//  Created by Jan Lecoutere on 25/10/2022.
//

import Foundation

struct UgentNewsItem: Decodable, Identifiable {
    let id: String
    let link: String
    let published: Date
    let summary: String
    let title: String
    var orgPath: String? = "logo-ugent-en"
    
    private enum CodingKeys: String, CodingKey {
        case id, link, published, summary, title
    }
}