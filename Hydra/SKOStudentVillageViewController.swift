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

    var exihibitors = [Exihibitor]()
    var oldExihibitors: [Exihibitor]?

    var previousSearchLength = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(SKOStudentVillageViewController.reloadExihibitors), name: NSNotification.Name(rawValue: SKOStoreExihibitorsUpdatedNotification), object: nil)
        exihibitors = SKOStore.shared.exihibitors

        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchResultsUpdater = self
        searchController?.delegate = self
        searchController?.dimsBackgroundDuringPresentation = false

        let searchBar = searchController!.searchBar
        searchBar.barTintColor = UIColor.SKOBackgroundColor()
        self.tableView?.tableHeaderView = searchBar
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func reloadExihibitors() {
        exihibitors = SKOStore.shared.exihibitors
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let searchController = self.searchController, searchController.isActive {
            self.searchController?.isActive = false
        }
    }

    // MARK: Searchbar
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text?.lowercased()
        if let searchString = searchString {
            let searchLength = searchString.characters.count
            if searchLength == 0 {
                self.exihibitors = oldExihibitors!
                self.previousSearchLength = 0
            } else {
                if previousSearchLength >= searchLength {
                    self.exihibitors = oldExihibitors!
                }
                self.previousSearchLength = searchLength

                exihibitors = exihibitors.filter({ (exi) -> Bool in
                    return exi.name.lowercased().range(of: searchString) != nil
                })
            }
        }

        self.tableView?.reloadData()
    }

    func willPresentSearchController(_ searchController: UISearchController) {
        oldExihibitors = exihibitors
    }

    func willDismissSearchController(_ searchController: UISearchController) {
        exihibitors = oldExihibitors!
        previousSearchLength = 0
    }

    // MARK: UITableview DataSource methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exihibitors.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentVillageCell") as! SKOStudentVillageTableViewCell

        cell.exihibitor = exihibitors[(indexPath as NSIndexPath).row]

        return cell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    // MARK: UITableView Delegate methods
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let exihibitor = exihibitors[(indexPath as NSIndexPath).row]

        self.performSegue(withIdentifier: "skoStudentVillageDetailSegue", sender: exihibitor)
    }

    // MARK: Storyboard segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, identifier == "skoStudentVillageDetailSegue" {
            guard let exihibitor = sender as? Exihibitor,
                let vc = segue.destination as? SKOStudentVillageDetailViewController
                else { return }

            vc.exihibitor = exihibitor
        }
    }
}
