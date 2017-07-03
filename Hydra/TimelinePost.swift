//
//  TimelinePost.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 16/09/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import ObjectMapper

class TimelinePost: NSObject, Codable {
    var title: String?
    var body: String?
    var link: String?
    var media: String?
    var date: Date?
    //TODO: var origin: Origin = .NoneOrigin
    var origin: Origin {
        get {
            return .NoneOrigin
        }
    }
    //TODO: var postType: PostType = .NoneType
    var postType: PostType {
        get {
            return .NoneType
        }
    }
    var poster: String?
    
    private enum CodingKeys: String, CodingKey {
        case title, body, link, media, date, poster
        //case origin, postType = "post_type"
    }

    enum Origin: String {
        case Facebook = "facebook"
        case Instagram = "instagram"
        case Blog = "dafault"
        case NoneOrigin = "none"
    }

    enum PostType: String {
        case Photo = "photo"
        case Video = "video"
        case Text = "text"
        case Link = "link"
        case NoneType = "none"
    }
}
