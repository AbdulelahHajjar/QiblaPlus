//
//  LogicController.swift
//  QiblaPlus
//
//  Created by Abdulelah Hajjar on 18/02/2020.
//  Copyright © 2020 Abdulelah Hajjar. All rights reserved.
//

import Foundation

class LogicController {    
    func setPrefLanguage(_ lang: String) {
        Constants.defaults.set(lang, forKey: "Language")
    }
    
    //If a user prefers a language, this function will return it, otherwise, it is going to return nil
    func getPrefLanguage() -> String? {
        if let savedLanguage: String = Constants.defaults.object(forKey: "Language") as? String {
            return savedLanguage
        }
        else {
            return nil
        }
    }
    
    func getDeviceLanguage() -> String {
        let prefLangArray = Locale.preferredLanguages.first!
        var prefLanguage: String
        prefLangArray.contains("ar") ? (prefLanguage = "ar") : (prefLanguage = "en")
        return prefLanguage
    }
    
    func getTips(lang: String) -> NSAttributedString {
        return Constants.getTips()[lang]!
    }
    
    //Sets the date and time the device has calibrated at, to re-calibrate after 40 minutes
    func setLastCalibrated(calibrationDate: Date) {
        Constants.lastCalibrated = calibrationDate
    }
    
    //Returns true if the device must calibrate (based on the Date of last calibration)
    func mustCalibrate() -> Bool {
        if let diff = Calendar.current.dateComponents([.minute], from: Constants.lastCalibrated, to: Date()).minute, diff > 40 {
            return true
        }
        else {
            return false
        }
    }
}
