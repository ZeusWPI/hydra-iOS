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
    
    private var locationManager: CLLocationManager = CLLocationManager()
    private var location: CLLocation?
    
    private override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.pausesLocationUpdatesAutomatically = true
        self.locationManager.distanceFilter = 100.0
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func updateLocation() {
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.Restricted || status == CLAuthorizationStatus.Denied {
            allowedLocation = false
            return
        } else if status == .NotDetermined {
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
    
    private func pauseUpdating() {
        self.locationManager.stopUpdatingLocation()
    }
    
    func calculateDistance(latitude: Double, longitude: Double) -> CLLocationDistance? {
        if !allowedLocation || location == nil{
            return nil
        }
        return location?.distanceFromLocation(CLLocation(latitude: latitude, longitude: longitude))
    }
    
    //MARK: - Implement core location delegate methods
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        debugPrint("LocationService: location updated")
        
        location = locations.first
        NSNotificationCenter.defaultCenter().postNotificationName(LocationServiceDidUpdateLocationNotification, object: nil)

        if #available(iOS 9.0, *) {
            // else is used
        } else {
            self.pauseUpdating()
        }
    }
    
    func locationManagerDidResumeLocationUpdates(manager: CLLocationManager) {
        debugPrint("LocationService: Resumed location updates")
    }

    func locationManagerDidPauseLocationUpdates(manager: CLLocationManager) {
        debugPrint("LocationService: Paused location updated")
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        debugPrint("LocationService: failed with error: \(error.localizedDescription)")
    }
}