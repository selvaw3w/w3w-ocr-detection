import CoreMedia
import CoreML
import UIKit
import Vision
import JJFloatingActionButton
import MessageUI
import SSZipArchive

class ScanViewController: UIViewController, StoryBoarded {
    
    weak var coordinator: MainCoordinator?
    // action button
    let actionButton = JJFloatingActionButton()
    // toggle multi 3wa detection
    var isMulti3wa = true
    // toggle all filter & w3w only
    var isallFilter = false
    // set up video preview view
    @IBOutlet var videoPreview: UIView!
    // set up video capture view
    var videoCapture: VideoCapture!
    // image process
    var imageProcess = ImageProcess()
    // set up core ml
    var coreML = W3wCoreMLModel()
    // Image Buffer Size
    private var ImageBufferSize = CGSize(width: 1080, height: 1920)
    // ocr
    var ocr = OCRManager.sharedInstance
    // Render image
    private var context = CIContext()
    // maximum boundingboxes
    var maxBoundingBoxViews = 15 {
        didSet {
            setUpBoundingBoxViews()
        }
    }
    // initialise bounding box view
    var boundingBoxViews = [BoundingBoxView]()
    // color range
    var colors: [String: UIColor] = [:]
    // set up minimum bounding box
    func setUpBoundingBoxViews() {
        for _ in 0..<maxBoundingBoxViews {
          boundingBoxViews.append(BoundingBoxView())
        }
        let labels = coreML.loadLabels()
        // Assign random colors to the classes.
        for label in labels {
            colors[label] = UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1)
        }
    }

    // set all views
    override func viewDidLoad() {
        super.viewDidLoad()
        coreML.delegate = self
        ocr.setAreaOfInterest(viewBounds: self.view.bounds)
        actionButton.delegate = self
        setUpActionButton()
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
}

//MARK: Menu button
extension ScanViewController: JJFloatingActionButtonDelegate {
     
     func setUpActionButton() {
         actionButton.addItem(title: "Report Issue", image: UIImage(systemName: "envelope.circle.fill")?.withRenderingMode(.alwaysTemplate)) { item in
             self.videoCapture.stop()
             self.sendScreenshotEmail()
         }

         actionButton.addItem(title: "Multi 3wa detection", image: UIImage(systemName: "doc.on.clipboard")?.withRenderingMode(.alwaysTemplate)) { item in
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
         
         actionButton.addItem(title: "all labels", image: UIImage(systemName: "doc.on.clipboard")?.withRenderingMode(.alwaysTemplate)) { item in
             self.isallFilter = !self.isallFilter
             if self.isallFilter {
                item.titleLabel.text = "w3w Label only"
                item.imageView.image = UIImage(systemName: "doc.on.clipboard")
             } else {
                item.titleLabel.text = "all labels"
                item.imageView.image = UIImage(systemName: "doc")
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
}

//MARK: Send Email
extension ScanViewController: MFMailComposeViewControllerDelegate {
    
    private func sendScreenshotEmail() {
        guard MFMailComposeViewController.canSendMail() else {
            fatalError("error sending email ")
        }
        
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        
        let emailTo = ["matt.stuttle+OCR@what3words.com"]
        mailComposer.setSubject("Issue")
        mailComposer.setMessageBody("Hi, this image is not working.", isHTML: true)
        mailComposer.setToRecipients(emailTo)
        
        guard coreML.loadCurrentStatebuffer != nil else {
            //TODO: show alert message
            return
        }
        
        let ciimage = CIImage(cvPixelBuffer: coreML.loadCurrentStatebuffer!)
        imageProcess.context = CIContext(options: nil)
        let cgImage = imageProcess.context.createCGImage(ciimage, from: CGRect(x: 0, y: 0, width: self.ImageBufferSize.width, height: self.ImageBufferSize.height))
        let imageObject = UIImage(cgImage: cgImage!)
        let imageData = imageObject.jpegData(compressionQuality: 1.0)
        
        mailComposer.addAttachmentData(imageData!, mimeType: "image/jpeg", fileName: "Image.jpeg")
        self.present(mailComposer, animated: true, completion: nil)
        
    }
    
    internal func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?){
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
}
//MARK: Video capture
extension ScanViewController: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame sampleBuffer: CMSampleBuffer) {
        imageProcess.updateImageBufferSize(sampleBuffer: sampleBuffer)
        coreML.predict(sampleBuffer: sampleBuffer)
    }
}

//MARK: Process CoreML 
extension ScanViewController: processPredictionsDelegate {
    func showPredictions(predictions: [VNRecognizedObjectObservation]) {
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
                if bestClass == "w3w" && (confidence * 100) > 80.0 {
                    if (coreML.currentBuffer != nil) {
                        let croppedImage = imageProcess.cropImage(prediction, cvPixelBuffer: coreML.currentBuffer!)
                        let recognisedtext = ocr.find_3wa(image: croppedImage)
                        guard recognisedtext.isEmpty else {
                            boundingBoxViews[i].show(frame: rect, label: label, w3w: recognisedtext, color: color)
                            return
                        }
                    }
                }
            } else {
                boundingBoxViews[i].hide()
            }
        }
    }
}


