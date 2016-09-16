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
    var date: NSDate?
    var origin: Origin = .None
    var postType: PostType = .None
    var poster: String?

    required init?(_ map: Map) {

    }

    func mapping(map: Map) {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)!
        let dateTransform = DateFormatterTransform(dateFormatter: formatter)

        let originTransform = TransformOf<Origin, String>(fromJSON: { (s) -> TimelinePost.Origin? in
            if let s = s {
                if let type = Origin(rawValue: s) {
                    return type
                }
            }
            return .None
            }) { $0?.rawValue }

        let postTypeTransform = TransformOf<PostType, String>(fromJSON: { (s) -> TimelinePost.PostType? in
            if let s = s, let type = PostType(rawValue: s) {
                return type
            }
            return .None
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
        return nil
    }

    func encodeWithCoder(aCoder: NSCoder) {

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
        case None = "none"
    }

    enum PostType: String {
        case Photo = "photo"
        case Video = "video"
        case Text = "text"
        case Link = "link"
        case None = "none"
    }
}

