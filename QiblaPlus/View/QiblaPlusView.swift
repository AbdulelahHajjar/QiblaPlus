//
//  QiblaPlusView.swift
//  AccurateQiblaFinder
//
//  Created by Abdulelah Hajjar on 04/08/2019.
//  Copyright © 2019 Abdulelah Hajjar. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftGifOrigin
import LGButton

class QiblaPlusView: UIViewController, QiblaDirectionProtocol {
    //MARK:- IBOutlets
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var needleImage: UIImageView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var calibrationProgressBar: UIProgressView!
    
    //MARK:- Current Status Variables
    var currentLangauge: String?
    var animationIsPlaying: Bool = false    //No animation on first launch.
    
    //MARK:- Overridden Functions
    override func loadView() {
        super.loadView()
        setBackground()
        hideAllComponents()
        
        if(Constants.shared.getPrefLanguage() == nil) {
            setLanguage(lang: Constants.shared.getDeviceLanguage())
        }
        else {
            setLanguage(lang: Constants.shared.getPrefLanguage()!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        QiblaController.shared.qiblaDelegate = self
        QiblaController.shared.startProcess()
        setObservers()
        showCalibrationDisplay()
    }
    
    //MARK:- QiblaDirectionProtocol Delegate Functions
    func didSuccessfullyFindHeading(rotationAngle: Double) {
        if !animationIsPlaying {
            UIView.animate(withDuration: 0.200) {
                self.showNeedle()
                self.needleImage.transform = CGAffineTransform.init(rotationAngle: CGFloat(rotationAngle))
            }
        }
    }
    
    func didFindError(error: [String : String]) {
        showWarning(warningText: error[currentLangauge!]!)
    }
    
	func showCalibration(force: Bool) {
		if force {showCalibrationDisplay()}
		else {showCalibrationIfNeeded()}
	}
	
    //MARK:- Language-related Functions
    @IBOutlet weak var langBtnOutlet: LGButton!
    @IBAction func changeLanguageBtn() {
        currentLangauge == "en" ? setLanguage(lang: "ar") : setLanguage(lang: "en")
        showCalibrationIfNeeded()
    }
    
    func setLanguage(lang: String) {
        currentLangauge = lang
        
        lang == "en" ? (langBtnOutlet.titleString = "عــربــي") : (langBtnOutlet.titleString = "English")
        
        Constants.shared.setPrefLanguage(lang)
        QiblaController.shared.startProcess()

        UIView.animate(withDuration: 0.250) {
            self.tipsLabel.alpha = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.250) {
            self.tipsLabel.attributedText = Constants.shared.getTips(lang: lang)
            UIView.animate(withDuration: 0.250) {
                self.tipsLabel.alpha = 1.0
            }
        }
    }
    
    
    //MARK:- UI-related Functions
    func showCalibrationIfNeeded() {
        if (Constants.shared.mustCalibrate()) && !animationIsPlaying && !QiblaController.shared.existsError {
            showCalibrationDisplay()
        }
    }
	
    func showWarning(warningText: String) {
        if !animationIsPlaying { //Only show the warning if the calibration display is not being shown at the moment
            warningLabel.text = warningText
            needleImage.alpha = 0   //Hide the needle
            warningLabel.alpha = 1  //Show the warning
        }
    }
    
    func showNeedle() {
        if !animationIsPlaying { //Only show the needle if the calibration display is not being shown at the moment
            needleImage.image = UIImage(named: "Needle.png")
            warningLabel.alpha = 0  //Hide the warning if any
            needleImage.alpha = 1   //Show needle
        }
    }
    
    func hideAllComponents() {
        warningLabel.alpha = 0
        needleImage.alpha = 0
        calibrationProgressBar.alpha = 0
    }
    
    func setBackground() {
        let gradient = CAGradientLayer()
        gradient.frame = backgroundView.bounds
        gradient.colors = [UIColor(red: 0.29, green: 0.48, blue: 0.63, alpha: 1.00).cgColor, UIColor(red: 0.15, green: 0.23, blue: 0.30, alpha: 1.00).cgColor]
        
        gradient.endPoint = CGPoint.init(x: 0, y: 1)
        gradient.startPoint = CGPoint.init(x: 1  , y: 0)
        backgroundView.layer.insertSublayer(gradient, at: 0)
    }
    
    func showCalibrationDisplay() {
        animationIsPlaying = true
		calibrationProgressBar.progress = 0
        needleImage.transform = CGAffineTransform.init(rotationAngle: CGFloat(0))
        Constants.shared.setLastCalibrated(calibrationDate: Date()) //Update last time calib display shown
        needleImage.image = UIImage(named: "NeedleCalibration" + currentLangauge!.uppercased() + ".png")
        calibrationProgressBar.setProgress(0, animated: false)
        needleImage.alpha = 1
        warningLabel.alpha = 0
        UIView.animate(withDuration: 0.400, animations: {
            self.calibrationProgressBar.alpha = 1
            self.needleImage.alpha = 1
        }) { (Bool) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.400, execute: {
                UIView.animate(withDuration: 3, animations: {
                    self.calibrationProgressBar.setProgress(1.0, animated: true)
                }, completion: { (Bool) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                        
                        UIView.animate(withDuration: 0.400, animations: {
                            self.needleImage.alpha = 0
                            self.calibrationProgressBar.alpha = 0
                        }, completion: { (Bool) in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.400, execute: {
                                self.needleImage.image = UIImage(named: "Needle.png")
                                UIView.animate(withDuration: 0.400, animations: {
                                    self.needleImage.alpha = 1
                                })
                                self.animationIsPlaying = false }) }) }) }) })
        }
    }
        
    //MARK:- App Background Activity Observer
    func setObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appCameToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func appMovedToBackground() {
        QiblaController.shared.locationManager.stopUpdatingHeading()
        QiblaController.shared.locationManager.stopUpdatingLocation()
    }
    
    @objc func appCameToForeground() {
        if(Constants.shared.getPrefLanguage() == nil) {
            setLanguage(lang: Constants.shared.getDeviceLanguage())
        }
        else {
            setLanguage(lang: Constants.shared.getPrefLanguage()!)
        }
                
        QiblaController.shared.startProcess()
        showCalibrationIfNeeded()
    }
}
