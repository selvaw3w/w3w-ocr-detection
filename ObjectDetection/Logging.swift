//
//  Logging.swift
//  ObjectDetection
//
//  Created by Lshiva on 18/04/2020.
//  Copyright © 2020 What3words. All rights reserved.
//

import Foundation

public func DLog<T>(_ object: @autoclosure () -> T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
  #if DEBUG
    let queue = Thread.isMainThread ? "UI" : "BG"
    print("<\(queue)>: \(object())")
  #endif
}
