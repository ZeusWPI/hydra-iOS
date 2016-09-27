//
//  HomeRestoCollectionViewCell.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 31/07/15.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import UIKit

class HomeRestoCollectionViewCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var closedLabel: UILabel!
    
    
    var restoMenu: RestoMenu? {
        didSet {
            if restoMenu != nil {
                closedLabel.isHidden = restoMenu!.open
                if (restoMenu!.date as NSDate).isToday() {
                    dayLabel.text = "vandaag"
                } else if (restoMenu!.date as NSDate).isTomorrow() {
                    dayLabel.text = "morgen"
                } else {
                    let formatter = DateFormatter.h_dateFormatterWithAppLocale()
                    formatter?.dateFormat = "EEEE d MMMM"
                    dayLabel.text = formatter?.string(from: restoMenu!.date as Date)
                }
            } else {
                dayLabel.text = ""
                closedLabel.isHidden = false
            }
            tableView.reloadData()
            self.layoutSubviews() // call this to force an update after setting the new menu, so the tableview height changes.
        }
    }
    
    override func awakeFromNib() {
        tableView.separatorColor = UIColor.clear
        self.contentView.setShadow()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if restoMenu!.open {
            if let count = restoMenu?.mainDishes?.count , restoMenu!.open{
                return count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "restoMenuTableViewCell") as? HomeRestoMenuItemTableViewCell

        cell!.menuItem = restoMenu?.mainDishes![(indexPath as NSIndexPath).row]

        return cell!
    }
}

class HomeRestoMenuItemTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var menuItem: RestoMenuItem? {
        didSet {
            if let menuItem = menuItem {
                nameLabel.text = menuItem.name
                priceLabel.text = menuItem.price
                self.contentView.layoutIfNeeded() // relayout when prices are added
            }
        }
    }
}
