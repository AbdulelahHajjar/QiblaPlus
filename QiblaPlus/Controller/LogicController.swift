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
        if prefLangArray.contains("ar") {
            return "ar"
        }
        else {
            return "en"
        }
    }
    
    func getTips(lang: String) -> NSAttributedString {
        return Constants.getTips()[lang]!
    }
    
    func setLastCalibrated(calibrationDate: Date) {
        Constants.lastCalibrated = calibrationDate
    }
    
    func mustCalibrate() -> Bool {
        if let diff = Calendar.current.dateComponents([.minute], from: Constants.lastCalibrated, to: Date()).minute, diff > 40 {
            return true
        }
        else {
            return false
        }
    }
}
