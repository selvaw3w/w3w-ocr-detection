//
//  CoordinatorFactory.swift
//  iOSStyleguide
//
//  Created by Pavle Pesic on 3/14/18.
//  Copyright © 2018 Fabrika. All rights reserved.
//

import UIKit

protocol CoordinatorFactoryProtocol {
    func instantiateApplicationCoordinator() -> ApplicationCoordinator
    func instantiateScanCoordinator(router: RouterProtocol) -> ScanCoordinator
    //TODO: settings coordinator
    //func instantiatSettingsCoordinator(router: RouterProtocol) -> SettingsCoordinator
}
