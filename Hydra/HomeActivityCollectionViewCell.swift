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
                let longDateFormatter = DateFormatter.h_dateFormatterWithAppLocale()
                longDateFormatter?.timeStyle = .short
                longDateFormatter?.dateStyle = .long
                longDateFormatter?.doesRelativeDateFormatting = true

                let shortDateFormatter = DateFormatter.h_dateFormatterWithAppLocale()
                shortDateFormatter?.timeStyle = .short
                shortDateFormatter?.dateStyle = .none

                associationLabel.text = activity.association.displayName
                titleLabel.text = activity.title

                if let end = activity.end {
                    if (activity.start as NSDate).addingDays(1) >= activity.end! {
                        dateLabel.text = "\(longDateFormatter?.string(from: activity.start as Date)) - \(shortDateFormatter?.string(from: end as Date))"
                    } else {
                        dateLabel.text = "\(longDateFormatter?.string(from: activity.start as Date))\n\(longDateFormatter?.string(from: end as Date))"
                    }
                } else {
                    dateLabel.text = longDateFormatter?.string(from: (self.activity?.start)! as Date)
                }

                descriptionLabel.text = activity.descriptionText
                var distance: Double? = nil
                if (activity.latitude != 0.0 && activity.longitude != 0.0) {
                    distance = LocationService.sharedService.calculateDistance(activity.latitude, longitude: activity.longitude)
                }

                if let d = distance , d < 100*1000{
                    if d < 1000 {
                        locationLabel.text = activity.location + " (\(Int(d))m)"
                    } else {
                        locationLabel.text = activity.location + " (\(Int(d/1000))km)"
                    }
                } else {
                    locationLabel.text = activity.location
                }

                if let url = activity.facebookEvent?.imageUrl {
                    imageView.sd_setImage(with: url as URL, placeholderImage: imageView.image)
                } else {
                    let association = activity.association.internalName.lowercased()
                    imageView.sd_setImage(with: URL(string: "https://zeus.ugent.be/hydra/api/2.0/association/logo/\(association).png")!)
                }
            }
        }
    }
}
