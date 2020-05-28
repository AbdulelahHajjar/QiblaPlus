//
//  CompassVC.swift
//  QiblaPlus
//
//  Created by Abdulelah Hajjar on 21/05/2020.
//  Copyright © 2020 Abdulelah Hajjar. All rights reserved.
//

import UIKit

enum CompassComponent {
	case needle
	case warning
	case calibration
}

class CompassVC: UIViewController, QiblaDirectionProtocol {
	
	//MARK:- Outlets
	@IBOutlet weak var baseImage: UIView!
	@IBOutlet weak var arrowImage: UIImageView!
	@IBOutlet weak var errorLabel: UILabel!
	@IBOutlet weak var calibrationInstructionImage: UIImageView!
	@IBOutlet weak var calibrationImage: UIImageView!
	@IBOutlet weak var progressBar: UIProgressView!
	
	var isAnimationPlaying = false
	var isNewAppSession = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setObservers()
		hideAllComponents()
		LocationDelegate.shared.qiblaDelegate = self
		LocationDelegate.shared.startMonitoringQibla()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		setUpBase()
	}
	
	//MARK:- Qibla Direction Delegate Methods
	func didSuccessfullyFindHeading(rotationAngle: Double) {
		rotateArrow(angle: rotationAngle)
		if !isAnimationPlaying && arrowImage.alpha != 1 {
			show(component: .needle)
		}
		
		if isNewAppSession {
			DataModel.shared.incrementSuccessSessionNumberIfNeeded()
			if DataModel.shared.shouldAskForReview {
				DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
					DataModel.shared.requestAppStoreReview()
				}
			}
			isNewAppSession = false
		}
	}
	
	func didFindError(error: String) {
		show(component: .warning)
		errorLabel.text = error
	}
	
	func showCalibration() {
		if !isAnimationPlaying { showCalibrationDisplay() }
	}
	
	//MARK:- UI Components Related Methods
	func show(component: CompassComponent) {
		hideAllComponents()
		
		switch component {
		case .needle:
			arrowImage.alpha = 1
		case .warning:
			errorLabel.alpha = 1
		case .calibration:
			calibrationImage.alpha = 1
			calibrationInstructionImage.alpha = 1
			progressBar.alpha = 1
		}
	}
	
	func hideAllComponents() {
		arrowImage.alpha = 0
		errorLabel.alpha = 0
		progressBar.alpha = 0
		calibrationImage.alpha = 0
		calibrationInstructionImage.alpha = 0
	}
	
	func rotateArrow(angle: Double) {
		UIView.animate(withDuration: 0.200) {
			self.arrowImage.transform = CGAffineTransform.init(rotationAngle: CGFloat(angle))
		}
	}
	
	func setUpBase() {
		let gradient = CAGradientLayer()
		gradient.frame = baseImage.bounds
		gradient.colors = [UIColor(cgColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)).cgColor,
						   UIColor(cgColor: #colorLiteral(red: 0.8392156863, green: 0.8784313725, blue: 0.8784313725, alpha: 1)).cgColor]
		
		gradient.endPoint = CGPoint.init(x: 0, y: 1)
		gradient.startPoint = CGPoint.init(x: 1  , y: 0)
		
		baseImage.layer.insertSublayer(gradient, at: 0)
		baseImage.layer.cornerRadius = baseImage.frame.size.width / 2
		baseImage.clipsToBounds = true
		baseImage.layer.borderColor = UIColor(cgColor: #colorLiteral(red: 0.7843137255, green: 0.8374213576, blue: 0.8374213576, alpha: 1)).cgColor
		baseImage.layer.borderWidth = 2
	}
	
	func showCalibrationDisplay() {
		isAnimationPlaying = true
		DataModel.shared.refreshLastCalibrationDate()
		progressBar.setProgress(0, animated: false)
		calibrationImage.image = UIImage.gif(asset: "Calibration")
		calibrationInstructionImage.image = UIImage(named: LanguageModel.shared.localizedString(from: .calibrationInstructionsImage))
		
		UIView.animate(withDuration: 0.400, animations: {
			self.show(component: .calibration)
		}) { (Bool) in
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.400, execute: {
				UIView.animate(withDuration: 3, animations: {
					self.progressBar.setProgress(1.0, animated: true)
				}, completion: { (Bool) in
					DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
						UIView.animate(withDuration: 0.400, animations: {
							self.show(component: .needle)
						}, completion: { (Bool) in
							DispatchQueue.main.asyncAfter(deadline: .now() + 0.400, execute: {
								self.isAnimationPlaying = false
								self.calibrationImage.image = nil
							})
						})
					})
				})
			})
		}
	}
	
	//MARK:- App Background Activity Observer
	func setObservers() {
		let notificationCenter = NotificationCenter.default
		notificationCenter.addObserver(self, selector: #selector(onDidChangeAppLanguage(_:)), name: LanguageModel.shared.appLanguageNotification, object: nil)
		notificationCenter.addObserver(self, selector: #selector(appCameToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
	}
	
	@objc func onDidChangeAppLanguage(_ notification: Notification) {
		LocationDelegate.shared.startMonitoringQibla()
	}
	
	@objc func appCameToForeground() {
		isNewAppSession = true
	}
}
