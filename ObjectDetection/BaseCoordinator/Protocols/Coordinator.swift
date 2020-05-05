//
//  Coordinator.swift
//  iOSStyleguide
//
//  Created by LShiva on 3/05/20.
//  Copyright © 2018 Fabrika. All rights reserved.
//

import Foundation

protocol Coordinator: class {
    func start()
    func start(with option: DeepLinkOption?)
}
