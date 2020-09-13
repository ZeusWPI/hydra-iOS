//
//  HomeActivityCollectionViewCell.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 01/08/15.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import UIKit
import SDWebImage

class HomeActivityCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var associationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        self.contentView.setShadow()
    }

    var activity: Activity? {
        didSet {
            if let activity = self.activity {
                let longFormatter = DateFormatter.h_dateFormatterWithAppLocale()
                longFormatter?.timeStyle = .short
                longFormatter?.dateStyle = .long
                longFormatter?.doesRelativeDateFormatting = true

                let shortFormatter = DateFormatter.h_dateFormatterWithAppLocale()
                shortFormatter?.timeStyle = .short
                shortFormatter?.dateStyle = .none

                guard let longDateFormatter = longFormatter,
                    let shortDateFormatter = shortFormatter
                    else { return }

                associationLabel.text = activity.association
                titleLabel.text = activity.title

                if let end = activity.end {
                    if (activity.start as NSDate).addingDays(1) >= activity.end! {
                        dateLabel.text = "\(longDateFormatter.string(from: activity.start)) - \(shortDateFormatter.string(from: end))"
                    } else {
                        dateLabel.text = "\(longDateFormatter.string(from: activity.start))\n\(longDateFormatter.string(from: end))"
                    }
                } else {
                    dateLabel.text = longDateFormatter.string(from: activity.start)
                }

                descriptionLabel.text = activity.descriptionText
                
                locationLabel.text = activity.location

                imageView.sd_setImage(with: URL(string: APIConfig.DSA + "verenigingen/" + activity.association + "/logo")!)
            }
        }
    }
}
