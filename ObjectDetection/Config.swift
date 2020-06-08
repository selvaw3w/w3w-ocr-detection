//
//  Constants.swift
//  ObjectDetection
//
//  Created by Lshiva on 09/04/2020.
//  Copyright © 2020 What3words Ltd. All rights reserved.
//

import UIKit

struct Config {

    struct Font {
        struct type {
            static let sourceSansBold   = "SourceSansPro-Bold"
            static let sourceLight      = "SourceSansPro-Light"
            static let sourceExtraLight = "SourceSansPro-ExtraLight"
            static let sourceSanRegular = "SourceSansPro-Regular"
            static let rockWell         = "Rockwell"
        }
        struct Color {
            static let text             = UIColor(red: 0.039, green: 0.188, blue: 0.286, alpha: 1)
            static let background       = UIColor(red: 0.039, green: 0.188, blue: 0.286, alpha: 0.8)
            static let textGray         = UIColor(red: 0.322, green: 0.322, blue: 0.322, alpha: 1)
            static let backgroundLight  = UIColor(red: 0.949, green: 0.957, blue: 0.961, alpha: 1)
            static let overlayW3w       = UIColor(red: 0.039, green: 0.188, blue: 0.286, alpha: 0.3)
            static let overlaynonW3w    = UIColor.clear
            static let overlayError     = UIColor(red: 0.039, green: 0.188, blue: 0.286, alpha: 0.6)
            static let issue            = UIColor(red: 0.882, green: 0.122, blue: 0.149, alpha: 1)
        }
    }
    
    struct w3w {
        static var defaultLangauge      = "en"
        static var sendEmail            = ["matt.stuttle+OCR@what3words.com"]
        static let destructBBViewtimer  = 15
        static let countries = ["ad", "ae", "af", "ag", "ai", "al", "am", "ao", "aq", "ar", "as", "at", "au", "aw", "ax", "az", "ba", "bb", "bd", "be", "bf", "bg", "bh", "bi", "bj", "bl", "bm", "bn", "bo", "bq", "br", "bs", "bt", "bv", "bw", "by", "bz", "ca", "cc", "cd", "cf", "cg", "ch", "ci", "ck", "cl", "cm", "cn", "co", "cr", "cu", "cv", "cw", "cx", "cy", "cz", "de", "dj", "dk", "dm", "do", "dz", "ec", "ee", "eg", "eh", "er", "es", "et", "eu", "fi", "fj", "fk", "fm", "fo", "fr", "ga", "gb-eng", "gb-nir", "gb-sct", "gb-wls", "gb", "gd", "ge", "gf", "gg", "gh", "gi", "gl", "gm", "gn", "gp", "gq", "gr", "gs", "gt", "gu", "gw", "gy", "hk", "hm", "hn", "hr", "ht", "hu", "id", "ie", "il", "im", "in", "io", "iq", "ir", "is", "it", "je", "jm", "jo", "jp", "ke", "kg", "kh", "ki", "km", "kn", "kp", "kr", "kw", "ky", "kz", "la", "lb", "lc", "li", "lk", "lr", "ls", "lt", "lu", "lv", "ly", "ma", "mc", "md", "me", "mf", "mg", "mh", "mk", "ml", "mm", "mn", "mo", "mp", "mq", "mr", "ms", "mt", "mu", "mv", "mw", "mx", "my", "mz", "na", "nc", "ne", "nf", "ng", "ni", "nl", "no", "np", "nr", "nu", "nz", "om", "pa", "pe", "pf", "pg", "ph", "pk", "pl", "pm", "pn", "pr", "ps", "pt", "pw", "py", "qa", "re", "ro", "rs", "ru", "rw", "sa", "sb", "sc", "sd", "se", "sg", "sh", "si", "sj", "sk", "sl", "sm", "sn", "so", "sr", "ss", "st", "sv", "sx", "sy", "sz", "tc", "td", "tf", "tg", "th", "tj", "tk", "tl", "tm", "tn", "to", "tr", "tt", "tv", "tw", "tz", "ua", "ug", "um", "un", "us", "uy", "uz", "va", "vc", "ve", "vg", "vi", "vn", "vu", "wf", "ws", "ye", "yt", "za", "zm", "zw", "zz"]
        
        static let currentThreshold = "currentThreshold"
        static let current3waFilter = "current3waFilter"
        static let developerMode    = "developerMode"
    }
}
