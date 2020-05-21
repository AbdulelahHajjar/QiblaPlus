//
//  LanguageModel.swift
//  QiblaPlus
//
//  Created by Abdulelah Hajjar on 21/05/2020.
//  Copyright © 2020 Abdulelah Hajjar. All rights reserved.
//

import UIKit

enum Language: String {
	case english = "en"
	case arabic = "ar"
	case unknown = "unknown"
}

enum DefaultsKeys: String {
	case language = "Language"
}

enum LocalizedStringKeys: String {
	case buttonText = "buttonText"
	case tips = "tips"
	case cannotFindLocation = "cannotFindLocation"
	case cannotCalibrate = "cannotCalibrate"
	case locationDisabled = "locationDisabled"
	case wrongAuthInSettings = "wrongAuthInSettings"
	case noTrueHeadingError = "noTrueHeadingError"
}

struct LanguageModel {
	static var shared = LanguageModel()
	let defaults = UserDefaults.standard
	
	var appLanguage: Language {
		get { savedLanguage != .unknown ? savedLanguage : deviceLanguage }
		set { setSavedLanguage(newValue) }
	}
	
	private var deviceLanguage: Language {
		let deviceLanguagesArray = Locale.preferredLanguages.first!
		var deviceLanguage: Language
		deviceLanguagesArray.contains(Language.arabic.rawValue) ? (deviceLanguage = .arabic) : (deviceLanguage = .english)
		return deviceLanguage
	}
	
	private var savedLanguage: Language {
		if let savedLanguage = defaults.object(forKey: DefaultsKeys.language.rawValue) as? String { return Language(rawValue: savedLanguage) ?? .unknown }
		else { return .unknown }
	}
	
	var tips: NSAttributedString {
		let tipsAttributes = [NSAttributedString.Key.font : UIFont(name: "SFProDisplay-Light", size: 15),
							  NSAttributedString.Key.paragraphStyle : paragraphStyle,
							  NSAttributedString.Key.foregroundColor : UIColor.white]
		
		return NSAttributedString(string: localizedString(from: .tips), attributes: tipsAttributes as [NSAttributedString.Key : Any])
	}
	
	var paragraphStyle: NSMutableParagraphStyle {
		let enParagraphStyle = NSMutableParagraphStyle()
		enParagraphStyle.lineSpacing = 8
		enParagraphStyle.alignment = appLanguage == .arabic ? .right : .left
		return enParagraphStyle
	}
	
	private init() {}
	
	private func setSavedLanguage(_ language: Language) {
		defaults.set(language.rawValue, forKey: DefaultsKeys.language.rawValue)
	}
	
	func localizedString(from key: LocalizedStringKeys) -> String {
		guard let bundlePath = Bundle.main.path(forResource: appLanguage.rawValue, ofType: "lproj"), let bundle = Bundle(path: bundlePath) else {
			return NSLocalizedString(key.rawValue, comment: "")
		}
		return NSLocalizedString(key.rawValue, tableName: nil, bundle: bundle, comment: "")
	}
}
