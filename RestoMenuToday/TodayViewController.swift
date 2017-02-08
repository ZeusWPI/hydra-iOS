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
    
    let visualEffectView = UIVisualEffectView(effect: UIVibrancyEffect.notificationCenter())
    let warningLabel     = UILabel()
    
    var menu : Menu!
    var filteredMenuItems : [MenuItem]!
    
    let menuItemTableViewCellIdentifier = "menuItemTableViewCell"

    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.warningLabel.textAlignment = .center
        
        // Add the warning label to the effect view and the effect view to the view
        self.visualEffectView.contentView.addSubview(self.warningLabel)
        self.view.addSubview(visualEffectView)
        
        self.updateView()
        
        self.widgetPerformUpdate()
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
    
    func updateView() {
        if let menu = menu {
            if menu.open {
                self.warningLabel.isHidden = true
                
                self.menuItemsTableView.isHidden = false
                self.menuItemsTableView.reloadData()
                
                self.preferredContentSize = self.menuItemsTableView.contentSize
            } else {
                self.warningLabel.isHidden = false
                self.warningLabel.text   = NSLocalizedString("We're Currently Closed", comment: "")
                
                self.menuItemsTableView.isHidden = true
                
                self.preferredContentSize = CGSize(width: self.view.frame.size.width, height: 50)
            }
        } else {
            self.warningLabel.isHidden = false
            self.warningLabel.text   = NSLocalizedString("No Data Available", comment: "")

            self.menuItemsTableView.isHidden = true
            
            self.preferredContentSize = CGSize(width: self.view.frame.size.width, height: 50)
        }
        
        self.view.setNeedsLayout()
    }

    // MARK: NCWidgetProviding
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void) = {result in return}) {
        let calendar = Calendar.current
        
        // Call the completion with no data as update result when we already have a menu for the given date
        if self.menu != nil && (calendar as NSCalendar).ordinality(of: .day, in: .era, for: self.menu.date as Date) ==  (calendar as NSCalendar).ordinality(of: .day, in: .era, for: Date()){
            completionHandler(.noData)
            return
        }

        if menu == nil {
            self.warningLabel.text = NSLocalizedString("Loading Data...", comment: "")
            self.warningLabel.isHidden = false
        }
        
        RestoManager.sharedManager.retrieveMenuForDate(Date(), completionHandler: { (menu, error) -> () in
            if let menu = menu {
                self.menu = menu
                
                // Filter all the menu items to only display the main menu items
                self.filteredMenuItems = menu.menuItems.filter { return $0.type == MenuItemType.main }
                
                completionHandler(.newData)
            } else {
                completionHandler(.failed)
            }
            
            self.updateView()
        })
    }

    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (self.menu != nil) ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.menu != nil) ? self.filteredMenuItems.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: menuItemTableViewCellIdentifier, for: indexPath) as! MenuItemTableViewCell
        cell.menuItem = self.filteredMenuItems[(indexPath as NSIndexPath).row]
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
