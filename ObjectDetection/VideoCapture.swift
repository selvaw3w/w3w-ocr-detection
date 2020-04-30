import AVFoundation
import CoreVideo
import UIKit

public protocol VideoCaptureDelegate: class {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame: CMSampleBuffer)
    
    func photoCapture(_ capture: VideoCapture, didCapturePhotoFrame: UIImage)
}

public class VideoCapture: NSObject {
    // preview layer
    public var previewLayer: AVCaptureVideoPreviewLayer?
    // set up video capture delegate
    public weak var delegate: VideoCaptureDelegate?
        
    let captureSession = AVCaptureSession()
    
    let videoOutput = AVCaptureVideoDataOutput()
    
    let photoOutput = AVCapturePhotoOutput()
        
    var deviceOrientationOnCapture = UIDevice.current.orientation
    
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

        let photoMetadata = photo.metadata
        
        print("Metadata orientation with key: \(photoMetadata[String(kCGImagePropertyOrientation)] as Any)")
        
        guard let cgiImage = photo.cgImageRepresentation()?.takeUnretainedValue() else {
            fatalError("Error: while generating image from photo capture data.")
        }
        
        let currentCIImage = CIImage(cgImage: cgiImage)
        
        let rotateCIImage = currentCIImage.oriented(forExifOrientation: Int32(deviceOrientationOnCapture.getCIImageOrientationFromDevice().rawValue))

        guard let cgImage = CIContext(options: nil).createCGImage(rotateCIImage, from: rotateCIImage.extent) else {
            fatalError("Error: while generating cgimage from photo capture data")
        }
        
        let image = UIImage(cgImage: cgImage)

        delegate?.photoCapture(self, didCapturePhotoFrame: image)
    }
    
    public func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("Just about to take a photo.")
        // get device orientation on capture
        self.deviceOrientationOnCapture = UIDevice.current.orientation
        print("Device orientation: \(self.deviceOrientationOnCapture.rawValue)")
    }
}


extension UIDeviceOrientation {
    
    func getCIImageOrientationFromDevice() -> UIImage.Orientation {
        switch UIDevice.current.orientation {
            case .portrait, .faceUp:
                print(UIImage.Orientation.init(rawValue: 6) as Any)
                return UIImage.Orientation.init(rawValue: 6)!
            case .landscapeLeft :
                print(UIImage.Orientation.init(rawValue: 3) as Any)
                return UIImage.Orientation.init(rawValue: 3)!
            case .landscapeRight :
                print(UIImage.Orientation.init(rawValue: 1) as Any)
                return UIImage.Orientation.init(rawValue: 1)!
            case .unknown:
                print(UIImage.Orientation.init(rawValue: 1) as Any)
                return UIImage.Orientation.init(rawValue: 1)!
            case .portraitUpsideDown, .faceDown:
                print(UIImage.Orientation.init(rawValue: 1) as Any)
                return UIImage.Orientation.init(rawValue: 1)!
        @unknown default:
            return UIImage.Orientation.init(rawValue: 6)!
        }
    }
    
    // TOOD: Incase in future to rotate UIImage from current device orientation.
    func getUIImageOrientationFromDevice() -> UIImage.Orientation {
        // return CGImagePropertyOrientation based on Device Orientation
        // This extented function has been determined based on experimentation with how an UIImage gets displayed.
        switch self {
        case UIDeviceOrientation.portrait, .faceUp:
            print("UIDeviceOrientation.portrait")
            return UIImage.Orientation.right
        case UIDeviceOrientation.portraitUpsideDown, .faceDown:
            print("UIDeviceOrientation.portraitUpsideDown")
            return UIImage.Orientation.left
        case UIDeviceOrientation.landscapeLeft:
            print("UIDeviceOrientation.landscapeLeft")
            return UIImage.Orientation.up
        case UIDeviceOrientation.landscapeRight:
            print("UIDeviceOrientation.landscapeRight")
            return UIImage.Orientation.down
        case UIDeviceOrientation.unknown:
            print("UIDeviceOrientation.unknown")
            return UIImage.Orientation.up
        @unknown default:
            fatalError("no orientation found")
        }
    }
}
