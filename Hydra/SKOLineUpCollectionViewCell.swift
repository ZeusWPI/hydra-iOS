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
                if let picture = artist.image!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
                    self.imageView?.sd_setImage(with: URL(string: picture))
                } else {
                    self.imageView?.image = nil
                }
                self.artistLabel?.text = artist.name

                guard let shortDateFormatter = DateFormatter.h_dateFormatterWithAppLocale() else {
                    return
                }
                shortDateFormatter.timeStyle = .short
                shortDateFormatter.dateStyle = .none
                
                self.playTimeLabel?.text = "\(shortDateFormatter.string(from: artist.start))-\(shortDateFormatter.string(from: artist.end))"
            }
        }
    }
}
