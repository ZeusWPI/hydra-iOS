//
//  NewsViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 07/07/2017.
//  Copyright © 2017 Zeus WPI. All rights reserved.
//

import Foundation

class NewsViewController: HydraTableViewController<NewsItem> {
    
    override var notificationName: String? {
        get {
            return AssociationStoreDidUpdateNewsNotification
        }
    }
    
    override func reloadObjects() {
        AssociationStore.shared.reloadNewsItems(true)
    }
    
    override func tableViewCell(forIndex index: Int) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewsItemTableViewCell") as? NewsItemTableViewCell else {
            return UITableViewCell()
        }
        let item = objects[index]
        cell.item = item
        
        return cell
    }
    
    override func loadObjects() -> [NewsItem] {
        return AssociationStore.shared.newsItems
    }
    
    override func objectSelected(object item: NewsItem) {
        if !item.read {
            item.read = true
        }
        
        let vc = NewsDetailViewController(newsItem: item)
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}

class NewsItemTableViewCell: UITableViewCell {
    var item: NewsItem? {
        didSet {
            self.textLabel?.text = item?.title
            self.detailTextLabel?.text = item?.association.displayName //TODO add time
        }
    }
}

