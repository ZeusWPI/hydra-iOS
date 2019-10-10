//
//  RestoMenuCollectionCell.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 14/08/15.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import UIKit

class RestoMenuCollectionCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var extraMessage: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    var restoMenu: RestoMenu? {
        didSet {
            tableView.reloadData()
        }
    }

    override func awakeFromNib() {
        tableView.separatorColor = UIColor.clear
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 4; //TODO: add maaltijdsoep
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let menu = restoMenu, menu.open {
            let restoMenuSection = RestoMenuSection(rawValue: section)
            switch restoMenuSection! {
            case .soup:
                return (restoMenu?.sideDishes!.count)!
            case .meat:
                return (restoMenu?.mainDishes!.count)!
            case .vegetable:
                return (restoMenu?.vegetables!.count)!
            default:
                return 0
            }

        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuItemCell") as? RestoMenuItemTableViewCell

        cell?.backgroundColor = UIColor.clear // for iPads, for some strange the cells lose their color

        let restoMenuSection = RestoMenuSection(rawValue: (indexPath as NSIndexPath).section)
        switch restoMenuSection! {
        case .soup:
            cell!.menuItem = restoMenu?.sideDishes![(indexPath as NSIndexPath).row]
        case .meat:
            cell!.menuItem = restoMenu?.mainDishes![(indexPath as NSIndexPath).row]
        case .vegetable:
            cell!.vegetable = restoMenu?.vegetables![(indexPath as NSIndexPath).row]
        default: break
        }
        
        extraMessage.sizeToFit()

        return cell!
    }

    // Using footers of the previous section instead of headers so they scroll
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // Zero height for last section footer
        return section < 3 ? 35 : 0
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // Return nil if last footer
        if section == 3 {
            return nil
        }
        let frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: 35)
        let header = UIView(frame: frame)

        let label = UILabel(frame: frame)
        label.textAlignment = .center
        if #available(iOS 8.2, *) {
            label.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.light)
        } else {
            // Fallback on earlier versions
            label.font = UIFont.systemFont(ofSize: 20)
        }
        label.baselineAdjustment = .alignCenters
        let restoMenuSection = RestoMenuSection(rawValue: section+1)
        switch restoMenuSection! {
        case .soup:
            label.text = "SOEP"
        case .meat:
            label.text = "VLEES & VEGGIE"
        case .vegetable:
            label.text = "GROENTEN"
        default:
            return header
        }

        header.addSubview(label)
        return header
    }
}

class RestoMenuItemTableViewCell: UITableViewCell {
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

    var vegetable: String? {
        didSet {
            if let vegetable  = vegetable {
                nameLabel.text = vegetable
                priceLabel.text = ""
            }
        }
    }
}

enum RestoMenuSection: Int {
    case soup = 1, meat = 3, vegetable = 2, empty = 0
}
