//
//  QiblaController.swift
//  QiblaPlus
//
//  Created by Abdulelah Hajjar on 06/03/2020.
//  Copyright © 2020 Abdulelah Hajjar. All rights reserved.
//

import UIKit
import CoreLocation

protocol QiblaDirectionProtocol {
    func didSuccessfullyFindHeading(rotationAngle: Double)
    func didFindError(error: String)
	func showCalibration()
}

class QiblaController: NSObject, CLLocationManagerDelegate {
	private(set) static var shared = QiblaController()
	
    let locationManager = CLLocationManager()
	var qiblaDelegate: QiblaDirectionProtocol?
	
	private var errorDescription: String? {
		if CLLocationManager.headingAvailable() == false {
			return LanguageModel.shared.localizedString(from: .noTrueHeadingError)
		}
		else if CLLocationManager.locationServicesEnabled() == false {
			return LanguageModel.shared.localizedString(from: .locationDisabled)
		}
		else if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse {
			return LanguageModel.shared.localizedString(from: .wrongAuthInSettings)
		}
		else {
			return nil
		}
	}
	
	var canFindQibla: Bool {
		return errorDescription == nil
	}
	
    override private init() {
        super.init()
		setObservers()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
	
    func startMonitoringQibla() {
		locationManager.requestWhenInUseAuthorization()
		
		if canFindQibla {
			if Constants.shared.mustCalibrate {
				qiblaDelegate?.showCalibration()
			}
			locationManager.pausesLocationUpdatesAutomatically = false
			locationManager.startUpdatingLocation()
			locationManager.startUpdatingHeading()
		} else {
			qiblaDelegate?.didFindError(error: errorDescription ?? "Error: Please restart the app.")
		}
    }
	
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        var heading = newHeading.trueHeading
		let location = manager.location
		
		if heading.isInvalid {
			qiblaDelegate?.didFindError(error: LanguageModel.shared.localizedString(from: .cannotCalibrate))
		}
		else if location?.isInvalid ?? true {
			qiblaDelegate?.didFindError(error: LanguageModel.shared.localizedString(from: .cannotFindLocation))
		}
        else {
			let latitude = location!.coordinate.latitude
			let longitude = location!.coordinate.longitude
			
			let bearingAngle = Constants.shared.bearing(lat: latitude, lon: longitude)
			
            heading *= Double.pi/180.0
			qiblaDelegate?.didSuccessfullyFindHeading(rotationAngle: bearingAngle - heading + Double.pi * 2)
        }
    }
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		startMonitoringQibla()
		if canFindQibla && Constants.shared.mustCalibrate { qiblaDelegate?.showCalibration() }
	}
	
	func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
		return true
	}
	
	func setObservers() {
		let notificationCenter = NotificationCenter.default
		notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
		notificationCenter.addObserver(self, selector: #selector(appCameToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
	}
	
	@objc func appMovedToBackground() {
		QiblaController.shared.locationManager.stopUpdatingHeading()
		QiblaController.shared.locationManager.stopUpdatingLocation()
	}
	
	@objc func appCameToForeground() {
		QiblaController.shared.startMonitoringQibla()
	}
}

extension CLLocationDirection {
	var isInvalid: Bool {
		return self == -1.0 || self.isNaN
	}
}

extension CLLocation {
	var isInvalid: Bool {
		return horizontalAccuracy < 0
	}
}
