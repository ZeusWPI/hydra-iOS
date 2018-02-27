//
//  NewsViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 07/07/2017.
//  Copyright © 2017 Zeus WPI. All rights reserved.
//

import Foundation
import SafariServices

class NewsViewController: HydraTableViewController<NewsProtocol> {
    
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
    
    override func loadObjects() -> [NewsProtocol] {
        var items = [NewsProtocol]()
        items.append(contentsOf: AssociationStore.shared.newsItems as [NewsProtocol])
        items.append(contentsOf: AssociationStore.shared.ugentNewsItems as [NewsProtocol])
        items.sort { $1.date <= $0.date}
        return items
    }
    
    override func objectSelected(object item: NewsProtocol) {
        var item = item
        if !item.read {
            item.read = true
        }
        
        if let newsItem = item as? NewsItem {
            self.performSegue(withIdentifier: "newsDetailSegue", sender: newsItem)
        } else if let ugentNewsItem = item as? UGentNewsItem {
            let url = URL(string: ugentNewsItem.identifier)!
            let svc = SFSafariViewController(url: url)
            UIApplication.shared.windows[0].rootViewController?.present(svc, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "newsDetailSegue":
            guard let item = sender as? NewsItem, let vc = segue.destination as? NewsDetailViewController else { return }
            vc.newsItem = item
        default:
            break
        }
    }
}

class NewsItemTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var assocationLabel: UILabel?
    @IBOutlet weak var starImageView: UIImageView?
    
    var item: NewsProtocol? {
        didSet {
            if let item = item {
                self.titleLabel?.text = item.title
                if item.read {
                    self.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
                } else {
                    self.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
                }
                self.assocationLabel?.text = item.author
                self.starImageView?.isHidden = !item.highlighted
            }
        }
    }
}

protocol NewsProtocol {
    var title: String { get }
    var author: String { get }
    var date: Date { get }
    var highlighted: Bool { get }
    var content: String { get }
    var read: Bool { get set }
}

extension NewsItem: NewsProtocol {
    var author: String {
        get {
            return association.displayName
        }
    }
}

extension UGentNewsItem: NewsProtocol {
    var author: String {
        get {
            return creators.joined(separator: ", ")
        }
    }
    
    var highlighted: Bool {
        get {
            return true
        }
    }
}
