//
//  LogicController.swift
//  QiblaPlus
//
//  Created by Abdulelah Hajjar on 18/02/2020.
//  Copyright © 2020 Abdulelah Hajjar. All rights reserved.
//

import Foundation

class LogicController {
    let constants = Constants()
    var enError = ""
    var arError = ""
    
    func setPrefLanguage(_ lang: String) {
        constants.defaults.set(lang, forKey: "Language")
    }
    
    func getPrefLanguage() -> String? {
        if let savedLanguage: String = constants.defaults.object(forKey: "Language") as? String {
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
        return constants.tips[lang]!
    }
    
    func setLastCalibrated(calibrationDate: Date) {
        constants.lastCalibrated = calibrationDate
    }
    
    func mustCalibrate() -> Bool {
        if let diff = Calendar.current.dateComponents([.minute], from: constants.lastCalibrated, to: Date()).minute, diff > 40 {
            return true
        }
        else {
            return false
        }
    }

    
    
    
    func getErrorMessage(appLanguage: String) -> String {
        if appLanguage == "en" {
            return enError
        }
        else {
            return arError
        }
    }
}
