//
//  ViewControllerFactoryImp.swift
//  HauteCurator
//
//  Created by LShiva on 1/18/19.
//  Copyright © 2020 What3words. All rights reserved.
//

import UIKit

extension DependencyContainer: ScanViewControllerFactory {
    func instantiateCameraViewController() -> CameraViewController {
        let cameraViewController = UIStoryboard.main.instantiateViewController(identifier: "CameraViewController") as! CameraViewController
        return cameraViewController
    }
    
    func instantiatePhotoViewController() -> PhotoViewController {
        let photoViewController = UIStoryboard.main.instantiateViewController(identifier: "PhotoViewController") as! PhotoViewController
        return photoViewController
    }
}
