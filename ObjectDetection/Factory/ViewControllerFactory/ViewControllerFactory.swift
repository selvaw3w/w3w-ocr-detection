//
//  ViewControllerFactory.swift
//  EncoreJets
//
//  Created by LShiva on 5/24/18.
//  Copyright © 2020 What3words. All rights reserved.
//

protocol ScanViewControllerFactory {
    func instantiateCameraController() -> CameraController
    func instantiatePhotoController() -> PhotoController
}

//    func instantiateTermsAndConditionsViewController() -> TermsAndConditionsViewController
//protocol SettingsViewControllerFactory {
//    func instantiateSettingsViewController() -> SettingsViewController
//}


