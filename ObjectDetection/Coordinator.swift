//
//  Coordinator.swift
//  ObjectDetection
//
//  Created by Lshiva on 16/04/2020.
//  Copyright © 2020 MachineThink. All rights reserved.
//

import Foundation
import UIKit

protocol Coordinator {
    var childCoordinators:[Coordinator] { get set }
    
    var navigationController: UINavigationController { get set }
    
    func start()
}
