//
//  TimelinePost.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 16/09/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import ObjectMapper

class TimelinePost: NSObject, NSCoding, Mappable {
    var title: String?
    var body: String?
    var link: String?
    var media: String?
    var date: Date?
    var origin: Origin = .NoneOrigin
    var postType: PostType = .NoneType
    var poster: String?

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
        let dateTransform = DateFormatterTransform(dateFormatter: formatter)

        let originTransform = TransformOf<Origin, String>(fromJSON: { (s) -> TimelinePost.Origin? in
            if let s = s {
                if let type = Origin(rawValue: s) {
                    return type
                }
            }
            return .NoneOrigin
            }) { $0?.rawValue }

        let postTypeTransform = TransformOf<PostType, String>(fromJSON: { (s) -> TimelinePost.PostType? in
            if let s = s, let type = PostType(rawValue: s) {
                return type
            }
            return .NoneType
            }) { $0?.rawValue }

        title <- map[PropertyKey.titleKey]
        body <- map[PropertyKey.bodyKey]
        link <- map[PropertyKey.linkKey]
        media <- map[PropertyKey.mediaKey]
        date <- (map["created_at"], dateTransform)
        origin <- (map[PropertyKey.originKey], originTransform)
        postType <- (map[PropertyKey.postTypeKey], postTypeTransform)
        poster <- map[PropertyKey.posterKey]
    }

    required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObject(forKey: PropertyKey.titleKey) as? String
        body = aDecoder.decodeObject(forKey: PropertyKey.bodyKey) as? String
        link = aDecoder.decodeObject(forKey: PropertyKey.linkKey) as? String
        media = aDecoder.decodeObject(forKey: PropertyKey.mediaKey) as? String
        date = aDecoder.decodeObject(forKey: PropertyKey.dateKey) as? Date
        poster = aDecoder.decodeObject(forKey: PropertyKey.posterKey) as? String

        guard let originValue = aDecoder.decodeObject(forKey: PropertyKey.originKey) as? String,
        let postTypeValue = aDecoder.decodeObject(forKey: PropertyKey.postTypeKey) as? String,
            let origin = Origin(rawValue: originValue),
            let postType = PostType(rawValue: postTypeValue) else { return nil }

        self.origin = origin
        self.postType = postType
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: PropertyKey.titleKey)
        aCoder.encode(body, forKey: PropertyKey.bodyKey)
        aCoder.encode(link, forKey: PropertyKey.linkKey)
        aCoder.encode(media, forKey: PropertyKey.mediaKey)
        aCoder.encode(date, forKey: PropertyKey.dateKey)
        aCoder.encode(poster, forKey: PropertyKey.posterKey)
        aCoder.encode(origin.rawValue, forKey: PropertyKey.originKey)
        aCoder.encode(postType.rawValue, forKey: PropertyKey.postTypeKey)
    }

    struct PropertyKey {
        static let titleKey = "title"
        static let bodyKey = "body"
        static let linkKey = "link"
        static let mediaKey = "media"
        static let dateKey = "date"
        static let originKey = "origin"
        static let postTypeKey = "post_type"
        static let posterKey = "poster"
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
