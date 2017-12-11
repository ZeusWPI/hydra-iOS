//
//  HomeUGentNewsItemCollectionViewCell.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 11/12/2017.
//  Copyright © 2017 Zeus WPI. All rights reserved.
//

import Foundation

class HomeUGentNewsItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var creatorsLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        self.contentView.setShadow()
    }
    
    var article: UGentNewsItem? {
        didSet {
            if let article = article {
                titleLabel.text = article.title
                let dateTransformer = SORelativeDateTransformer()
                dateLabel.text = dateTransformer.transformedValue(article.date) as! String?
                creatorsLabel.text = article.creators.joined(separator: ", ")
                contentLabel.text = article.content
            }
        }
    }
}
