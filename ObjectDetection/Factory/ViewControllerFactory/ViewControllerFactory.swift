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

protocol ReportViewControllerFactory {
    func instantiateReportController() -> ReportController
}
