//
//  ObjectDetectionTests.swift
//  ObjectDetectionTests
//
//  Created by Lshiva on 14/05/2020.
//  Copyright © 2020 What3words. All rights reserved.
//

import XCTest
import CoreMedia

@testable import ObjectDetection

class ObjectDetectionTests: XCTestCase {
    
    var imageProcess = ImageProcess()
    var width   = 100
    var height  = 150
    
    override func setUp() {
        super.setUp()
        let sampleBuffer = getCMSampleBuffer()
        imageProcess.updateImageBufferSize(sampleBuffer: sampleBuffer)
        XCTAssertEqual(imageProcess.ImageBufferSize.width, CGFloat(self.width), "the image buffer size is correct")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {

    }
    
    fileprivate func getCMSampleBuffer() -> CMSampleBuffer {
        var pixelBuffer : CVPixelBuffer? = nil
        CVPixelBufferCreate(kCFAllocatorDefault, self.width, self.height, kCVPixelFormatType_32BGRA, nil, &pixelBuffer)
        
        var info = CMSampleTimingInfo()
        info.presentationTimeStamp = CMTime.zero
        info.duration = CMTime.invalid
        info.decodeTimeStamp = CMTime.invalid

        var formatDesc: CMFormatDescription? = nil
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer!, formatDescriptionOut: &formatDesc)

        var sampleBuffer: CMSampleBuffer? = nil

        CMSampleBufferCreateReadyWithImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer!, formatDescription: formatDesc!, sampleTiming: &info, sampleBufferOut: &sampleBuffer);
        return sampleBuffer!
    }

}
