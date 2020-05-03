
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
    private func showCameraViewController() {
        let showCameraViewController = self.factory.instantiateCameraViewController()
        showCameraViewController.onShowPhoto = { [unowned self] in
            self.showPhotoViewController()
        }
        
        self.router.setRootModule(showCameraViewController, hideBar: false, animated: false)
    }
    
    private func showPhotoViewController() {
        let photoViewController = self.factory.instantiatePhotoViewController()
        photoViewController.onBack = { [unowned self] in
            self.router.popModule(transition: FadeAnimator(animationDuration: 0.1, isPresenting: true))
        }
        
        self.router.push(photoViewController, transition: FadeAnimator(animationDuration: 0.2, isPresenting: true))
    }
    
    // MARK: - Coordinator
    
    override func start() {
        self.showCameraViewController()
    }
    
     // MARK: - Init
     init(router: RouterProtocol, factory: Factory) {
         self.router = router
         self.factory = factory
     }
}



//var childCoordinators = [Coordinator]()
//var navigationController: UINavigationController

//init(navigationController: UINavigationController) {
//    navigationController.setNavigationBarHidden(true, animated: true)
//    self.navigationController = navigationController
//}
//
//func start() {
//    self.camera()
//}
//
//func camera() {
//    let vc = CameraViewController.instantiate()
//    vc.coordinator = self
//    navigationController.pushViewController(vc, animated: false)
//}
//
//func photo(to Image: UIImage) {
//    let vc = PhotoViewController.instantiate()
//    vc.image = Image
//    vc.coordinator = self
//    navigationController.pushViewController(vc, animated: true)
//}
