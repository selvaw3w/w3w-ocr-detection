//
//  Constants.swift
//  ObjectDetection
//
//  Created by Lshiva on 09/04/2020.
//  Copyright © 2020 What3words Ltd. All rights reserved.
//

import UIKit

struct Config {
    // Font
    struct Font {
        struct type {
            static let sourceSansBold   = "SourceSansPro-Bold"
            static let sourceLight      = "SourceSansPro-Light"
            static let sourceExtraLight = "SourceSansPro-ExtraLight"
            static let sourceSanRegular = "SourceSansPro-Regular"
        }
        struct Color {
            static let text             = UIColor(red: 0.039, green: 0.188, blue: 0.286, alpha: 1)
            static let background       = UIColor(red: 0.039, green: 0.188, blue: 0.286, alpha: 0.8)
            static let textGrayColor    = UIColor(red: 0.322, green: 0.322, blue: 0.322, alpha: 1)
            static let backgroundLight  = UIColor(red: 0.949, green: 0.957, blue: 0.961, alpha: 1)
        }
    }
    
    struct w3w {
        static var defaultLangauge      = "en"
        static var sendEmail            = ["matt.stuttle+OCR@what3words.com"]
    }
}
