
//
//  MainCoordinator.swift
//  ObjectDetection
//
//  Created by Lshiva on 17/04/2020.
//  Copyright © 2020 MachineThink. All rights reserved.
//

import Foundation
import UIKit

class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        navigationController.setNavigationBarHidden(true, animated: true)
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = ScanViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
}
