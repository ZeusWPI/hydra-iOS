//
//  RestoMenuInfoCollectionViewCell.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 26/09/15.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import UIKit

class RestoMenuInfoCollectionViewCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!

    var sandwiches: [RestoSandwich]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 0:
            if let sandwiches = self.sandwiches {
                return sandwiches.count
            }
        default: break
        }
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch(indexPath.section) {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("sandwichCell") as? RestoSandwichTableViewCell
            
            cell?.item = sandwiches?[indexPath.item]
            
            return cell!
        default:
            return tableView.dequeueReusableCellWithIdentifier("infoItemCell")!
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 25
    }
}

class RestoSandwichTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var smallPriceLabel: UILabel!
    @IBOutlet weak var mediumPriceLabel: UILabel!
    
    var item: RestoSandwich? {
        didSet {
            if let item = item {
                self.nameLabel.text = item.name
                self.smallPriceLabel.text = "€ " + item.priceSmall
                self.mediumPriceLabel.text = "€ " + item.priceMedium
            }
        }
    }
}