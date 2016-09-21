//
//  SKOTimelineCollectionViewCell.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 16/09/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import FontAwesome_swift

class SKOTimelineCollectionViewCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var dateLabel: UILabel?
    @IBOutlet var bodyText: UITextView?
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var socialNetwork: UIImageView?
    @IBOutlet var imageHeightLarge: NSLayoutConstraint?
    @IBOutlet var imageHeightHidden: NSLayoutConstraint?
    
    var timelinePost: TimelinePost? {
        didSet {
            if let post = timelinePost {
                titleLabel?.text = post.title
                dateLabel?.text = SORelativeDateTransformer().transformedValue(post.date) as? String
                bodyText?.text = post.body
                if let media = post.media, let url = NSURL(string: media) where post.postType == .Photo {
                    imageView?.sd_setImageWithURL(url)
                    showImageView()
                } else {
                    hideImageView()
                }

                if let poster = post.poster, let url = NSURL(string: poster) {
                    imageView?.sd_setImageWithURL(url)
                    showImageView()
                } else {
                    hideImageView()
                }

                if let socialNetwork = socialNetwork {
                    switch post.origin {
                    case .Facebook:
                        socialNetwork.image = UIImage.fontAwesomeIconWithName(.Facebook, textColor: UIColor.blackColor(), size: socialNetwork.frame.size)
                    case .Instagram:
                        socialNetwork.image = UIImage.fontAwesomeIconWithName(.Instagram, textColor: UIColor.blackColor(), size: socialNetwork.frame.size)
                    default:
                        socialNetwork.image = nil
                    }
                }
            }
        }
    }

    func hideImageView() {
        imageView?.hidden = true
        imageHeightLarge?.active = false
        imageHeightHidden?.active = true
        self.layoutIfNeeded()
    }

    func showImageView() {
        imageView?.hidden = false
        imageHeightLarge?.active = true
        imageHeightHidden?.active = false
        self.layoutIfNeeded()
    }
}