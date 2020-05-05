//
//  Extension.swift
//  ObjectDetection
//
//  Created by Lshiva on 29/04/2020.
//  Copyright © 2020 What3words. All rights reserved.
//

import UIKit


//MARK: UILabel
extension UILabel {
    
    @objc var substituteFontName : String {
        get { return self.font.fontName }
        set {
            if self.font.fontName.range(of:"-Bold") == nil {
                self.font = UIFont(name: newValue, size: self.font.pointSize)
            }
        }
    }
    
    @objc var substituteFontNameBold : String {
        get { return self.font.fontName }
        set {
            if self.font.fontName.range(of:"-Bold") != nil {
                self.font = UIFont(name: newValue, size: self.font.pointSize)
            }
        }
    }
}
//MARK: UITextfield
extension UITextField {
    @objc var substituteFontName : String {
        get { return self.font!.fontName }
        set { self.font = UIFont(name: newValue, size: (self.font?.pointSize)!) }
    }
}
//MARK: UIFont
extension UIFont {
    class func appRegularFontWith( size:CGFloat ) -> UIFont{
        return  UIFont(name: Config.Font.type.sourceLight, size: size)!
    }
    
    class func appBoldFontWith( size:CGFloat ) -> UIFont{
        return  UIFont(name: Config.Font.type.sourceLight, size: size)!
    }
}
