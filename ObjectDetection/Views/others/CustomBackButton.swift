//
//  CustomBackButton.swift
//  ObjectDetection
//
//  Created by Lshiva on 03/05/2020.
//  Copyright © 2020 What3words Ltd All rights reserved.
//

import UIKit

class CustomBackButton: UIButton {

    static func initCustomBackButton(backButtonImage: UIImage? = nil, backButtonTitle: String? = nil, backButtonfont: UIFont? = nil, backButtonTitleColor: UIColor? = nil) -> UIButton {
        let button = UIButton(type: .system)
        if let backButtonImage = backButtonImage {
            button.setImage(backButtonImage, for: .normal)
        }
        if let backButtonTitle = backButtonTitle {
            button.setTitle(backButtonTitle, for: .normal)
        }
        if let backButtonfont = backButtonfont {
            button.titleLabel?.font = backButtonfont
        }
        if let backButtonTitleColor = backButtonTitleColor {
            button.setTitleColor(backButtonTitleColor, for: .normal)
        }
        
        button.centerTextAndImage(spacing: 8)
        
        return button
    }

}

