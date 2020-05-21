//
//  Constants.swift
//  QiblaPlus
//
//  Created by Abdulelah Hajjar on 29/02/2020.
//  Copyright © 2020 Abdulelah Hajjar. All rights reserved.
//

import UIKit

struct Constants {
	static var shared = Constants()
	
    let makkahLat = 0.3738927226761722 //21.4224750 deg
    let makkahLon = 0.6950985611585316 //39.8262139 deg
    var lastCalibrated = Date()
		
	var mustCalibrate: Bool {
		if let diff = Calendar.current.dateComponents([.minute], from: lastCalibrated, to: Date()).minute, diff > 40 { return true }
		else { return false }
	}
	
	private init() {}
	
    func bearing(lat: Double, lon: Double) -> Double {
		let newLat = lat * Double.pi / 180.0
		let newLon = lon * Double.pi / 180.0
        let x = cos(makkahLat) * sin(makkahLon - newLon)
        let y = cos(newLat) * sin(makkahLat) - sin(newLat) * cos(makkahLat) * cos(makkahLon - newLon)
        return atan2(x, y)
    }
	
	mutating func refreshLastCalibrationDate() {
		lastCalibrated = Date()
	}
}
