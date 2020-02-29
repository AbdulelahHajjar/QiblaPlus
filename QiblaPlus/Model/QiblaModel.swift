//
//  QiblaMode.swift
//  QiblaPlus
//
//  Created by Abdulelah Hajjar on 29/02/2020.
//  Copyright © 2020 Abdulelah Hajjar. All rights reserved.
//

import UIKit


class QiblaModel {
    let tips: [String : NSAttributedString]
    
    
    init() {
        tips = QiblaModel.initTipsLabel()
    }
    
    static func initTipsLabel() -> [String : NSAttributedString] {
        //Setting paragraph style for the tips
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.lineSpacing = 8
        paragraphStyle.alignment = .left
        
        var tipsAttributes = [NSAttributedString.Key.font : UIFont(name: "SFProDisplay-Light", size: 15),
                              NSAttributedString.Key.paragraphStyle : paragraphStyle,
                              NSAttributedString.Key.foregroundColor : UIColor.white]
        
        let enTipsAttributed : NSAttributedString = NSAttributedString(string: "Tips for better qibla accuracy:\n♾ Calibrate compass by moving iPhone in an 8-figure\n🧲  Move away from electronic devices\n📱 Lay your phone flat", attributes: tipsAttributes as [NSAttributedString.Key : Any])
        
        //Switching alignment direction from left to right
        paragraphStyle.alignment = .right
        tipsAttributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        
        let arTipsAttributed : NSAttributedString = NSAttributedString(string: "نصائح لقبلة أدق:\n♾ عاير البوصلة بتدوير الجهاز على شكل 8\n🧲  ابتعد عن الأجهزة الإلكترونية\n📱 ضع هاتفك بشكل مسطح", attributes: tipsAttributes as [NSAttributedString.Key : Any])
        
        return ["en" : enTipsAttributed, "ar" : arTipsAttributed]
    }
}
