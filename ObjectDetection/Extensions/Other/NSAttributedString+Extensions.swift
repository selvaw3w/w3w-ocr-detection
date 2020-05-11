//
//  NSAttributedString+Extensions.swift
//  ObjectDetection
//
//  Created by Lshiva on 11/05/2020.
//  Copyright © 2020 MachineThink. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {

    public func format3wa(threeWordAddress: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: "///\(threeWordAddress)")
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: NSRange(location: 0, length: 3))
        return attributedString
    }
}
