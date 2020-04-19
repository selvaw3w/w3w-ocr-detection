//
//  CoreMLModel.swift
//  ObjectDetection
//
//  Created by Lshiva on 18/04/2020.
//  Copyright © 2020 MachineThink. All rights reserved.
//

import UIKit
import CoreMedia
import CoreML
import UIKit
import Vision

protocol processPredictionsDelegate {

    func showPredictions(predictions: [VNRecognizedObjectObservation])
}

class W3wCoreMLModel: NSObject {

    // set up delegate
    var delegate : processPredictionsDelegate?
    
    // Initialise coreML model
    let w3wMLModel   = w3w()

    // current pixel buffer
    var currentBuffer: CVPixelBuffer?
    
    // curernt buffer state
    var loadCurrentStatebuffer: CVPixelBuffer?
    
    // load coreML model
    lazy var visionModel: VNCoreMLModel = {
        do {
          return try VNCoreMLModel(for: w3wMLModel.model)
        } catch {
          fatalError("Failed to create VNCoreMLModel: \(error)")
        }
    }()
    
    override init() {
        super.init()
    }
    
    /// - Make new vision request
    lazy var visionRequest: VNCoreMLRequest = {
        let request = VNCoreMLRequest(model: visionModel, completionHandler: {
        [weak self] request, error in
        self?.processObservations(for: request, error: error)
        })

        request.imageCropAndScaleOption = .scaleFill
        return request
    }()
    
    /// - load all the labels from the model
    func loadLabels() -> [String] {
                
        // The label names are stored inside the MLModel's metadata.
        guard let userDefined = w3wMLModel.model.modelDescription.metadata[MLModelMetadataKey.creatorDefinedKey] as? [String: String],
        let allLabels = userDefined["classes"] else {
            fatalError("Missing metadata")
        }
        // load all the labels
        return allLabels.components(separatedBy: ",")
    }
    
    /// - process all observations
    func processObservations(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            if let results = request.results as? [VNRecognizedObjectObservation] {
                self.detectedObservation(predictions: results)
                self.currentBuffer = nil
            } else {
                self.detectedObservation(predictions: [])
            }
        }
    }
    
    func detectedObservation(predictions: [VNRecognizedObjectObservation]) {
        self.delegate?.showPredictions(predictions: predictions)
    }
    
    func predict(sampleBuffer: CMSampleBuffer) {
        if currentBuffer == nil, let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
          currentBuffer = pixelBuffer
          loadCurrentStatebuffer = currentBuffer

          var options: [VNImageOption : Any] = [:]
          if let cameraIntrinsicMatrix = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            options[.cameraIntrinsics] = cameraIntrinsicMatrix
          }
            
          let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: options)
            do {
                try handler.perform([self.visionRequest])
            } catch {
                print("Failed to perform Vision request: \(error)")
            }
        }
    }
}
