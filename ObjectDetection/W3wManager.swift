//
//  W3wManager.swift
//  ObjectDetection
//
//  Created by Lshiva on 18/04/2020.
//  Copyright © 2020 MachineThink. All rights reserved.
//

import UIKit
import what3words

class W3wManager: NSObject {
    // selected w3w languages
    public var languages: [String]?
    // set the data path
    private var dataPath: String = ""
    // initialise the engine
    internal var engine: W3wEngine?
    // get sdk version
    public var sdkVersion: String? {
      return engine?.version
    }
    // get dataversion
    public var dataVersion: String? {
      return engine?.dataVersion
    }
    // delete the engine
    public func cleanup() {
        self.engine = nil
    }
    
    init(dataPath: String) {
        self.dataPath = dataPath
        super.init()
        
        let engine = self.createEngine()
        self.didInitialiseEngine(engine: engine)
    }
    
    fileprivate func createEngine() -> W3wEngine {
        var engine: W3wEngine!
        
        do {
            engine = try W3wEngine.newDeviceEngine(w3wDataPath: self.dataPath)
        } catch {
            DLog("Engine load error: \(error)")
        }
        return engine
    }
    
    fileprivate func didInitialiseEngine(engine: W3wEngine) {
        DLog("W3W-SDK Version: \(engine.version)")
        DLog("W3W-SDK Data Version: \(engine.dataVersion)")
        DLog("W3W-SDK available languages: \(engine.availableLanguages())")
        
        // Save available languages
        self.languages = engine.availableLanguages()
        
        // Save instance
        self.engine = engine
    
    }
}
