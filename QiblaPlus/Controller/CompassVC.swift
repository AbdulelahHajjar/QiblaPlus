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
	@IBOutlet weak var base: UIView!
	@IBOutlet weak var needle: UIImageView!
	@IBOutlet weak var warning: UILabel!
	@IBOutlet weak var calibration: UIImageView!
	@IBOutlet weak var progressBar: UIProgressView!
	
	var isAnimationPlaying = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setUpBase()
		setObservers()
		hideAllComponents()
		QiblaController.shared.qiblaDelegate = self
	}
	
	//MARK:- Qibla Direction Delegate Methods
	func didSuccessfullyFindHeading(rotationAngle: Double) {
		rotateNeedle(rotationAngle: rotationAngle)
		if !isAnimationPlaying && needle.alpha != 1 { show(component: .needle) }
	}
	
	func didFindError(error: String) {
		show(component: .warning)
		warning.text = error
	}
	
	func showCalibration() {
		if !isAnimationPlaying { showCalibrationDisplay() }
	}
	
	//MARK:- UI Components Related Methods
	func show(component: CompassComponent) {
		hideAllComponents()
		
		switch component {
		case .needle:
			needle.alpha = 1
		case .warning:
			warning.alpha = 1
		case .calibration:
			calibration.alpha = 1
			progressBar.alpha = 1
		}
	}
	
	func hideAllComponents() {
		needle.alpha = 0
		warning.alpha = 0
		progressBar.alpha = 0
		calibration.alpha = 0
	}
	
	func rotateNeedle(rotationAngle: Double) {
		UIView.animate(withDuration: 0.200) {
			self.needle.transform = CGAffineTransform.init(rotationAngle: CGFloat(rotationAngle))
		}
	}
	
	func setUpBase() {
		base.layer.cornerRadius = base.frame.size.width / 2
		base.clipsToBounds = true
		base.layer.borderColor = UIColor.lightGray.cgColor
		base.layer.borderWidth = 2
	}
	
	func showCalibrationDisplay() {
		isAnimationPlaying = true
		Constants.shared.refreshLastCalibrationDate()
		progressBar.setProgress(0, animated: false)
		calibration.image = UIImage.gif(asset: "Calibration")
		
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
								self.calibration.image = nil
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
	}
	
	@objc func onDidChangeAppLanguage(_ notification: Notification) {
		QiblaController.shared.startMonitoringQibla()
	}
}
