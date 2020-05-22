//
//  QiblaVC.swift
//  QiblaPlus
//
//  Created by Abdulelah Hajjar on 04/08/2019.
//  Copyright © 2019 Abdulelah Hajjar. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftGifOrigin
import LGButton

class QiblaVC: UIViewController {
    //MARK:- IBOutlets
    @IBOutlet var backgroundView: UIView!
	@IBOutlet weak var tipsLabel: UILabel!
	
	//MARK:- Overridden Functions
    override func loadView() {
        super.loadView()
        setBackground()
		setObservers()
		langBtnOutlet.titleString = LanguageModel.shared.localizedString(from: .buttonText)
		tipsLabel.attributedText = LanguageModel.shared.tips
    }
	
    //MARK:- Language-related Functions
    @IBOutlet weak var langBtnOutlet: LGButton!
    @IBAction func changeLanguageBtn() {
		LanguageModel.shared.toggleLanguage()
    }
    
    //MARK:- UI-related
    func setBackground() {
        let gradient = CAGradientLayer()
        gradient.frame = backgroundView.bounds
        gradient.colors = [UIColor(red: 0.29, green: 0.48, blue: 0.63, alpha: 1.00).cgColor, UIColor(red: 0.15, green: 0.23, blue: 0.30, alpha: 1.00).cgColor]
        
        gradient.endPoint = CGPoint.init(x: 0, y: 1)
        gradient.startPoint = CGPoint.init(x: 1  , y: 0)
        backgroundView.layer.insertSublayer(gradient, at: 0)
    }
    
    //MARK:- App Background Activity Observer
    func setObservers() {
        let notificationCenter = NotificationCenter.default
		notificationCenter.addObserver(self, selector: #selector(onDidChangeAppLanguage(_:)), name: LanguageModel.shared.appLanguageNotification, object: nil)
    }
    
	@objc func onDidChangeAppLanguage(_ notification: Notification) {
		self.langBtnOutlet.titleString = LanguageModel.shared.localizedString(from: .buttonText)
		UIView.animate(withDuration: 0.250) {
			self.tipsLabel.alpha = 0
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.250) {
			self.tipsLabel.attributedText = LanguageModel.shared.tips
			UIView.animate(withDuration: 0.250) {
				self.tipsLabel.alpha = 1.0
			}
		}
	}
}
