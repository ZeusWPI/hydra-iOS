//
//  LocationService.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 01/08/15.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import Foundation
import CoreLocation

let LocationServiceDidUpdateLocationNotification = "LocationServiceDidUpdateLocation"

class LocationService: NSObject, CLLocationManagerDelegate {
    
    static let sharedService = LocationService()
    
    var allowedLocation: Bool = false
    
    fileprivate var locationManager: CLLocationManager = CLLocationManager()
    fileprivate var location: CLLocation?
    
    fileprivate override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.pausesLocationUpdatesAutomatically = true
        self.locationManager.distanceFilter = 100.0
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func updateLocation() {
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.restricted || status == CLAuthorizationStatus.denied {
            allowedLocation = false
            return
        } else if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        allowedLocation = true
        if #available(iOS 9.0, *) {
            self.locationManager.requestLocation()
        } else {
            // Fallback on earlier versions
            self.locationManager.startUpdatingLocation()
        }
    }
    
    fileprivate func pauseUpdating() {
        self.locationManager.stopUpdatingLocation()
    }
    
    func calculateDistance(_ latitude: Double, longitude: Double) -> CLLocationDistance? {
        if !allowedLocation || location == nil{
            return nil
        }
        return location?.distance(from: CLLocation(latitude: latitude, longitude: longitude))
    }
    
    //MARK: - Implement core location delegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        debugPrint("LocationService: location updated")
        
        location = locations.first
        NotificationCenter.default.post(name: Notification.Name(rawValue: LocationServiceDidUpdateLocationNotification), object: nil)

        if #available(iOS 9.0, *) {
            // else is used
        } else {
            self.pauseUpdating()
        }
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        debugPrint("LocationService: Resumed location updates")
    }

    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        debugPrint("LocationService: Paused location updated")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint("LocationService: failed with error: \(error.localizedDescription)")
    }
}
