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
            static let sourceLight = "SourceSansPro-Light"
            static let sourceExtraLight = "SourceSansPro-ExtraLight"
        }
        struct Color {
            static let text = UIColor(red: 0.039, green: 0.188, blue: 0.286, alpha: 1)
            static let background = UIColor(red: 0.039, green: 0.188, blue: 0.286, alpha: 0.8)
        }
    }
    
    struct w3w {
        static var defaultLangauge = "en"
    }
}
