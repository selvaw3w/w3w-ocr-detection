//
//  ThreeWordBoxes.swift
//  ObjectDetection
//
//  Created by Lshiva on 08/06/2020.
//  Copyright © 2020 MachineThink. All rights reserved.
//

import UIKit

class ThreeWordBox {

    var threeWordAddress    : String
    var threeWordRect     : CGRect
    var threeWordView     : ThreeWordBoundingBoxView?
    var countDownTimer      : Int
    
    init(threeWordAddress: String, threeWordRect: CGRect, threeWordView: ThreeWordBoundingBoxView? = nil) {
        self.threeWordAddress = threeWordAddress
        self.threeWordRect = threeWordRect
        self.threeWordView = threeWordView
        self.countDownTimer = Config.w3w.destructBBViewtimer
    }
}

class ThreeWordBoxes {
    
    var threeWordBoxes : Dictionary<String,ThreeWordBox> = [:]
    
    func add(threeWordAddress: String, rect: CGRect, parent: UIView) {
        if threeWordBoxes[threeWordAddress] != nil {
            threeWordBoxes[threeWordAddress]?.countDownTimer = Config.w3w.destructBBViewtimer
            threeWordBoxes[threeWordAddress]?.threeWordRect = rect
        } else {
            let createboundingBoxView = ThreeWordBoundingBoxView()
            threeWordBoxes[threeWordAddress] = ThreeWordBox(threeWordAddress: threeWordAddress, threeWordRect: rect, threeWordView: createboundingBoxView)
        }
    }
    
    func remove(threeWordBox: ThreeWordBox) {
        threeWordBoxes.removeValue(forKey: threeWordBox.threeWordAddress)
    }
    
    func removeBoundingBoxes() {
        for (_, threeWordbox) in threeWordBoxes {
            threeWordbox.countDownTimer -= 1
            if threeWordbox.countDownTimer < 1 {
                self.remove(threeWordBox: threeWordbox)
                threeWordbox.threeWordView?.hide()
            }
        }
    }
    
    func removeAllBoundingBox() {
        for(_, threeWordbox) in threeWordBoxes {
            threeWordbox.countDownTimer = 0
            self.remove(threeWordBox: threeWordbox)
            threeWordbox.threeWordView?.hide()
        }
    }
}
