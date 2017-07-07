//
//  TodayViewController.swift
//  Hydra
//
//  Created by Simon Schellaert on 12/11/14.
//  Copyright (c) 2014 Simon Schellaert. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NCWidgetProviding {
    
    // MARK: Interface Builder Outlets
    
    @IBOutlet weak var menuItemsTableView: UITableView!
    
    // MARK: Properties
    
    let visualEffectView = UIVisualEffectView(effect: UIVibrancyEffect.widgetPrimary())
    let warningLabel     = UILabel()
    
    var menu : RestoMenu?
    var filteredMenuItems : [RestoMenuItem]? {
        get {
            return menu?.mainDishes
        }
    }
    
    let menuItemTableViewCellIdentifier = "menuItemTableViewCell"

    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(TodayViewController.restoMenuUpdated), name: NSNotification.Name(rawValue: RestoStoreDidReceiveMenuNotification), object: nil)
        
        self.menu = RestoStore.shared.menuForDay(Date())
        self.warningLabel.textAlignment = .center
        
        // Add the warning label to the effect view and the effect view to the view
        self.visualEffectView.contentView.addSubview(self.warningLabel)
        self.view.addSubview(visualEffectView)
        
        self.updateView()
        
        self.widgetPerformUpdate()
        
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Set the visual effect view and warning label's size to be the size of the view
        self.visualEffectView.frame = self.view.bounds
        self.warningLabel.frame = self.visualEffectView.bounds
        
        // Move the warning label to the left to account for the left margin of the today extension
        self.warningLabel.center.x -= (UIScreen.main.bounds.width - self.view.bounds.width) / 2
    }

    // MARK: Custom Methods
    @objc func restoMenuUpdated() {
        self.menu = RestoStore.shared.menuForDay(Date())
        
        DispatchQueue.main.async {
            self.updateView()
        }
    }
    
    func updateView() {
        if let menu = menu {
            if menu.open {
                self.warningLabel.isHidden = true
                
                self.menuItemsTableView.isHidden = false
                self.menuItemsTableView.reloadData()
                
                self.preferredContentSize = self.menuItemsTableView.contentSize
            } else {
                showWarning(title: NSLocalizedString("We're Currently Closed", comment: ""))
            }
        } else {
            showWarning(title: NSLocalizedString("No Data Available", comment: ""))
        }
        
        self.view.setNeedsLayout()
    }
    
    func showWarning(title: String) {
        self.warningLabel.isHidden = false
        self.warningLabel.text = title
        
        self.menuItemsTableView.isHidden = true
        
        self.preferredContentSize = CGSize(width: self.view.frame.size.width, height: 50)
    }

    // MARK: NCWidgetProviding
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void) = {result in return}) {
        let calendar = Calendar.current as NSCalendar
        menu = RestoStore.shared.menuForDay(Date())
        
        // Call the completion with no data as update result when we already have a menu for the given date
        if let menu = self.menu, calendar.ordinality(of: .day, in: .era, for: menu.date) == calendar.ordinality(of: .day, in: .era, for: Date()){
            completionHandler(.noData)
            return
        }

        if menu == nil {
            self.warningLabel.text = NSLocalizedString("Loading Data...", comment: "")
            self.warningLabel.isHidden = false
        }
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        switch activeDisplayMode {
        case .compact:
            self.preferredContentSize = CGSize(width: maxSize.width, height: 110)
        case .expanded:
            var rows = CGFloat(0)
            rows += CGFloat(self.filteredMenuItems?.count ?? 0)
            self.preferredContentSize = CGSize(width: maxSize.width, height: CGFloat(36)*rows)
        }
    }
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (self.menu != nil) ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return (self.filteredMenuItems != nil) ? self.filteredMenuItems!.count : 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: menuItemTableViewCellIdentifier, for: indexPath) as! MenuItemTableViewCell
        cell.menuItem = self.filteredMenuItems![indexPath.row]
        return cell
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Set the layout margins explicitly on iOS 8 to force no separator insets
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 36
    }
}
