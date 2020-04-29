//
//  QiblaMode.swift
//  QiblaPlus
//
//  Created by Abdulelah Hajjar on 29/02/2020.
//  Copyright © 2020 Abdulelah Hajjar. All rights reserved.
//

import UIKit

class Constants {
    static let makkahLat = 0.3738927226761722      //21.4224750 deg
    static let makkahLon = 0.6950985611585316      //39.8262139 deg
    static let defaults = UserDefaults.standard
    static var lastCalibrated = Date()
    
    static let cannotFindLocation = ["en" : "⚠\nUnable to find device's location.", "ar" : "⚠\nتعذر الحصول على معلومات الموقع الحالي."]
    static let cannotCalibrate = ["en" : "⚠\nPlease enable\n\"Compass Calibration\" in:\nSettings -> Privacy -> Location Services -> System Services.", "ar" : "⚠\nPlease enable\n\"Compass Calibration\" in:\nSettings -> Privacy -> Location Services -> System Services."]
    static let locationDisabled = ["en" : "⚠\nPlease enable location services from your device's settings.", "ar" : "⚠\nالرجاء تفعيل خدمات الموقع من الإعدادات لمعرفة القبلة."]
    static let wrongAuthInSettings = ["en" : "⚠\nPlease allow this app \"When In Use\" location privileges to determine qibla direction.", "ar" : "⚠\nالرجاء إعطاء هذا التطبيق صلاحيات الموقع \"أثناء الإستخدام\" لمعرفة القبلة."]
    static let noTrueHeadingError = ["en" : "⚠\nYour device does not support true heading directions.", "ar" : "⚠\nجهازك لا يدعم إستخدام مستشعر الإتجاهات."]

    static func getTips() -> [String : NSAttributedString] {
        //Setting paragraph style for the tips
        let enParagraphStyle = NSMutableParagraphStyle()
        enParagraphStyle.lineSpacing = 8
        enParagraphStyle.alignment = .left
        
        let arParagraphStyle = NSMutableParagraphStyle()
        arParagraphStyle.lineSpacing = 0
        arParagraphStyle.alignment = .right
        arParagraphStyle.lineHeightMultiple = 0.91
        
        //Adding attributes to dictionary
        var tipsAttributes = [NSAttributedString.Key.font : UIFont(name: "SFProDisplay-Light", size: 15),
                              NSAttributedString.Key.paragraphStyle : enParagraphStyle,
                              NSAttributedString.Key.foregroundColor : UIColor.white]

        //Adding attributes to English string
        let enTipsAttributed : NSAttributedString = NSAttributedString(string: "Tips for better qibla accuracy:\n♾ Calibrate compass by moving iPhone in an 8-figure\n🧲  Move away from electronic devices\n📱 Lay your phone flat", attributes: tipsAttributes as [NSAttributedString.Key : Any])
        
        //Switching alignment of text to right
        tipsAttributes[NSAttributedString.Key.paragraphStyle] = arParagraphStyle
        tipsAttributes[NSAttributedString.Key.font] = UIFont(name: "Dubai-Light", size: 15)
    
        //Adding attributes to Arabic string
        let arTipsAttributed : NSAttributedString = NSAttributedString(string: "نصائح لقبلة أدق:\n♾ عاير البوصلة بتدوير الجهاز على شكل 8\n🧲  ابتعد عن الأجهزة الإلكترونية\n📱 ضع هاتفك بشكل مسطح", attributes: tipsAttributes as [NSAttributedString.Key : Any])
        
        return ["en" : enTipsAttributed, "ar" : arTipsAttributed]
    }
    
    static func getBearing(newLat: Double, newLon: Double) -> Double {
        let x = cos(makkahLat) * sin(makkahLon - newLon)
        let y = cos(newLat) * sin(makkahLat) - sin(newLat) * cos(makkahLat) * cos(makkahLon - newLon)
        return atan2(x, y)
    }
	
	static func mustCalibrate() -> Bool {
		if let diff = Calendar.current.dateComponents([.minute], from: Constants.lastCalibrated, to: Date()).minute, diff > 40 {
			return true
		}
		else {
			return false
		}
	}
	
	static func getDeviceLanguage() -> String {
		let prefLangArray = Locale.preferredLanguages.first!
		var prefLanguage: String
		prefLangArray.contains("ar") ? (prefLanguage = "ar") : (prefLanguage = "en")
		return prefLanguage
	}
	
	static func getPrefLanguage() -> String? {
		if let savedLanguage: String = Constants.defaults.object(forKey: "Language") as? String {
			return savedLanguage
		}
		else {
			return nil
		}
	}
	
	static func setPrefLanguage(_ lang: String) {
		Constants.defaults.set(lang, forKey: "Language")
	}
	
	static func getTips(lang: String) -> NSAttributedString {
		return Constants.getTips()[lang]!
	}
	
	static func setLastCalibrated(calibrationDate: Date) {
		Constants.lastCalibrated = calibrationDate
	}
}
