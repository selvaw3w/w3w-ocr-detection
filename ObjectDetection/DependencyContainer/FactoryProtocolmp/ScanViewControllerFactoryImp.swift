//
//  ViewControllerFactoryImp.swift
//  HauteCurator
//
//  Created by LShiva on 1/18/19.
//  Copyright © 2019 What3words. All rights reserved.
//

import UIKit

extension DependencyContainer: ScanViewControllerFactory {
    func instantiateCameraController() -> CameraController {
        let cameraController = UIStoryboard.main.instantiateViewController(identifier: "CameraController") as! CameraController
        return cameraController
    }
    
    func instantiatePhotoController() -> PhotoController {
        let photoController = UIStoryboard.main.instantiateViewController(identifier: "PhotoController") as! PhotoController
        return photoController
    }
}
