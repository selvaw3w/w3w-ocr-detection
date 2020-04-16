import CoreMedia
import CoreML
import UIKit
import Vision
import ocrsdk
import what3words
import JJFloatingActionButton
import MessageUI

class ViewController: UIViewController, MFMailComposeViewControllerDelegate, JJFloatingActionButtonDelegate {

    // action button
    let actionButton = JJFloatingActionButton()
    // toggle multi 3wa detection
    var isMulti3wa = true
    // set up video preview view
    @IBOutlet var videoPreview: UIView!
    // w3w SDK
    var w3wEngine: W3wEngine? = nil
    // ocr Engine
    var ocrEngine: W3WOCREngine? = nil
    // set up video capture view
    var videoCapture: VideoCapture!
    // Image Buffer Sizeiter    private var ImageBufferSize = CGSize(width: 1080, height: 1920)
    // current pixel buffer
    var currentBuffer: CVPixelBuffer?
    // save current state to send via email
    var savedBuffer: CVPixelBuffer?
    // Render image
    private var context = CIContext()
    // Initialise coreML model
    let w3wMLModel   = w3w()
    // current bounding box
    var currentBBox = Int()
    // load coreML model
    lazy var visionModel: VNCoreMLModel = {
        do {
          return try VNCoreMLModel(for: w3wMLModel.model)
        } catch {
          fatalError("Failed to create VNCoreMLModel: \(error)")
        }
    }()
    // make new vision Request
    lazy var visionRequest: VNCoreMLRequest = {
        let request = VNCoreMLRequest(model: visionModel, completionHandler: {
        [weak self] request, error in
        self?.processObservations(for: request, error: error)
        })

        request.imageCropAndScaleOption = .scaleFill
        return request
    }()
    // maximum boundingboxes
    var maxBoundingBoxViews = 10 {
        didSet {
            setUpBoundingBoxViews()
        }
    }
    // initialise bounding box view
    var boundingBoxViews = [BoundingBoxView]()
    // color range
    var colors: [String: UIColor] = [:]
    // recognition text
    public var recogText = String()
    // observer
    var observer:NSKeyValueObservation?
    func setUpBoundingBoxViews() {
        for _ in 0..<maxBoundingBoxViews {
          boundingBoxViews.append(BoundingBoxView())
        }
        // The label names are stored inside the MLModel's metadata.
        guard let userDefined = w3wMLModel.model.modelDescription.metadata[MLModelMetadataKey.creatorDefinedKey] as? [String: String],
           let allLabels = userDefined["classes"] else {
          fatalError("Missing metadata")
        }
        // load all the labels
        let labels = allLabels.components(separatedBy: ",")
            // Assign random colors to the classes.
            for label in labels {
              colors[label] = UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1)
        }
    }

    //MARK: set all views
    override func viewDidLoad() {
        super.viewDidLoad()
        actionButton.delegate = self
        setUpActionButton()
        setUpEngines()
        setUpBoundingBoxViews()
        setUpCamera()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        resizePreviewLayer()
    }

    func resizePreviewLayer() {
        videoCapture.previewLayer?.frame = videoPreview.bounds
    }
    // set upaction buttons
    func setUpActionButton() {
        actionButton.addItem(title: "Report Issue", image: UIImage(systemName: "envelope.circle.fill")?.withRenderingMode(.alwaysTemplate)) { item in
            self.videoCapture.stop()
          if( MFMailComposeViewController.canSendMail() ) {
            print("Can send email.")

            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            let toRecipents = ["matt.stuttle+OCR@what3words.com"]
            //Set the subject and message of the email
            mailComposer.setSubject("Issue")
            mailComposer.setMessageBody("Hi, this image is not working.", isHTML: true)
            mailComposer.setToRecipients(toRecipents)
            if (self.savedBuffer != nil) {
                let ciiimage = CIImage(cvPixelBuffer: self.savedBuffer!)
                self.context = CIContext(options: nil)
                let cgImage = self.context.createCGImage(ciiimage, from: CGRect(x: 0, y: 0, width: self.ImageBufferSize.width, height: self.ImageBufferSize.height))
                let imageObject = UIImage(cgImage: cgImage!)
                let imageData = imageObject.jpegData(compressionQuality: 1.0)
                mailComposer.addAttachmentData(imageData!, mimeType: "image/jpeg", fileName: "Image.jpeg")
                self.present(mailComposer, animated: true, completion: nil)
            } else {
                print("current buffer nil")
            }
          }
        }

        actionButton.addItem(title: "Multi 3wa detection", image: UIImage(systemName: "doc.on.clipboard")?.withRenderingMode(.alwaysTemplate)) { item in
          // toggle button
            self.isMulti3wa = !self.isMulti3wa
            if self.isMulti3wa {
                item.titleLabel.text = "Multi 3wa detection"
                item.imageView.image = UIImage(systemName: "doc.on.clipboard")
                self.maxBoundingBoxViews = 10
          } else {
                item.titleLabel.text = "Single 3wa detection"
                item.imageView.image = UIImage(systemName: "doc")
                self.maxBoundingBoxViews = 1
                
          }
        }
        view.addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
    }
    
    func floatingActionButtonDidClose(_ button: JJFloatingActionButton) {
        videoCapture.start()
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?){
        switch result.rawValue {
            case MFMailComposeResult.cancelled.rawValue:
                print("Mail cancelled")
                controller.dismiss(animated: true, completion: nil)
            case MFMailComposeResult.saved.rawValue:
                print("Mail saved")
                controller.dismiss(animated: true, completion: nil)
            case MFMailComposeResult.sent.rawValue:
                print("Mail sent")
                controller.dismiss(animated: true, completion: nil)
            case MFMailComposeResult.failed.rawValue:
                print("Mail sent failure.")
                controller.dismiss(animated: true, completion: nil)
            default:
                break
            }
            controller.dismiss(animated: true, completion: nil)
            videoCapture.start()
    }

    //MARK: Load w3w & OCR engines
    func setUpEngines() {
        w3wEngine = try? W3wEngine.newDeviceEngine()
        let tessdataPath = copyFolders()
        ocrEngine = try? W3WOCREngine.newOcrEngine(languageCode: "en", tessdataPath: "\(tessdataPath)/tessdata", coreSDK: w3wEngine!)
        print("w3wsdk version:\(String(describing: w3wEngine?.version))")
        print("ocrsdk version:\(String(describing: ocrEngine?.version))")
        self.ocrEngine?.setAreaOfInterest(self.view.bounds)
    }
    
    //MARK: Set up camera
    func setUpCamera() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.setUp(sessionPreset: .high) { success in
            if success {
                // Add the video preview into the UI.
                if let previewLayer = self.videoCapture.previewLayer {
                    self.videoPreview.layer.addSublayer(previewLayer)
                    self.resizePreviewLayer()
                }
                // Add the bounding box layers to the UI, on top of the video preview.
                for box in self.boundingBoxViews {
                    box.addToLayer(self.videoPreview.layer)
                }
                // Once everything is set up, we can start capturing live video.
                self.videoCapture.start()
            }
        }
    }

    func predict(sampleBuffer: CMSampleBuffer) {
        if currentBuffer == nil, let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
          currentBuffer = pixelBuffer
          savedBuffer = currentBuffer
          // Get additional info from the camera.
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
    
    func processObservations(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            if let results = request.results as? [VNRecognizedObjectObservation] {
                self.show(predictions: results)
                self.currentBuffer = nil
            } else {
                self.show(predictions: [])
            }
        }
    }

    func show(predictions: [VNRecognizedObjectObservation]) {
        // current frame
        for i in 0..<boundingBoxViews.count {
            if i < predictions.count {
                let prediction = predictions[i]
                let width = view.frame.width
                let height = view.frame.height
                let scale = CGAffineTransform.identity.scaledBy(x: width, y: height)
                let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -height)
                let rect = prediction.boundingBox.applying(scale).applying(transform)

                let bestClass = prediction.labels[0].identifier
                let confidence = prediction.labels[0].confidence

                // Display the bounding box.
                let label = String(format: "%@ %.1f", bestClass, confidence * 100)
                let color = colors[bestClass] ?? UIColor.red
                if bestClass == "w3w" && (confidence * 100) > 98.0 {
                    // crop the image to send to ocrsdk
                    let originX = prediction.boundingBox.minX * ImageBufferSize.width
                    let originY = prediction.boundingBox.minY * ImageBufferSize.height
                    let cropWidth = (prediction.boundingBox.maxX - prediction.boundingBox.minX) * ImageBufferSize.width
                    let cropHeight = (prediction.boundingBox.maxY-prediction.boundingBox.minY)*ImageBufferSize.height
                    let cropRect = CGRect(x: originX, y: originY, width: cropWidth, height: cropHeight)
                    if (currentBuffer != nil) {
                        let ciiimage = CIImage(cvPixelBuffer: currentBuffer!)
                        context = CIContext(options: nil)
                        let cgImage = context.createCGImage(ciiimage, from: cropRect)
                        let croppedImage = UIImage(cgImage: cgImage!)
                        let recognisedtext = self.ocrEngine?.find_3wa(imageFromBuffer: croppedImage)
                        guard (recognisedtext == nil || recognisedtext == "" ) else {
                            boundingBoxViews[i].show(frame: rect, label: label, w3w: recognisedtext!, color: color)
                            return
                        }
                    }
                }
            } else {
                boundingBoxViews[i].hide()
            }
        }
    }

    func cropImage(_ rect: CGRect, sampleBuffer: CMSampleBuffer) -> UIImage {
        let ciImage =  self.imageFromSampleBuffer(sampleBuffer: sampleBuffer)
        context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciImage, from: rect)
        return UIImage(cgImage: cgImage!)
    }

    private func imageFromSampleBuffer(sampleBuffer:CMSampleBuffer) ->  CIImage {
        // Create a CIImage from the image buffer
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        return CIImage(cvPixelBuffer: imageBuffer!)
    }
    
    func updateImageBufferSize(sampleBuffer: CMSampleBuffer) {
        // get the image buffer size and set
        let width = CVPixelBufferGetWidth(CMSampleBufferGetImageBuffer(sampleBuffer)!);
        let height = CVPixelBufferGetHeight(CMSampleBufferGetImageBuffer(sampleBuffer)!);
        ImageBufferSize = CGSize(width: width, height: height)
    }
    
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
                print(filename)
            }
        } catch {
            print("\nError\n")
        }
    }
}

extension ViewController: VideoCaptureDelegate {
    
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame sampleBuffer: CMSampleBuffer) {
        // update image buffer size
        updateImageBufferSize(sampleBuffer: sampleBuffer)
        predict(sampleBuffer: sampleBuffer)
    }
}
