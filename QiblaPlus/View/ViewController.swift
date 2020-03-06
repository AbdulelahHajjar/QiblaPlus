//
//  ViewController.swift
//  AccurateQiblaFinder
//
//  Created by Abdulelah Hajjar on 04/08/2019.
//  Copyright © 2019 Abdulelah Hajjar. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftGifOrigin
import LGButton

class ViewController: UIViewController, QiblaDirectionProtocol {
    
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var needleImage: UIImageView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var calibrationProgressBar: UIProgressView!
    
    let logicController =       LogicController()
    let locationController =    LocationController()
    let constants =             Constants()
    
    var currentLangauge: String?
    var animationIsPlaying: Bool = false    //No animation on first launch.
    var firstLaunch: Bool = true            //On first launch, this is true.
    
    override func loadView() {
        super.loadView()
        setBackground()
        hideAllComponents()
        
        if(logicController.getPrefLanguage() == nil) {
            setLanguage(lang: logicController.getDeviceLanguage())
        }
        else {
            setLanguage(lang: logicController.getPrefLanguage()!)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setObservers()
        locationController.qiblaDirectionDelegate = self
        findQibla()
    }
    
    //MARK: Qibla finding methods (Core)
    func findQibla() {
        if locationController.canFindQibla() {
            locationController.locationManager.startUpdatingLocation()
            locationController.locationManager.startUpdatingHeading()
            
            if (firstLaunch || logicController.mustCalibrate()) && !animationIsPlaying {
                firstLaunch = false
                showCalibrationDisplay()
            }
        }
    }
    
    func didSuccessfullyFindHeading(rotationAngle: Double) {
        if !animationIsPlaying {
            UIView.animate(withDuration: 0.200) {
            self.needleImage.transform = CGAffineTransform.init(rotationAngle: CGFloat(rotationAngle))
            }
        }
    }
    
    func didFindError(error: [String : String]) {
        showWarning(warningText: error[currentLangauge!]!)
    }
    
    //MARK: Language-related methods
    @IBOutlet weak var langBtnOutlet: LGButton!
    @IBAction func changeLanguageBtn() {
        if currentLangauge == "en" {
            setLanguage(lang: "ar")
        }
        else {
            setLanguage(lang: "en")
        }
        findQibla()
    }
    
    func setLanguage(lang: String) {
        currentLangauge = lang
        
        if(lang == "en") {
            langBtnOutlet.titleString = "عــربــي"
        }
        else {
            langBtnOutlet.titleString = "English"

        }
        
        logicController.setPrefLanguage(lang)

        UIView.animate(withDuration: 0.250) {
            self.tipsLabel.alpha = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.250) {
            self.tipsLabel.attributedText = self.logicController.getTips(lang: lang)
            UIView.animate(withDuration: 0.250) {
                self.tipsLabel.alpha = 1.0
            }
        }
    }
    
    //MARK: Misc. methods
    func setObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appCameToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func appMovedToBackground() {
        locationController.locationManager.stopUpdatingHeading()
        locationController.locationManager.stopUpdatingLocation()
    }
    
    @objc func appCameToForeground() {
        if(logicController.getPrefLanguage() == nil) {
            setLanguage(lang: logicController.getDeviceLanguage())
        }
        else {
            setLanguage(lang: logicController.getPrefLanguage()!)
        }
        findQibla()
    }
  
    //MARK: UI-related methods
    func showCalibrationDisplay() {
        animationIsPlaying = true
        needleImage.transform = CGAffineTransform.init(rotationAngle: CGFloat(0))
        logicController.setLastCalibrated(calibrationDate: Date()) //Update last time calib display shown
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
}

//        //Method to check installation date of the application
//        let urlToDocumentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
//        //installDate is NSDate of install
//        let installDate = (try! FileManager.default.attributesOfItem(atPath: urlToDocumentsFolder.path)[FileAttributeKey.creationDate])
//        print("This app was installed by the user on \(String(describing: installDate))")
