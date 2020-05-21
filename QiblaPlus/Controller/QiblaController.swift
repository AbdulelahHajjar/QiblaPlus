//
//  QiblaController.swift
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
	func showCalibration(force: Bool)
}

class QiblaController: NSObject, CLLocationManagerDelegate {
	private(set) static var shared = QiblaController()
	
    var bearingAngle: Double?
    let locationManager = CLLocationManager()
    var qiblaDelegate: QiblaDirectionProtocol?
    
    var existsError: Bool = false
    
    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
    }
	
	func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
		return true
	}
	
    func startProcess() {
        let canFindQibla = findErrors()
        if(canFindQibla) {
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
    }
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		startProcess()
		qiblaDelegate?.showCalibration(force: true)
	}
	
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        var heading = newHeading.trueHeading
		let location = manager.location
		
        if heading == -1.0 { qiblaDelegate?.didFindError(error: Constants.shared.cannotCalibrate) }
		else if location == nil && location?.horizontalAccuracy ?? 0 <= 0 { qiblaDelegate?.didFindError(error: Constants.shared.cannotFindLocation )}
        else {
			let bearingAngle = Constants.shared.bearing(lat: location!.coordinate.latitude, lon: location!.coordinate.longitude)
            heading *= Double.pi/180.0
			qiblaDelegate?.didSuccessfullyFindHeading(rotationAngle: bearingAngle - heading + Double.pi * 2)
        }
    }
    
	func findErrors() -> Bool {
		var status = false
        if(CLLocationManager.headingAvailable() == false) {
            qiblaDelegate?.didFindError(error: Constants.shared.noTrueHeadingError)
        }
        else if CLLocationManager.locationServicesEnabled() == false {
            qiblaDelegate?.didFindError(error: Constants.shared.locationDisabled)
        }
        else if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse {
            qiblaDelegate?.didFindError(error: Constants.shared.wrongAuthInSettings)
        }
		else {
			status = true
		}
		return status
    }
}
