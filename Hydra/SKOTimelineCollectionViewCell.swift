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
                if let media = post.media, let url = URL(string: media) , post.postType == .Photo {
                    imageView?.sd_setImage(with: url)
                    showImageView()
                } else {
                    hideImageView()
                }

                if let poster = post.poster, let url = URL(string: poster) {
                    imageView?.sd_setImage(with: url)
                    showImageView()
                } else if let media = post.media, let url = URL(string: media) {
                    imageView?.sd_setImage(with: url)
                    showImageView()
                } else {
                    hideImageView()
                }

                if let socialNetwork = socialNetwork {
                    switch post.origin {
                    case .Facebook:
                        socialNetwork.image = UIImage.fontAwesomeIcon(name: .facebook, textColor: UIColor.black, size: socialNetwork.frame.size)
                    case .Instagram:
                        socialNetwork.image = UIImage.fontAwesomeIcon(name: .instagram, textColor: UIColor.black, size: socialNetwork.frame.size)
                    default:
                        socialNetwork.image = nil
                    }
                }
            }
        }
    }

    func hideImageView() {
        imageView?.isHidden = true
        imageHeightLarge?.isActive = false
        imageHeightHidden?.isActive = true
        self.layoutIfNeeded()
    }

    func showImageView() {
        imageView?.isHidden = false
        imageHeightLarge?.isActive = true
        imageHeightHidden?.isActive = false
        self.layoutIfNeeded()
    }
}
