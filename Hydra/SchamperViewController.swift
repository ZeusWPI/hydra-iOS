//
//  SchamperViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 01/07/2017.
//  Copyright © 2017 Zeus WPI. All rights reserved.
//

import Foundation

class SchamperViewController: HydraTableViewController<SchamperArticle> {
    
    override var notificationName: String? {
        get {
            return SchamperStoreDidUpdateArticlesNotification
        }
    }
    
    override func reloadObjects() {
        SchamperStore.shared.reloadArticles()
        self.refreshControl?.endRefreshing()
    }
    
    override func tableViewCell(forIndex index: Int) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SchamperCell") as? SchamperTableViewCell else {
            return UITableViewCell()
        }
        let article = objects[index]
        cell.article = article
        
        return cell
    }
    
    override func loadObjects() -> [SchamperArticle] {
        return SchamperStore.shared.articles
    }
    
    override func objectSelected(object article: SchamperArticle) {
        if !article.read {
            article.read = true
        }
        
        let vc = SchamperDetailViewController(withArticle: article)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

class SchamperTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var authorLabel: UILabel?
    
    var article: SchamperArticle? {
        didSet {
            if let article = article {
                self.titleLabel?.text = article.title
                if article.read {
                    self.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
                } else {
                    self.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
                }
                self.authorLabel?.text = article.author //TODO add time
            }
        }
    }
}
