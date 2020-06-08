//
//  CameraViewModel.swift
//  ObjectDetection
//
//  Created by Lshiva on 11/05/2020.
//  Copyright © 2020 What3words. All rights reserved.
//

import Foundation
import what3words

class CameraViewModel {
    
    public var suggestion = [CameraModel]()
        
    var config = OCRManager.sharedInstance

    init(config: OCRManager) {
        self.config = config
    }
    
    public func suggestions(threeWordAddress: String) {
        let suggestions = self.config.w3wEngine?.autoAuggest(threeWordAddress: threeWordAddress)
        self.suggestion = CameraModel.suggestionItems(suggestions: suggestions!)
    }
}
