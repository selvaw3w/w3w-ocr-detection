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

class OCRManager: NSObject {
    
    // Singleton w3w instance
    static let sharedInstance = OCRManager()
    // initialise w3w Engine
    var w3wEngine : W3wManager?
    // set up w3w-days
    public var w3wModel: W3wDataModel!
    // initialise ocr Engine
    var ocrEngine : W3WOCREngine? = nil
    // get current language
    var currentLanguage : String! {
        get {
            return self.selectedOCRLanguage()
        }
    }
    // get sdk version
    public var ocrSdkVersion: String? {
      return ocrEngine?.version
    }
    
    // get dataversion
    public var ocrTesseractVersion: String? {
      return ocrEngine?.tesseract_version
    }
    
    override public init() {
        super.init()
        self.setDefaultLanguage()
        do {
            w3wModel = W3wDataModel(bundle: Bundle.main)
            
            w3wEngine = W3wManager(dataPath: w3wModel.w3wDataLocalPath)
            
            ocrEngine = try? W3WOCREngine.newOcrEngine(languageCode: "en", tessdataPath: w3wModel.ocrDataPath!, coreSDK: w3wEngine!.engine!)
            
            DLog("OCR-Engine: \(self.ocrSdkVersion!)")
            DLog("W3W-Data: \(self.ocrTesseractVersion!)")
        }
    }
    
    /// - Set default OCR Language. Default to 'en'
    fileprivate func setDefaultLanguage() { /// Localisation
        if let langStr = Locale.current.languageCode {
            Constants.w3w.defaultLanguage = langStr.lowercased()
        }
    }
    
    /// - Get selected OCR language from the settings. Defaulted to 'en'
    fileprivate func selectedOCRLanguage() -> String {
        if let language = Settings.objectForKey(key: Constants.w3w.Language) as? String {
            return language
        } else {
            return Constants.w3w.defaultLanguage
        }
    }
    
    /// - parameter image: send UIImage to OCR Engine for recognition
    public func find_3wa(image: UIImage) -> String {
        let recognisedText = ocrEngine?.find_3wa(imageFromBuffer: image)
        return recognisedText!
    }
    
    /// - parameter CMbuffer: send CMSamplebuffer to OCR engine for recognition
    public func addVideoBuffer(CMBuffer: CMSampleBuffer) {
        ocrEngine?.addVideoBuffer(buffer: CMBuffer)
    }
    
    /// - parameter viewBounds: set the region for recognition and draw the overlay area on the uiview
    public func setAreaOfInterest(viewBounds: CGRect) {
        guard viewBounds.isNull else {
            ocrEngine?.setAreaOfInterest(viewBounds)
            return
        }
    }
}

extension OCRManager: W3WOCRRecognitionDelegate {
    
    func w3wOCRSuggestions(_ recognisedText: String!) {
        //TODO: add recognition delegate to send receiver
    }
}
