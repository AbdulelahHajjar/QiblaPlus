//
//  LocationController.swift
//  QiblaPlus
//
//  Created by Abdulelah Hajjar on 06/03/2020.
//  Copyright © 2020 Abdulelah Hajjar. All rights reserved.
//

import Foundation
import CoreLocation

protocol QiblaDirectionProtocol {
    func didSuccessfullyFindHeading(heading: Double)
    func didFindError(error: [String : String])
}

class LocationController: NSObject, CLLocationManagerDelegate {
    var bearingAngle: Double?
    var qiblaDirectionDelegate: QiblaDirectionProtocol?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        if (lastLocation.horizontalAccuracy > 0) {
            let lat = lastLocation.coordinate.latitude * Double.pi / 180.0
            let lon = lastLocation.coordinate.longitude * Double.pi / 180.0
            bearingAngle = Constants.getBearing(newLat: lat, newLon: lon)
        }
        else {
            let errorD = ["en" : "⚠\nUnable to find device's location.", "ar" : "⚠\nتعذر الحصول على معلومات الموقع الحالي."]
            qiblaDirectionDelegate?.didFindError(error: errorD)
        }
    }
}
