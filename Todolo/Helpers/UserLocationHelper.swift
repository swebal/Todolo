//
//  UserLocationHelper.swift
//  Todolo
//
//  Created by Markus Karlsson on 2019-03-16.
//  Copyright © 2019 The App Factory AB. All rights reserved.
//

import UIKit
import CoreLocation

class UserLocationHelper: NSObject, CLLocationManagerDelegate {
    
    static let shared = UserLocationHelper()
    let locationManager = CLLocationManager()
    var lastKnownLocation:CLLocation?
    static let didUpdateLocation = "didUpdateLocation"
    static let locationDenied = "locationDenied"
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    func authorize() {
        locationManager.requestWhenInUseAuthorization() // Hänger ihop med vad man måste ange i info.plist
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationArray = locations as NSArray
        let location = locationArray.lastObject as! CLLocation
        lastKnownLocation = location
        let name = Notification.Name(UserLocationHelper.didUpdateLocation)
        NotificationCenter.default.post(name: name, object: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedWhenInUse) {
            print("Location allowed")
            // Start location services
            locationManager.startUpdatingLocation()
        } else {
            print("Location denied")
            let name = Notification.Name(UserLocationHelper.locationDenied)
            NotificationCenter.default.post(name:name, object: nil)
        }
    }
    
    func searchCoordinates(address: String, withinMeters: Double, onLocationFound:@escaping (_ location: CLLocation) -> Void) {
        if lastKnownLocation != nil {
            CLGeocoder().geocodeAddressString(address) { (placemarks, error) in
                guard let placemarks = placemarks else {
                    onLocationFound(CLLocation(latitude: 0, longitude: 0))
                    return
                }
                var foundLocation = CLLocation(latitude: 0, longitude: 0)
                var shortestDistance: Double = withinMeters > 0 ? withinMeters : 999999999999
                for placemark in placemarks {
                    if let location = placemark.location {
                        let distance = location.distance(from: self.lastKnownLocation!)
                        if distance < shortestDistance {
                            shortestDistance = distance
                            foundLocation = location
                        }
                    }
                }
                onLocationFound(foundLocation)
            }
        } else {
            onLocationFound(CLLocation(latitude: 0, longitude: 0))
        }
    }
}
