//
//  ImageProcess.swift
//  ObjectDetection
//
//  Created by Lshiva on 19/04/2020.
//  Copyright © 2020 MachineThink. All rights reserved.
//

import UIKit
import CoreMedia
import Vision

class ImageProcess: NSObject {
    
    public var context = CIContext()
    
    // Image Buffer Size
    private var ImageBufferSize = CGSize(width: 1080, height: 1920)

    override init() {
        super.init()
    }
    
    func updateImageBufferSize(sampleBuffer: CMSampleBuffer) {
        // get the image buffer size and set
        let width = CVPixelBufferGetWidth(CMSampleBufferGetImageBuffer(sampleBuffer)!);
        let height = CVPixelBufferGetHeight(CMSampleBufferGetImageBuffer(sampleBuffer)!);
        ImageBufferSize = CGSize(width: width, height: height)
    }
    
    //crop image
    func cropImage(_ prediction: VNRecognizedObjectObservation, cvPixelBuffer: CVPixelBuffer) -> UIImage  {
        let originX = prediction.boundingBox.minX * ImageBufferSize.width
        let originY = prediction.boundingBox.minY * ImageBufferSize.height
        let cropWidth = (prediction.boundingBox.maxX - prediction.boundingBox.minX) * ImageBufferSize.width
        let cropHeight = (prediction.boundingBox.maxY-prediction.boundingBox.minY)*ImageBufferSize.height
        let rect = CGRect(x: originX, y: originY, width: cropWidth, height: cropHeight)
        
        let croppedImage = UIImage(cgImage: cropRect(rect, pixelBuffer: cvPixelBuffer))
        return croppedImage
    }
    
    func cropRect(_ rect: CGRect, pixelBuffer: CVPixelBuffer) -> CGImage {
        //TODO: add validation
        let ciiimage = ciImageFromPixelBuffer(pixelBuffer: pixelBuffer)
        context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciiimage, from: rect)
        return cgImage!
    }
    
    func ciImageFromPixelBuffer(pixelBuffer: CVPixelBuffer) -> CIImage {
        return CIImage(cvPixelBuffer: pixelBuffer)
    }
}
