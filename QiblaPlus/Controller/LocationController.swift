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
    func didFindError(error: String)
}

class LocationController: NSObject, CLLocationManagerDelegate {
    var bearingAngle: Double?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        if (lastLocation.horizontalAccuracy > 0) {
            let lat = lastLocation.coordinate.latitude * Double.pi / 180.0
            let lon = lastLocation.coordinate.longitude * Double.pi / 180.0
            bearingAngle = logicController.getBearing(newLat: lat, newLon: lon)
        }
        else {
            if currentLangauge == "en" {
                showWarning(warningText: "⚠\nUnable to find device's location.")
            }
            else {
                showWarning(warningText: "⚠\nتعذر الحصول على معلومات الموقع الحالي.")
            }
        }
    }
    
    
}
