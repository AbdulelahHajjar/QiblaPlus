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
    let locationManager = CLLocationManager()
    var qiblaDirectionDelegate: QiblaDirectionProtocol?
    
    var existsError: Bool = false
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startProcess() {
        findErrors()
        if(!existsError) {
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        if (lastLocation.horizontalAccuracy > 0) {
            let lat = lastLocation.coordinate.latitude * Double.pi / 180.0
            let lon = lastLocation.coordinate.longitude * Double.pi / 180.0
            bearingAngle = Constants.getBearing(newLat: lat, newLon: lon)
        }
        else {
            qiblaDirectionDelegate?.didFindError(error: Constants.cannotFindLocation)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        locationManager.startUpdatingLocation()
        var heading = newHeading.trueHeading

        if heading == -1.0 {
            qiblaDirectionDelegate?.didFindError(error: Constants.cannotCalibrate)
        }
            
        else {
            heading *= Double.pi/180.0
            if(bearingAngle == nil) {
                qiblaDirectionDelegate?.didFindError(error: Constants.cannotFindLocation)
            }
            else {
                qiblaDirectionDelegate?.didSuccessfullyFindHeading(rotationAngle: bearingAngle! - heading + Double.pi * 2)
            }
        }
    }
    
    func findErrors() {
        if(CLLocationManager.headingAvailable() == false) {
            qiblaDirectionDelegate?.didFindError(error: Constants.noTrueHeadingError)
            existsError = true
        }
        else if CLLocationManager.locationServicesEnabled() == false {
            qiblaDirectionDelegate?.didFindError(error: Constants.locationDisabled)
            existsError = true
        }
        else if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse {
            qiblaDirectionDelegate?.didFindError(error: Constants.wrongAuthInSettings)
            existsError = true
        }
        else {
            existsError = false
        }
    }
}
