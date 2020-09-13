//
//  ActivityDetailController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 11/12/2017.
//  Copyright © 2017 Zeus WPI. All rights reserved.
//

import Foundation
import MapKit
import SafariServices
import SDWebImage

class ActivityDetailController: UIViewController {
    
    var activity: Activity? {
        didSet {
            updateActivity()
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var associationLabel: UILabel?
    @IBOutlet weak var timeLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UITextView?
    @IBOutlet weak var linkButton: UIButton?
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var locationLabel: UILabel?
    @IBOutlet weak var addressLabel: UILabel?
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateActivity()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .default
        }
    }
    
    func updateActivity() {
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
        
        guard let activity = activity else { return }
        
        self.title = activity.association
        self.titleLabel?.text = activity.title
        self.associationLabel?.text = activity.association
        self.descriptionLabel?.text = activity.descriptionText
        self.descriptionLabel?.scrollRangeToVisible(NSRange.init(location: 0, length: 0))
        
        if let end = activity.end {
            if (activity.start as NSDate).addingDays(1) >= activity.end! {
                self.timeLabel?.text = "\(longDateFormatter.string(from: activity.start)) - \(shortDateFormatter.string(from: end))"
            } else {
                self.timeLabel?.text = "\(longDateFormatter.string(from: activity.start))\n\(longDateFormatter.string(from: end))"
            }
        } else {
            self.timeLabel?.text = longDateFormatter.string(from: activity.start)
        }
        
        self.locationLabel?.text = activity.location
        self.addressLabel?.text = activity.address
        
        self.imageView?.sd_setImage(with: URL(string: APIConfig.DSA + "verenigingen/" + activity.association + "/logo")!)
        
        if activity.url?.count ?? 0 > 0 {
            linkButton?.isHidden = false
        } else {
            linkButton?.isHidden = true
        }
    }
    
    @IBAction func linkClicked() {
        if let urlS = activity?.url, let url = URL(string: urlS) {
            let svc = SFSafariViewController(url: url)
            UIApplication.shared.windows[0].rootViewController?.present(svc, animated: true, completion: nil)
        }
    }
    
}
