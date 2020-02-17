//
//  LogicController.swift
//  QiblaPlus
//
//  Created by Abdulelah Hajjar on 18/02/2020.
//  Copyright © 2020 Abdulelah Hajjar. All rights reserved.
//

import Foundation

class LogicController {
    var lastCalibrated = Date()
    
    func setLastCalibrated(calibrationDate: Date) {
        lastCalibrated = calibrationDate
    }
    
    func mustCalibrate() -> Bool {
        if let diff = Calendar.current.dateComponents([.minute], from: lastCalibrated, to: Date()).minute, diff > 40 {
            return true
        }
        else {
            return false
        }
    }
}
