//
//  Coordinator.swift
//  ObjectDetection
//
//  Created by LShiva on 3/14/18.
//  Copyright © 2020 What3words. All rights reserved.
//

import Foundation

protocol Coordinator: class {
    func start()
    func start(with option: DeepLinkOption?)
}
