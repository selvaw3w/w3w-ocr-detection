//
//  StoryBoaded.swift
//  ObjectDetection
//
//  Created by Lshiva on 17/04/2020.
//  Copyright © 2020 MachineThink. All rights reserved.
//

import Foundation
import UIKit

protocol StoryBoarded {
    static func instantiate() -> Self
}

extension StoryBoarded where Self: UIViewController {
    static func instantiate() -> Self {
        let id = String(describing: self)
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        return storyboard.instantiateViewController(identifier: id) as! Self
    }
}
