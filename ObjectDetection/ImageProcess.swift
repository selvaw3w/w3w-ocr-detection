//
//  ImageProcess.swift
//  ObjectDetection
//
//  Created by Lshiva on 19/04/2020.
//  Copyright © 2020 What3words. All rights reserved.
//

import UIKit
import CoreMedia
import Vision

class ImageProcess: NSObject {
    
    public var context = CIContext()
    
    // Image Buffer Size
    public var ImageBufferSize = CGSize(width: 1080, height: 1920)
    
    public var croppedRect = CGRect()

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
        croppedRect = CGRect(x: originX, y: originY, width: cropWidth, height: cropHeight)
        croppedRect = croppedRect.inset(by: UIEdgeInsets(top: 0.0, left: -20.0, bottom: 0.0, right: -50.0))
        let croppedImage = UIImage(cgImage: cropCGImage(croppedRect, pixelBuffer: cvPixelBuffer))
        return croppedImage
    }
    
    func covertScreenCoordinatestToImageCoordinates(frame: CGSize) -> CGSize {
        let width = frame.width
        let height = frame.height
        let scaleFactor = height/self.ImageBufferSize.height
        let scale = CGAffineTransform.identity.scaledBy(x: scaleFactor, y: scaleFactor)
        let offset = self.ImageBufferSize.width * scaleFactor - width
        let actualMarginWidth = -offset / 2.0
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: actualMarginWidth , y: -height)
        let size = frame.applying(scale.inverted()).applying(transform.inverted())
        return size
    }
    
    func convertImageCoordinatesToScreenCoordinates(point: CGPoint) {
    }
    
    func cropCGImage(_ rect: CGRect, pixelBuffer: CVPixelBuffer) -> CGImage {
        //TODO: add validation
        let ciiimage = ciImageFromPixelBuffer(pixelBuffer: pixelBuffer)
        context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciiimage, from: rect)
        return cgImage!
    }
    
    func ciImageFromPixelBuffer(pixelBuffer: CVPixelBuffer) -> CIImage {
        return CIImage(cvPixelBuffer: pixelBuffer)
    }
    
    func getCVPixelbuffer(from image: UIImage) -> CVPixelBuffer? {
      let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
      var pixelBuffer : CVPixelBuffer?
      let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
      guard (status == kCVReturnSuccess) else {
        return nil
      }

      CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
      let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

      let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
      let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

      context?.translateBy(x: 0, y: image.size.height)
      context?.scaleBy(x: 1.0, y: -1.0)

      UIGraphicsPushContext(context!)
      image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
      UIGraphicsPopContext()
      CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

      return pixelBuffer
    }
    
    func getMetaData(forImage image: UIImage) {
            guard let data = image.jpegData(compressionQuality: 1),
            let source = CGImageSourceCreateWithData(data as CFData, nil) else { return}

        if let type = CGImageSourceGetType(source) {
            print("type: \(type)")
        }

        if let properties = CGImageSourceCopyProperties(source, nil) {
            print("properties - \(properties)")
        }

        let count = CGImageSourceGetCount(source)
        print("count: \(count)")

        for index in 0..<count {
            if let metaData = CGImageSourceCopyMetadataAtIndex(source, index, nil) {
                print("all metaData[\(index)]: \(metaData)")

                let typeId = CGImageMetadataGetTypeID()
                print("metadata typeId[\(index)]: \(typeId)")


                if let tags = CGImageMetadataCopyTags(metaData) as? [CGImageMetadataTag] {

                    print("number of tags - \(tags.count)")

                    for tag in tags {
                        if let name = CGImageMetadataTagCopyName(tag) {
                            print("name: \(name)")
                        }
                        if let value = CGImageMetadataTagCopyValue(tag) {
                            print("value: \(value)")
                        }
                        if let prefix = CGImageMetadataTagCopyPrefix(tag) {
                            print("prefix: \(prefix)")
                        }
                        if let namespace = CGImageMetadataTagCopyNamespace(tag) {
                            print("namespace: \(namespace)")
                        }
                        if let qualifiers = CGImageMetadataTagCopyQualifiers(tag) {
                            print("qualifiers: \(qualifiers)")
                        }
                        print("-------")
                    }
                }
            }

            if let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) {
                print("properties[\(index)]: \(properties)")
            }
        }
    }
}
