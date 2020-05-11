//
//  W3wDataModel.swift
//  ObjectDetection
//
//  Created by Lshiva on 18/04/2020.
//  Copyright © 2020 What3words. All rights reserved.
//

import UIKit
import SSZipArchive

class W3wDataModel: NSObject {
    // set w3w data path
    public var w3wDataLocalPath: String!
    
    public var w3w: W3wManager?
    
    public var ocrDataPath: String? {
        return self.w3wDataLocalPath + "/tessdata"
    }
    
    public init(bundle: Bundle) {
        super.init()
        let destinationDir = self.prepareW3wDataLocation()
        self.w3wDataLocalPath = destinationDir + "/w3w-data"
        self.unzipW3wData(bundle: bundle, destination: destinationDir)
    }
    
    fileprivate func prepareW3wDataLocation() -> String {
        
        let documentDir = FileManager.DocumentsDir()
        
        let w3wDataDocumentsPath = documentDir + "/w3w-data"
        
        do {
            if FileManager.default.fileExists(atPath: w3wDataDocumentsPath) {
                try FileManager.default.removeItem(atPath: w3wDataDocumentsPath)
            }
        } catch {
            fatalError("Couldn't remove w3w-data dir path: \(w3wDataDocumentsPath)")
        }
        
        return w3wDataDocumentsPath
    }

    fileprivate func unzipW3wData(bundle: Bundle, destination: String) {
        guard let w3wDataZipPath = bundle.path(forResource: "w3w-data", ofType: "zip") else {
            fatalError("Invalid zip patch or can't find w3w-data in the main bundle")
        }
        // Unzip
        try? SSZipArchive.unzipFile(atPath: w3wDataZipPath, toDestination: destination, overwrite: true, password: nil)
    }
}
