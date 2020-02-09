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

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var needleImage: UIImageView!
    @IBOutlet weak var correctNeedle: UIImageView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var enTips: UILabel!
    @IBOutlet weak var arTips: UILabel!
    @IBOutlet weak var calibrationProgressBar: UIProgressView!
    
    let locationManager = CLLocationManager()
    let defaults = UserDefaults.standard
    let makkahLat = 0.3738927226761722      //21.4224750 deg
    let makkahLon = 0.6950985611585316      //39.8262139 deg
    var bearing : Double = 0
    var locationArray = [CLLocation]()
    var currentLangauge = ""
    
    var animationDone: Bool = true          //No animation on first launch.
    var firstLaunch: Bool = true            //On first launch, this is true.
    var lastTimeCalibDisplayShown = Date()  //Assign the current time of the device.
    var devicePassed40Mins: Bool = false    //On first launch, device did not pass 40 mins.
    
    @IBOutlet weak var langBtnOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackground()
        hideAllComponents()
        setLangSettings()
        setObservers()
        setLocationSettings()
        findQibla()
    }
    
    //MARK: Qibla finding methods (Core)
    func findQibla() {
        let error = errorMessages()
        
        if error.count == 0 {
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
            
            if let diff = Calendar.current.dateComponents([.minute], from: lastTimeCalibDisplayShown, to: Date()).minute, diff > 40 {
                devicePassed40Mins = true
            }
            else {
                devicePassed40Mins = false
            }
            
            if (firstLaunch || devicePassed40Mins) && animationDone {
                firstLaunch = false
                showCalibrationDisplay()
            }
        }
        else {
            showWarning(warningText: error)
        }
    }
    
    func errorMessages() -> String {
        if CLLocationManager.locationServicesEnabled() == false {
            if currentLangauge == "en" {
                return "⚠\nPlease enable location services from your device's settings."
            }
            else {
                return "⚠\nالرجاء تفعيل خدمات الموقع من الإعدادات لمعرفة القبلة."
            }
        }
        else if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse {
            if currentLangauge == "en" {
                return "⚠\nPlease allow this app \"When In Use\" location privileges to determine qibla direction."
            }
            else {
                return "⚠\nالرجاء إعطاء هذا التطبيق صلاحيات الموقع \"أثناء الإستخدام\" لمعرفة القبلة."
            }
        }
        else if CLLocationManager.headingAvailable() == false {
            if currentLangauge == "en" {
                return "⚠\nYour device does not support true heading directions."
            }
            else {
                return "⚠\nجهازك لا يدعم إستخدام مستشعر الإتجاهات."
            }
        }
        else {
            return ""
        }
    }
    
    func getBearing(newLat: Double, newLon: Double) -> Double {
        let x = cos(makkahLat) * sin(makkahLon - newLon)
        let y = cos(newLat) * sin(makkahLat) - sin(newLat) * cos(makkahLat) * cos(makkahLon - newLon)
        return atan2(x, y)
    }
    
    
    //MARK: Language-related methods
    @IBAction func langBtn(_ sender: UIButton) {
        if sender.titleLabel!.text! == "عربي" {
            setLanguage(lang: "ar")
            defaults.set("ar", forKey: "Language")
        }
        else {
            setLanguage(lang: "en")
            defaults.set("en", forKey: "Language")
        }
    }
    
    func findDeviceLanguage() {
        let prefLangArray = Locale.preferredLanguages.first!
        if prefLangArray.contains("ar") {
            setLanguage(lang: "ar")
        }
        else {
            setLanguage(lang: "en")
        }
    }
    
    func setLangSettings() {
        if let savedLanguage: String = defaults.object(forKey: "Language") as? String {
            setLanguage(lang: savedLanguage)
        }
        else {
            findDeviceLanguage()
        }
    }
    
    func setLanguage(lang: String) {
        if lang == "ar" {
            currentLangauge = "ar"
            langBtnOutlet.setTitle("English", for: .normal)
            
            UIView.animate(withDuration: 0.250) {
                self.enTips.alpha = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.250) {
                UIView.animate(withDuration: 0.250) {
                    self.arTips.alpha = 1
                }
            }
        }
        else {
            currentLangauge = "en"
            langBtnOutlet.setTitle("عربي", for: .normal)
            UIView.animate(withDuration: 0.250) {
                self.arTips.alpha = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.250) {
                UIView.animate(withDuration: 0.250) {
                    self.enTips.alpha = 1
                }
            }
        }
        findQibla()
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
        if let savedLanguage: String = defaults.object(forKey: "Language") as? String {
            setLanguage(lang: savedLanguage)
        }
        else {
            findDeviceLanguage()
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
            bearing = getBearing(newLat: lat, newLon: lon)
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
                    self.correctNeedle.transform = CGAffineTransform.init(rotationAngle: CGFloat(rotationAngle))
                }
                
                if rotationAngle > -0.050 && rotationAngle < 0.050 {
                    UIView.animate(withDuration: 0.250) {
                        self.correctNeedle.alpha = 1
                    }
                }
                else {
                    UIView.animate(withDuration: 0.250) {
                        self.correctNeedle.alpha = 0
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
        correctNeedle.transform = CGAffineTransform.init(rotationAngle: CGFloat(0))
        
        lastTimeCalibDisplayShown = Date()  //Update last time calib display shown
        
        needleImage.image = UIImage(named: "NeedleCalibration" + currentLangauge.uppercased() + ".png")
        correctNeedle.image = UIImage.gif(asset: "Calibration")
        calibrationProgressBar.setProgress(0, animated: false)
        
        needleImage.alpha = 1
        correctNeedle.alpha = 1
        warningLabel.alpha = 0
        
        UIView.animate(withDuration: 0.400, animations: {
            self.calibrationProgressBar.alpha = 1
            self.needleImage.alpha = 1
            self.correctNeedle.alpha = 1
        }) { (Bool) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.400, execute: {
                UIView.animate(withDuration: 3, animations: {
                    self.calibrationProgressBar.setProgress(1.0, animated: true)
                }, completion: { (Bool) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                        
                        UIView.animate(withDuration: 0.400, animations: {
                            self.needleImage.alpha = 0
                            self.correctNeedle.alpha = 0
                            self.calibrationProgressBar.alpha = 0
                        }, completion: { (Bool) in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.400, execute: {
                                self.needleImage.image = UIImage(named: "Needle.png")
                                self.correctNeedle.image = UIImage(named: "CorrectQiblaNeedle.png")
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
            correctNeedle.alpha = 0 //Hide the correct needle if available
            warningLabel.alpha = 1  //Show the warning
        }
    }
    
    func showNeedle() {
        if animationDone { //Only show the needle if the calibration display is not being shown at the moment
            needleImage.image = UIImage(named: "Needle.png")
            warningLabel.alpha = 0  //Hide the warning if any
            needleImage.alpha = 1   //Show needle
            correctNeedle.alpha = 0 //Hide correct needle to be showed by other methods
        }
    }
    
    func hideAllComponents() {
        warningLabel.alpha = 0
        needleImage.alpha = 0
        correctNeedle.alpha = 0
        calibrationProgressBar.alpha = 0
    }
    
    func setBackground() {
        let backgroundImageView = UIImageView()
        view.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundImageView.image = UIImage(named: "background.png")
        backgroundImageView.contentMode = UIView.ContentMode.scaleAspectFill
        view.sendSubviewToBack(backgroundImageView)
    }
}
