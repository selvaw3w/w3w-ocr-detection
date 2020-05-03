//
//  ViewControllerFactory.swift
//  EncoreJets
//
//  Created by LShiva on 5/24/18.
//  Copyright © 2020 What3words. All rights reserved.
//

protocol ScanViewControllerFactory {
    func instantiateCameraViewController() -> CameraViewController
    func instantiatePhotoViewController() -> PhotoViewController
}

//    func instantiateRegisterViewController() -> RegisterViewController
//    func instantiateTermsAndConditionsViewController() -> TermsAndConditionsViewController


//protocol WalktroughViewControllerFactory {
//    func instantiateWalktroughViewController() -> WalktroughViewController
//}


