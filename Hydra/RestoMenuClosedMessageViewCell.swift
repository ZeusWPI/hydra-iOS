//
//  RestoMenuClosedMessageViewCell.swift
//  Hydra
//
// Created by Ieben Smessaert on 2019-04-18.
// Copyright (c) 2019 Zeus WPI. All rights reserved.
//

import UIKit

class RestoMenuClosedMessageCollectionCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var closedExtraMessage: String? {
        didSet {
            tableView.reloadData()
        }
    }
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuClosedItemCell") as? RestoMenuClosedMessageViewCell

        tableView.rowHeight = UITableView.automaticDimension
        cell?.backgroundColor = UIColor.clear // for iPads, for some strange the cells lose their color

        cell?.message = closedExtraMessage
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 25
    }
}
class RestoMenuClosedMessageViewCell: UITableViewCell {
    @IBOutlet weak var closedTextView: UITextView!
    
    var message: String? {
        didSet {
            if let message = message {
                closedTextView.text = message
                closedTextView.sizeToFit()
                closedTextView.layoutIfNeeded()
            }
        }
    }
}
