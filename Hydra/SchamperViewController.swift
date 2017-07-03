//
//  SchamperViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 01/07/2017.
//  Copyright © 2017 Zeus WPI. All rights reserved.
//

import Foundation
import SVProgressHUD

class SchamperViewController: UITableViewController {
    
    var articles: [SchamperArticle]
    
    required init?(coder aDecoder: NSCoder) {
        articles = []
        super.init(coder: aDecoder)
    }
    
    @objc func didPullRefreshControl(sender: Any) {
        SchamperStore.shared.reloadArticles()
    }
    
    override func viewDidLoad() {
        self.title = "Schamper Daily"
        
        articles = SchamperStore.shared.articles
        NotificationCenter.default.addObserver(self, selector: #selector(SchamperViewController.articlesUpdated(notification:)), name: NSNotification.Name(rawValue: SchamperStoreDidUpdateArticlesNotification), object: nil)
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.hydraTint
        refreshControl.addTarget(self, action: #selector(SchamperViewController.didPullRefreshControl), for: .valueChanged)
        
        self.refreshControl = refreshControl
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GAI_track("Schamper")
        
        if self.articles.count == 0 {
            SVProgressHUD.show()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reload table to show just read articles
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SVProgressHUD.dismiss()
        
        // Update store cache if moving out of this controller
        if self.isMovingFromParentViewController {
            SchamperStore.shared.syncStorage()
        }
    }
    
    //MARK: TableView datasource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SchamperCell") as? SchamperTableViewCell else {
            return UITableViewCell()
        }
        let article = articles[indexPath.row]
        cell.article = article
        
        return cell
    }
    
    @objc func articlesUpdated(notification: Notification) {
        articles = SchamperStore.shared.articles
        self.tableView.reloadData()
        
        if SVProgressHUD.isVisible() {
            if self.articles.count > 0 {
                SVProgressHUD.dismiss()
            } else {
                SVProgressHUD.showError(withStatus: "Geen artikels gevonden.")
            }
        }
    }
    
    //MARK: TableView delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = self.articles[indexPath.row]
        
        if !article.read {
            article.read = true
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        let vc = SchamperDetailViewController(withArticle: article)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

class SchamperTableViewCell: UITableViewCell {
    var article: SchamperArticle? {
        didSet {
            //TODO: fill in article
        }
    }
}
