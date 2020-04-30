import CoreMedia
import CoreML
import UIKit
import Vision
import MessageUI
import SSZipArchive
import SnapKit

class ScanViewController: UIViewController, StoryBoarded {
        
    weak var coordinator: MainCoordinator?
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
    var ocrmanager = OCRManager.sharedInstance
    // recognised text array
    var recognised3wa = [String]()
    // Render image
    private var context = CIContext()
    // initialise bounding box view
    var boundingBoxViews = [BoundingBoxView]()
    // color range
    var colors: [String: UIColor] = [:]
    // maximum boundingboxes
    var maxBoundingBoxViews = 10 {
        didSet {
            setUpBoundingBoxViews()
        }
    }
    
    // record button
    internal lazy var capturebtn : UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 30
        button.layer.borderWidth = 2.0
        button.layer.borderColor = UIColor.white.cgColor
        button.setBackgroundImage(UIImage(named: "circleBtn"), for: .normal)
        button.clipsToBounds = true

        return button
    }()
    
    // report issue button
    internal lazy var reportBtn : UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = Config.Font.Color.background
        button.setTitle("Report an issue", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: Config.Font.type.sourceLight, size: 14.0)
        button.clipsToBounds = true
        return button
    }()
    
    // intro text
    internal lazy var introLbl : UILabel = {
        let label = PaddingUILabel(withInsets: 8, 8, 8, 8)
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = true
        label.text = "Frame the 3 word address you want to scan"
        label.backgroundColor = Config.Font.Color.background
        label.textAlignment = .center
        label.font = label.font.withSize(12.0)
        label.sizeToFit()
        return label
    }()
    
    internal lazy var overlayView : OverlayView = {
        let overlayView = OverlayView()
        overlayView.backgroundColor = UIColor .clear
        overlayView.frame.size = self.view.frame.size
        return overlayView
    }()
    // Selected Area
    internal var selectedarea : CGRect = CGRect.zero {
        didSet {
            self.overlayView.selectedArea = selectedarea
        }
    }
    // set all views
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        coreML.delegate = self
        self.ocrmanager.setAreaOfInterest(viewBounds: self.view.bounds)
        self.setUpBoundingBoxViews()
        self.setUpCamera()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        resizePreviewLayer()
    }
    
    func setup() {
        //preview view background color
        self.view.addSubview(overlayView)
        
        // set up intro label
        self.view.addSubview(introLbl)
        introLbl.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.videoPreview).offset(-30)
            make.centerX.equalTo(self.videoPreview)
            make.height.equalTo(30)
        }
        
        // set up report issue button
        self.view.addSubview(reportBtn)
        reportBtn.addTarget(self, action: #selector(self.reportIssue), for: .touchUpInside)

        reportBtn.snp.makeConstraints{(make) in
            make.top.equalTo(self.overlayView).offset(50)
            make.width.equalTo(120)
            make.height.equalTo(45)
            make.right.equalTo(-20)
        }
        
        // set up capture button
        self.view.addSubview(capturebtn)
        capturebtn.addTarget(self, action: #selector(self.startCapture), for: .touchUpInside)
        capturebtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.introLbl).offset(-60)
            make.centerX.equalTo(self.videoPreview)
            make.width.height.equalTo(60)
        }
    }
    
    // set up maximum bounding box
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
    
    @objc func startCapture() {
        videoCapture.photoCapture()
    }
    
    @objc func reportIssue() {
        self.sendScreenshotEmail()
    }
}

//MARK: Video capture
extension ScanViewController: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame sampleBuffer: CMSampleBuffer) {
        imageProcess.updateImageBufferSize(sampleBuffer: sampleBuffer)
        coreML.predictVideo(sampleBuffer: sampleBuffer)
    }
    
    func photoCapture(_ capture: VideoCapture, didCapturePhotoFrame image: UIImage) {
        // Get CVPixel buffer from image
        let pixelBuffer = imageProcess.getCVPixelbuffer(from: image)!
        // send for prediction
        coreML.predictPhoto(pixelBuffer: pixelBuffer)
    }
}

//MARK: Process CoreML
extension ScanViewController: processPredictionsDelegate {
    func showPredictions(predictions: [VNRecognizedObjectObservation]) {

        for i in 0..<boundingBoxViews.count {
            if i < predictions.count {
                let prediction = predictions[i]
                
                let originX = prediction.boundingBox.minX * ImageBufferSize.width
                let originY = prediction.boundingBox.minY * ImageBufferSize.height
                let cropWidth = (prediction.boundingBox.maxX - prediction.boundingBox.minX) * ImageBufferSize.width
                let cropHeight = (prediction.boundingBox.maxY-prediction.boundingBox.minY)*ImageBufferSize.height
                let cropRect1 = CGRect(x: originX, y: originY, width: cropWidth, height: cropHeight)

        
                let width = view.frame.width
                let height = view.frame.height
                let scaleFactor = height/ImageBufferSize.height
                let scale = CGAffineTransform.identity.scaledBy(x: scaleFactor, y: scaleFactor)
                let offset = ImageBufferSize.width * scaleFactor - width
                let actualMarginWidth = -offset / 2.0
                let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: actualMarginWidth , y: -height)
                let rect = cropRect1.applying(scale).applying(transform)

                let bestClass = prediction.labels[0].identifier
                let confidence = prediction.labels[0].confidence
                
                // Display the bounding box.
                let label = String(format: "%@ %.1f", bestClass, confidence * 100)
                //let color = colors[bestClass] ?? UIColor.red
                if bestClass == "w3w" && (confidence * 100) > 75.0 {
                    if (coreML.currentBuffer != nil) {
                        let croppedImage = imageProcess.cropImage(prediction, cvPixelBuffer: coreML.currentBuffer!)
                        let recognisedtext = ocrmanager.find_3wa(image: croppedImage)
                        guard recognisedtext.isEmpty else {
                            boundingBoxViews[i].show(frame: rect, label: label, w3w: recognisedtext, color: UIColor(displayP3Red: 0.426976, green: 0.882479, blue: 0.143794, alpha: 1.0))
                            self.selectedarea = rect
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
