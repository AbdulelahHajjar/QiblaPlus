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
    func didSuccessfullyFindHeading(rotationAngle: Double)
    func didFindError(error: [String : String])
}

class LocationController: NSObject, CLLocationManagerDelegate {
    
    var bearingAngle: Double?
    
    var locationManager = CLLocationManager()
    var qiblaDirectionDelegate: QiblaDirectionProtocol?
    
    let unableToFindLocationError = ["en" : "⚠\nUnable to find device's location.", "ar" : "⚠\nتعذر الحصول على معلومات الموقع الحالي."]
    let compassCalibrationError = ["en" : "⚠\nPlease enable\n\"Compass Calibration\" in:\nSettings -> Privacy -> Location Services -> System Services.", "ar" : "⚠\nPlease enable\n\"Compass Calibration\" in:\nSettings -> Privacy -> Location Services -> System Services."]
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        qiblaDirectionDelegate?.didFindError(error: unableToFindLocationError)
    }
    
//    func canFindQibla() -> Bool {
//        if CLLocationManager.locationServicesEnabled() == false {
//            enError = "⚠\nPlease enable location services from your device's settings."
//            arError = "⚠\nالرجاء تفعيل خدمات الموقع من الإعدادات لمعرفة القبلة."
//            return false
//        }
//        else if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse {
//            enError = "⚠\nPlease allow this app \"When In Use\" location privileges to determine qibla direction."
//            arError = "⚠\nالرجاء إعطاء هذا التطبيق صلاحيات الموقع \"أثناء الإستخدام\" لمعرفة القبلة."
//            return false
//        }
//        else if CLLocationManager.headingAvailable() == false {
//            enError = "⚠\nYour device does not support true heading directions."
//            arError = "⚠\nجهازك لا يدعم إستخدام مستشعر الإتجاهات."
//            return false
//        }
//        else {
//            enError = ""
//            arError = ""
//        }
//        return true
//    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        if (lastLocation.horizontalAccuracy > 0) {
            let lat = lastLocation.coordinate.latitude * Double.pi / 180.0
            let lon = lastLocation.coordinate.longitude * Double.pi / 180.0
            bearingAngle = Constants.getBearing(newLat: lat, newLon: lon)
        }
        else {
            qiblaDirectionDelegate?.didFindError(error: unableToFindLocationError)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        locationManager.startUpdatingLocation()
        var heading = newHeading.trueHeading
        
        if heading == -1.0 {
            qiblaDirectionDelegate?.didFindError(error: compassCalibrationError)
        }
            
        else {
            heading *= Double.pi/180.0
            if(bearingAngle == nil) {
                qiblaDirectionDelegate?.didFindError(error: unableToFindLocationError)
            }
            else {
                qiblaDirectionDelegate?.didSuccessfullyFindHeading(rotationAngle: bearingAngle! - heading + Double.pi * 2)
            }
        }
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        qiblaDirectionDelegate?.didFindError(error: ["en" : "Loading...", "ar" : "الرجاء الانتظار..."])
    }
}
