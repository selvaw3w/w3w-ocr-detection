//
//  UILabel.swift
//  ObjectDetection
//
//  Created by Lshiva on 01/07/2020.
//  Copyright © 2020 MachineThink. All rights reserved.
//

import UIKit


extension UILabel {
    func shadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 3.0
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
        self.layer.shouldRasterize = true
    }
}
