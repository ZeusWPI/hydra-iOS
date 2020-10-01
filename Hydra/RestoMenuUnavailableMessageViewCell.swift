//
//  RestoMenuUnavailableMessageViewCell.swift
//  Hydra
//
//  Created by Ieben Smessaert on 01/10/2020.
//  Copyright © 2020 Zeus WPI. All rights reserved.
//

import UIKit

class RestoMenuUnavailableMessageCollectionCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    override func awakeFromNib() {
        tableView.separatorColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuUnavailableItemCell") as? RestoMenuUnavailableMessageViewCell

        tableView.rowHeight = UITableView.automaticDimension
        cell?.backgroundColor = UIColor.clear // for iPads, for some strange the cells lose their color
        
        cell?.unavailableTextView.sizeToFit()
        cell?.unavailableTextView.layoutIfNeeded()

        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 25
    }
}
class RestoMenuUnavailableMessageViewCell: UITableViewCell {
    @IBOutlet weak var unavailableTextView: UITextView!
}
