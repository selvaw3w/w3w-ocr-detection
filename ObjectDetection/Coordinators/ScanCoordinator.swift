
//
//  MainCoordinator.swift
//  ObjectDetection
//
//  Created by Lshiva on 17/04/2020.
//  Copyright © 2020 What3words. All rights reserved.
//

import Foundation
import UIKit

class ScanCoordinator: BaseCoordinator, CoordinatorFinishOutput {

    // MARK: - CoordinatorFinishOutput
    var finishFlow: (() -> Void)?
    
    // MARK: - Vars & Lets

    private let router: RouterProtocol
    private let factory: Factory

    // MARK: - Private methods
    private func showCameraController() {
        let showCameraController = self.factory.instantiateCameraController()
        showCameraController.onShowPhoto = { [unowned self] in
            self.showPhotoController()
        }
        
        self.router.setRootModule(showCameraController, hideBar: false, animated: false)
    }
    
    private func showPhotoController() {
        let photoController = self.factory.instantiatePhotoController()
        photoController.onBack = { [unowned self] in
            self.router.popModule(transition: FadeAnimator(animationDuration: 0.1, isPresenting: true))
        }
        
        self.router.push(photoController, transition: FadeAnimator(animationDuration: 0.2, isPresenting: true))
    }
    
    // MARK: - Coordinator
    
    override func start() {
        self.showCameraController()
    }
    
     // MARK: - Init
     init(router: RouterProtocol, factory: Factory) {
         self.router = router
         self.factory = factory
     }
}
