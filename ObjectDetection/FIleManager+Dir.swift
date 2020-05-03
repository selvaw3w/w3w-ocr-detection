//
//  FIleManager+Dir.swift
//  ObjectDetection
//
//  Created by Lshiva on 18/04/2020.
//  Copyright © 2020 What3words. All rights reserved.
//

import Foundation

extension FileManager {
    public class func DocumentsDir() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
    
    public class func sharedContainerForSuiteName(_ name: String?) -> String? {
        if let name = name, let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: name) {
            return url.path
        }
        return nil
    }
    
    public class func cachesDir() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
    
    public func deviceRemainingFreeSpaceInBytes() -> Int64? {
        if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: FileManager.DocumentsDir()) {
            if let freeSize = systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber {
                return freeSize.int64Value
            }
        }
        return nil
    }
}
