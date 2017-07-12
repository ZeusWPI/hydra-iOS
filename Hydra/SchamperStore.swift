//
//  SchamperStore.swift
//  OAuthTest
//
//  Created by Feliciaan De Palmenaer on 28/02/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation
import Alamofire

let SchamperStoreDidUpdateArticlesNotification = "SchamperStoreDidUpdateArticlesNotification"

@objc class SchamperStore: SavableStore, Codable {

    private static var _shared: SchamperStore?
    @objc static var shared: SchamperStore {
        get {
            if let shared = _shared {
                return shared
            }
            
             _shared = SavableStore.loadStore(self, from: Config.SchamperStoreArchive)
            return _shared!
        }
    }

    var articles: [SchamperArticle] = []
    var lastUpdated: Date = Date(timeIntervalSince1970: 0)
    
    override func syncStorage() {
        super.syncStorage(obj: self, storageURL: Config.SchamperStoreArchive)
    }
    
    // MARK: Store functions
    // Force reload all articles
    func reloadArticles() {
        self.updateArticles()
    }

    func updateArticles(_ forceUpdate: Bool = false) {
        print("Updating Schamper Articles")

        let url = APIConfig.Zeus1_0 + "schamper/daily.json"

        self.updateResource(url, notificationName: SchamperStoreDidUpdateArticlesNotification, lastUpdated: self.lastUpdated, forceUpdate: forceUpdate) { (articles: [SchamperArticle]) in
            print("Updating Schamper articles")
            let readArticles = Set<String>(self.articles.filter({ $0.read }).map({ $0.title}))

            for article in articles {
                article.read = readArticles.contains(article.title)
            }

            self.articles = articles
            self.lastUpdated = Date()
        }

    }

    struct PropertyKey {
        static let articlesKey = "articles"
        static let lastUpdatedKey = "lastUpdated"
    }
}

// MARK: Implement FeedItemProtocol
extension SchamperStore: FeedItemProtocol {
    func feedItems() -> [FeedItem] {
        var feedItems = [FeedItem]()

        if !PreferencesService.sharedService.showSchamperInFeed {
            return feedItems
        }

        for article in articles { //TODO: test articles and sort them
            let daysOld = (article.date! as NSDate).days(before: Date())
            var priority = 999
            if !article.read {
                priority = priority - daysOld*40
            } else {
                priority = priority - daysOld*150
            }
            if priority > 0 {
                feedItems.append(FeedItem(itemType: .schamperNewsItem, object: article, priority: priority))
            }
        }
        return feedItems
    }
}
