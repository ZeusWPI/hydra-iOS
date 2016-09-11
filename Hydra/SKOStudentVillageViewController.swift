//
//  SKOStudentVillageViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 09/09/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation


class SKOStudentVillageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating {

    @IBOutlet var tableView: UITableView?

    var searchController: UISearchController?

    var exihibitors = SKOStore.sharedStore.exihibitors
    var oldExihibitors: [Exihibitor]?

    var previousSearchLength = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SKOStudentVillageViewController.reloadExihibitors), name: SKOStoreExihibitorsUpdatedNotification, object: nil)

        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchResultsUpdater = self
        searchController?.delegate = self
        searchController?.dimsBackgroundDuringPresentation = false

        let searchBar = searchController!.searchBar
        searchBar.barTintColor = UIColor.SKOBackgroundColor()
        self.tableView?.tableHeaderView = searchBar
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func reloadExihibitors() {
        exihibitors = SKOStore.sharedStore.exihibitors
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView?.reloadData()
        }
    }

    // MARK: Searchbar
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text?.lowercaseString
        if let searchString = searchString {
            let searchLength = searchString.characters.count
            if searchLength == 0 {
                self.exihibitors = oldExihibitors!
                self.previousSearchLength = 0
            }
            else {
                if previousSearchLength >= searchLength {
                    self.exihibitors = oldExihibitors!
                }
                self.previousSearchLength = searchLength

                exihibitors = exihibitors.filter({ (exi) -> Bool in
                    return exi.name.lowercaseString.rangeOfString(searchString) != nil
                })
            }
        }

        self.tableView?.reloadData()
    }

    func willPresentSearchController(searchController: UISearchController) {
        oldExihibitors = exihibitors
    }

    func willDismissSearchController(searchController: UISearchController) {
        exihibitors = oldExihibitors!
        previousSearchLength = 0
    }

    // MARK: UITableview DataSource methods

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exihibitors.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("studentVillageCell") as! SKOStudentVillageTableViewCell

        cell.exihibitor = exihibitors[indexPath.row]
        
        return cell
    }

    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    // MARK: UITableView Delegate methods
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88
    }
}