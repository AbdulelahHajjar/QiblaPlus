//
//  QiblaMode.swift
//  QiblaPlus
//
//  Created by Abdulelah Hajjar on 29/02/2020.
//  Copyright © 2020 Abdulelah Hajjar. All rights reserved.
//

import UIKit


class Constants {
    let tips: [String : NSAttributedString]
    
    
    init() {
        tips = Constants.initTipsLabel()
    }
    
    static func initTipsLabel() -> [String : NSAttributedString] {
        //Setting paragraph style for the tips
        let enParagraphStyle = NSMutableParagraphStyle()
        enParagraphStyle.lineSpacing = 8
        enParagraphStyle.alignment = .left
        
        let arParagraphStyle = NSMutableParagraphStyle()
        arParagraphStyle.lineSpacing = 8
        arParagraphStyle.alignment = .right
        
        //Adding attributes to dictionary
        var tipsAttributes = [NSAttributedString.Key.font : UIFont(name: "SFProDisplay-Light", size: 15),
                              NSAttributedString.Key.paragraphStyle : enParagraphStyle,
                              NSAttributedString.Key.foregroundColor : UIColor.white]

        //Adding attributes to English string
        let enTipsAttributed : NSAttributedString = NSAttributedString(string: "Tips for better qibla accuracy:\n♾ Calibrate compass by moving iPhone in an 8-figure\n🧲  Move away from electronic devices\n📱 Lay your phone flat", attributes: tipsAttributes as [NSAttributedString.Key : Any])
        
        //Switching alignment of text to right
        tipsAttributes[NSAttributedString.Key.paragraphStyle] = arParagraphStyle
    
        //Adding attributes to Arabic string
        let arTipsAttributed : NSAttributedString = NSAttributedString(string: "نصائح لقبلة أدق:\n♾ عاير البوصلة بتدوير الجهاز على شكل 8\n🧲  ابتعد عن الأجهزة الإلكترونية\n📱 ضع هاتفك بشكل مسطح", attributes: tipsAttributes as [NSAttributedString.Key : Any])
        
        return ["en" : enTipsAttributed, "ar" : arTipsAttributed]
    }
}
