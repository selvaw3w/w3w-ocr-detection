//
//  CoordinatorFactory.swift
//  ObjectDetection
//
//  Created by LShiva on 3/14/18.
//  Copyright © 2020 What3words. All rights reserved.
//

import UIKit

protocol CoordinatorFactoryProtocol {
    func instantiateApplicationCoordinator() -> ApplicationCoordinator
    func instantiateScanCoordinator(router: RouterProtocol) -> ScanCoordinator
    //TODO: settings coordinator
    //func instantiatSettingsCoordinator(router: RouterProtocol) -> SettingsCoordinator
}
