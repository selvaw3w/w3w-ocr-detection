import AVFoundation
import CoreVideo
import UIKit

public protocol VideoCaptureDelegate: class {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame: CMSampleBuffer)
    
    func photoCapture(_ capture: VideoCapture, didCapturePhotoFrame: CMSampleBuffer)
    
    //Test UIImage
    //func photoCapture(_ capture: VideoCapture, didCapturePhotoImage: UIImage)
}

public class VideoCapture: NSObject {
    // preview layer
    public var previewLayer: AVCaptureVideoPreviewLayer?
    // set up video capture delegate
    public weak var delegate: VideoCaptureDelegate?
        
    let captureSession = AVCaptureSession()
    
    let videoOutput = AVCaptureVideoDataOutput()
    
    let photoOutput = AVCapturePhotoOutput()
    
    let queue = DispatchQueue(label: "net.what3words.camera-queue")
    
    // setup video format
    public func setUp(sessionPreset: AVCaptureSession.Preset = .medium, completion: @escaping (Bool) -> Void) {
        queue.async {
        let success = self.setUpCamera(sessionPreset: sessionPreset)
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }

    func setUpCamera(sessionPreset: AVCaptureSession.Preset) -> Bool {

        captureSession.beginConfiguration()
        captureSession.sessionPreset = sessionPreset

        // setup video device input
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("Error: no video devices available")
            return false
        }
        setUpDeviceInput(captureDevice)
        setUpPreviewLayer()
        setUpDeviceOutput()
        videoOutput.connection(with: AVMediaType.video)?.videoOrientation = .portrait

        captureSession.commitConfiguration()

        return true
  }
    
    // setup video device input
    func setUpDeviceInput(_ device: AVCaptureDevice) {
        do {
            let videoDeviceInput: AVCaptureDeviceInput
            do {
                    videoDeviceInput = try AVCaptureDeviceInput(device: device)
            }
            catch {
                fatalError("Could not create AVCaptureDeviceInput instance with error: \(error).")
            }
            guard captureSession.canAddInput(videoDeviceInput) else {
                fatalError("could not add video deviceninput")
            }
            captureSession.addInput(videoDeviceInput)
        }
    }
    
    func setUpPreviewLayer() {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        //TODO: check the option to include - previewLayer.contentsGravity = CALayerContentsGravity.resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
        self.previewLayer = previewLayer
    }
    
    func setUpDeviceOutput() {
        // video output
        let settings: [String : Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA)
        ]

        videoOutput.videoSettings = settings
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: queue)
    
        guard captureSession.canAddOutput(videoOutput) else {
            fatalError("Could not add video output")
        }
        
        captureSession.addOutput(videoOutput)
        
        // photo output
        guard captureSession.canAddOutput(photoOutput) else {
            fatalError("couldn't add photo output")
        }
        photoOutput.isHighResolutionCaptureEnabled = true        
        captureSession.addOutput(photoOutput)
    }
    
    public func start() {
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    public func stop() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
  
    public func photoCapture() {

        let settings = AVCapturePhotoSettings()
        
        settings.isHighResolutionPhotoEnabled = false
        
        //let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        
        let previewFormat = [
            kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA),
        ] as [String : Any]
        
        settings.previewPhotoFormat = previewFormat
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension VideoCapture: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.videoCapture(self, didCaptureVideoFrame: sampleBuffer)
    }

    public func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("get frame dropped reason")
  }
}

extension VideoCapture: AVCapturePhotoCaptureDelegate {
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let error = error {
            fatalError("Capture failed: \(error.localizedDescription)")
        }
    }
}
