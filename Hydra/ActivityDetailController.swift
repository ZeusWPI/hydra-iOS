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
    @IBOutlet weak var mapView: MKMapView?
    @IBOutlet weak var locationLabel: UILabel?
    
    @IBOutlet weak var mapViewHeightConstraint: NSLayoutConstraint?
    
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
        
        self.title = activity.association.displayName
        self.titleLabel?.text = activity.title
        self.associationLabel?.text = activity.association.displayName
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
        
        var distance: Double? = nil
        if (activity.latitude != 0.0 && activity.longitude != 0.0) {
            distance = LocationService.sharedService.calculateDistance(activity.latitude, longitude: activity.longitude)
        }
        
        if let d = distance, d < 100*1000 {
            if d < 1000 {
                self.locationLabel?.text = activity.location + " (\(Int(d))m)"
            } else {
                self.locationLabel?.text = activity.location + " (\(Int(d/1000))km)"
            }
        } else {
            self.locationLabel?.text = activity.location
        }
        
        let association = activity.association.internalName.lowercased()
        self.imageView?.sd_setImage(with: URL(string: "https://zeus.ugent.be/hydra/api/2.0/association/logo/\(association).png")!)
        
        if let mapView = mapView, activity.hasCoordinates() {
            mapView.removeAnnotations(mapView.annotations)
            let annotation = MKPointAnnotation()
            let centerCoordinate = CLLocationCoordinate2D(latitude: activity.latitude, longitude: activity.longitude)
            annotation.coordinate = centerCoordinate
            annotation.title = activity.location
            mapView.addAnnotation(annotation)
            let distance: CLLocationDistance = 4000
            let region = MKCoordinateRegionMakeWithDistance(centerCoordinate, distance, distance)
            mapView.setRegion(region, animated: true)
            mapView.isHidden = false
        } else {
            mapView?.isHidden = true
            mapViewHeightConstraint?.constant = 0
        }
        
        if activity.url.count > 0 {
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
