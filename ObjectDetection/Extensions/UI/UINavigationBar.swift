//
//  UINavigationBar.swift
//  ServiceOrientedArchitecture
//
//  Created by LShiva on 4/4/19.
//  Copyright © 2020 What3words. All rights reserved.
//

import UIKit

extension UINavigationBar {
    
    // MARK: - Public methods
    
    static func customNavBarStyle(color: UIColor, largeTextFont: UIFont, smallTextFont: UIFont, isTranslucent: Bool, barTintColor: UIColor?) {
        self.appearance().largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: color,
                                                      NSAttributedString.Key.font: largeTextFont]
        
        self.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: color,
                                                 NSAttributedString.Key.font: smallTextFont]
        
        self.appearance().isTranslucent = isTranslucent
        
        if let barTintColor = barTintColor {
            self.appearance().barTintColor = barTintColor
        }
    }
    
}
