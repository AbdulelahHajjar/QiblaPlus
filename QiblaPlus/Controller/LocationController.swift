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
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        locationManager.startUpdatingLocation()
        
        var heading = newHeading.trueHeading
        
        if heading == -1.0 {
            if currentLangauge == "en" {
                showWarning(warningText: "⚠\nPlease enable\n\"Compass Calibration\" in:\nSettings -> Privacy -> Location Services -> System Services.")
            }
            else {
                showWarning(warningText: "⚠\nPlease enable\n\"Compass Calibration\" in:\nSettings -> Privacy -> Location Services -> System Services.")
            }
        }
            
        else {
            if !animationIsPlaying {
                showNeedle()
                heading *= Double.pi/180.0
                let rotationAngle = self.bearing - heading + Double.pi * 2
                
                UIView.animate(withDuration: 0.200) {
                    self.needleImage.transform = CGAffineTransform.init(rotationAngle: CGFloat(rotationAngle))
                }
            }
        }
    }
}
