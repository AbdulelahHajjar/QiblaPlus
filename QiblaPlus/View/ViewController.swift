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

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var needleImage: UIImageView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var calibrationProgressBar: UIProgressView!
    
    let logicController = LogicController()
    let locationManager = CLLocationManager()
    let constants = Constants()
    
    var bearing : Double = 0
    var locationArray = [CLLocation]()
    var currentLangauge = ""
    
    var animationDone: Bool = true          //No animation on first launch.
    var firstLaunch: Bool = true            //On first launch, this is true.
    var devicePassed40Mins: Bool = false    //On first launch, device did not pass 40 mins.
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackground()
        hideAllComponents()
        
        if(logicController.getPrefLanguage() == nil) {
            setLanguage(lang: logicController.getDeviceLanguage())
        }
        else {
            setLanguage(lang: logicController.getPrefLanguage()!)
        }
        
        setObservers()
        setLocationSettings()
        findQibla()
        
//        //Method to check installation date of the application
//        let urlToDocumentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
//        //installDate is NSDate of install
//        let installDate = (try! FileManager.default.attributesOfItem(atPath: urlToDocumentsFolder.path)[FileAttributeKey.creationDate])
//        print("This app was installed by the user on \(String(describing: installDate))")
    }
    
    //MARK: Qibla finding methods (Core)
    func findQibla() {
        if logicController.canFindQibla() {
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
            
            if (firstLaunch || logicController.mustCalibrate()) && animationDone {
                firstLaunch = false
                showCalibrationDisplay()
            }
        }
        else {
            showWarning(warningText: logicController.getErrorMessage(appLanguage: currentLangauge))
        }
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
            langBtnOutlet.titleString = "English"
        }
        else {
            langBtnOutlet.titleString = "عــربــي"

        }
        
        UIView.animate(withDuration: 0.250) {
            self.tipsLabel.alpha = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.250) {
            self.tipsLabel.attributedText = self.logicController.getTips(lang: lang)
            UIView.animate(withDuration: 0.250) {
                self.tipsLabel.alpha = 1.0
            }
        }
        logicController.setPrefLanguage(lang)
    }
    
    //MARK: Misc. methods
    func setObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appCameToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func appMovedToBackground() {
        locationArray.removeAll()
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
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
    
    
    //MARK: Location delegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationArray = locations
        let lastLocation = locationArray.last!
        if (lastLocation.horizontalAccuracy > 0) {
            let lat = lastLocation.coordinate.latitude * Double.pi / 180.0
            let lon = lastLocation.coordinate.longitude * Double.pi / 180.0
            bearing = logicController.getBearing(newLat: lat, newLon: lon)
        }
        else {
            if currentLangauge == "en" {
                showWarning(warningText: "⚠\nUnable to find device's location.")
            }
            else {
                showWarning(warningText: "⚠\nتعذر الحصول على معلومات الموقع الحالي.")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        locationManager.startUpdatingLocation()
        
        var heading = newHeading.trueHeading
        
        if heading == -1.0 {
            if currentLangauge == "en" {
                showWarning(warningText: "⚠\nPlease enable\n\"Compass Calibration\" in:\nSettings -> Privacy -> Location Services -> System Services.")
            }
            else {
                showWarning(warningText: "⚠\nPlease enable\n\"Compass Calibration\" in:\nSettings -> Privacy -> Location Services -> System Services.")
            }
        }
            
        else {
            if animationDone {
                showNeedle()
                
                heading *= Double.pi/180.0
                let rotationAngle = self.bearing - heading + Double.pi * 2
                
                UIView.animate(withDuration: 0.200) {
                    self.needleImage.transform = CGAffineTransform.init(rotationAngle: CGFloat(rotationAngle))
                }
                
                if rotationAngle > -0.050 && rotationAngle < 0.050 {
                    UIView.animate(withDuration: 0.250) {
                    }
                }
                else {
                    UIView.animate(withDuration: 0.250) {
                    }
                }
            }
        }
    }
    
    func setLocationSettings() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        showWarning(warningText: "Loading...")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        findQibla()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if currentLangauge == "en" {
            showWarning(warningText: "⚠\nUnable to find device's location.")
        }
        else {
            showWarning(warningText: "⚠\nتعذر الحصول على معلومات الموقع الحالي.")
        }
    }
    
    //MARK: UI-related methods
    func showCalibrationDisplay() {
        animationDone = false
        
        needleImage.transform = CGAffineTransform.init(rotationAngle: CGFloat(0))
        
        logicController.setLastCalibrated(calibrationDate: Date()) //Update last time calib display shown
        
        needleImage.image = UIImage(named: "NeedleCalibration" + currentLangauge.uppercased() + ".png")
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
                                self.animationDone = true
                            })
                        })
                    })
                })
            })
        }
    }
    
    func showWarning(warningText: String) {
        if animationDone { //Only show the warning if the calibration display is not being shown at the moment
            warningLabel.text = warningText
            needleImage.alpha = 0   //Hide the needle
            warningLabel.alpha = 1  //Show the warning
        }
    }
    
    func showNeedle() {
        if animationDone { //Only show the needle if the calibration display is not being shown at the moment
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
