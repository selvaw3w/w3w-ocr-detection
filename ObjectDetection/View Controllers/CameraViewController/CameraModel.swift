//
//  CameraModel.swift
//  ObjectDetection
//
//  Created by Lshiva on 11/05/2020.
//  Copyright © 2020 What3words. All rights reserved.
//c

import Foundation
import what3words

class CameraModel {

    var threeWordAddress    : String?
    var languageCode        : String?
    var countryCode         : String?
    var nearestPlace        : String?
    
    init(suggestion: W3wSuggestion) {
        self.threeWordAddress   = suggestion.threeWordAddress
        self.languageCode       = suggestion.languageCode
        self.countryCode        = suggestion.countryCode
        self.nearestPlace       = suggestion.nearestPlace
    }
    
    public class func suggestionItems(suggestions: [W3wSuggestion]) -> [CameraModel] {
        var items = [CameraModel]()
        for suggestion in suggestions {
            items.append(CameraModel(suggestion: suggestion))
        }
        return items
    }
}
