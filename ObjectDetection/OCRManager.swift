//
//  OCRManager.swift
//  ObjectDetection
//
//  Created by Lshiva on 09/04/2020.
//  Copyright © 2020 What3words Ltd. All rights reserved.
//

import UIKit
import Foundation
import ocrsdk
import what3words

class OCRManager: NSObject {
    
    // Singleton w3w instance
    static let sharedInstance = OCRManager()
    // initialise w3w Engine
    var w3wEngine : W3wEngine? = nil
    // initialise ocr Engine
    var ocrEngine : W3WOCREngine? = nil
    // get current language
    var currentLanguage : String! {
        get {
            return self.seelectedOCRLanguage()
        }
    }
    
    override public init() {
        super.init()
        self.setDefaultLanguage()
        do {
            w3wEngine = try? W3wEngine.newDeviceEngine()
            let tessdataPath = copyFolders()
            ocrEngine = try? W3WOCREngine.newOcrEngine(languageCode: "af", tessdataPath: "\(tessdataPath)/tessdata", coreSDK: w3wEngine!)
            print("w3wsdk version:\(String(describing: w3wEngine?.version))")
            print("ocrsdk version:\(String(describing: ocrEngine?.version))")
        }
    }
    
    /**
        Set default OCR Language. Default to 'en'
        - Returns: String
     
     */
    fileprivate func setDefaultLanguage() { /// Localisation
        if let langStr = Locale.current.languageCode {
            Constants.w3w.defaultLanguage = langStr.lowercased()
        }
    }
    
    //MARK:- Language
    /**
        Get selected OCR language from the settings. Defaulted to 'en'
        - Returns: String
     */
    fileprivate func seelectedOCRLanguage() -> String {
        if let language = Settings.objectForKey(key: Constants.w3w.Language) as? String {
            return language
        } else {
            return Constants.w3w.defaultLanguage
        }
    }
    
    //MARK: add video buffer
    public func find_3wa(image: UIImage) -> String {
        let recognisedText = ocrEngine?.find_3wa(imageFromBuffer: image)
        return recognisedText!
    }
    
    public func addVideoBuffer(CMBuffer: CMSampleBuffer) {
        ocrEngine?.addVideoBuffer(buffer: CMBuffer)
    }
    
    //MARK: Set area of interest
    public func setAreaOfInterest(viewBounds: CGRect) {
        guard viewBounds.isNull else {
            ocrEngine?.setAreaOfInterest(viewBounds)
            return
        }
    }
}

extension OCRManager {
    //MARK: load w3w-data
    func copyFolders() -> String {
        let filemgr = FileManager.default
        filemgr.delegate = self as? FileManagerDelegate
        let dirPaths = filemgr.urls(for: .documentDirectory, in: .userDomainMask)
        let docsURL = dirPaths[0]

        let folderPath = Bundle.main.resourceURL!.appendingPathComponent("w3w-data").path
        let docsFolder = docsURL.appendingPathComponent("w3w-data").path
        copyFiles(pathFromBundle: folderPath, pathDestDocs: docsFolder)
    
        return docsFolder
    }
    
    func copyFiles(pathFromBundle : String, pathDestDocs: String) {
        let fileManagerIs = FileManager.default
        fileManagerIs.delegate = self as? FileManagerDelegate

        do {
            let filelist = try fileManagerIs.contentsOfDirectory(atPath: pathFromBundle)
            try? fileManagerIs.copyItem(atPath: pathFromBundle, toPath: pathDestDocs)

            for filename in filelist {
                try? fileManagerIs.copyItem(atPath: "\(pathFromBundle)/\(filename)", toPath: "\(pathDestDocs)/\(filename)")
            }
        } catch {
            print("\nError\n")
        }
    }
}
