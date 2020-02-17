//
//  LogicController.swift
//  QiblaPlus
//
//  Created by Abdulelah Hajjar on 18/02/2020.
//  Copyright © 2020 Abdulelah Hajjar. All rights reserved.
//

import Foundation
import CoreLocation

class LogicController {
    var lastCalibrated = Date()
    var enError = ""
    var arError = ""
    
    
    func setLastCalibrated(calibrationDate: Date) {
        lastCalibrated = calibrationDate
    }
    
    func mustCalibrate() -> Bool {
        if let diff = Calendar.current.dateComponents([.minute], from: lastCalibrated, to: Date()).minute, diff > 40 {
            return true
        }
        else {
            return false
        }
    }
    
    func canFindQibla() -> Bool {
        if CLLocationManager.locationServicesEnabled() == false {
            enError = "⚠\nPlease enable location services from your device's settings."
            arError = "⚠\nالرجاء تفعيل خدمات الموقع من الإعدادات لمعرفة القبلة."
            return false
        }
        else if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse {
            enError = "⚠\nPlease allow this app \"When In Use\" location privileges to determine qibla direction."
            arError = "⚠\nالرجاء إعطاء هذا التطبيق صلاحيات الموقع \"أثناء الإستخدام\" لمعرفة القبلة."
            return false
        }
        else if CLLocationManager.headingAvailable() == false {
            enError = "⚠\nYour device does not support true heading directions."
            arError = "⚠\nجهازك لا يدعم إستخدام مستشعر الإتجاهات."
            return false
        }
        return true
    }
    
    func getErrorMessage(appLanguage: String) -> String {
        return appLanguage == "en" ? enError : arError
    }
}
