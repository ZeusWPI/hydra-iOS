//
//  SKOLineUpCollectionViewCell.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 10/09/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import UIKit

class SKOLineUpCollectionViewCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView?
    @IBOutlet var artistLabel: UILabel?
    @IBOutlet var playTimeLabel: UILabel?

    var artist: Artist? {
        didSet {
            if let artist = artist {
                if let picture = artist.picture {
                    self.imageView?.sd_setImageWithURL(NSURL(string: picture))
                } else {
                    self.imageView?.image = nil
                }
                self.artistLabel?.text = artist.name

                let shortDateFormatter = NSDateFormatter.H_dateFormatterWithAppLocale()
                shortDateFormatter.timeStyle = .ShortStyle
                shortDateFormatter.dateStyle = .NoStyle

                self.playTimeLabel?.text = "\(shortDateFormatter.stringFromDate(artist.start))-\(shortDateFormatter.stringFromDate(artist.end))"
            }
        }
    }
}
