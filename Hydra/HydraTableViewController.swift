//
//  HydraTableViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 07/07/2017.
//  Copyright © 2017 Zeus WPI. All rights reserved.
//

import Foundation
import SVProgressHUD

class HydraTableViewController<T>: UITableViewController {
    
    var objects: [T]
    var notificationName: String? {
        get {
            return nil
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        objects = []
        super.init(coder: aDecoder)
    }
    
    //MARK: Required functions
    func reloadObjects() {
        fatalError()
    }
    
    func tableViewCell(forIndex index: Int) -> UITableViewCell {
        fatalError()
    }
    
    func loadObjects() -> [T] {
        fatalError()
    }
    
    func objectSelected(object: T) {
        fatalError()
    }
    
    //MARK: Implementation
    @objc func didPullRefreshControl(sender: Any) {
        reloadObjects()
    }
    
    override func viewDidLoad() {
        objects = loadObjects()
        if let notificationName = self.notificationName {
            NotificationCenter.default.addObserver(self, selector: #selector(HydraTableViewController.objectsUpdated(notification:)), name: NSNotification.Name(rawValue: notificationName), object: nil)
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.hydraTint
        refreshControl.addTarget(self, action: #selector(HydraTableViewController.didPullRefreshControl), for: .valueChanged)
        
        self.refreshControl = refreshControl
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let title = self.title {
            GAI_track(title)
        }
        
        if self.objects.count == 0 {
            SVProgressHUD.show()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reload table to show just read articles
        objects = loadObjects()
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SVProgressHUD.dismiss()
    }
    
    //MARK: TableView datasource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableViewCell(forIndex: indexPath.row)
    }
    
    @objc func objectsUpdated(notification: Notification) {
        objects = loadObjects()
        self.tableView.reloadData()
        
        if SVProgressHUD.isVisible() {
            if self.objects.count > 0 {
                SVProgressHUD.dismiss()
            } else {
                SVProgressHUD.showError(withStatus: "Geen objecten gevonden.")
            }
        }
    }
    
    //MARK: TableView delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = self.objects[indexPath.row]
        objectSelected(object: object)
    }
}
