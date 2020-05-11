import CoreMedia
import CoreML
import UIKit
import Vision
import MessageUI
import SSZipArchive
import SnapKit

protocol CameraControllerProtocol: class {
    
    var onShowPhoto : (() -> Void)? { get set }
}

protocol CameraController3wa: class {
    func didSelect(threeWordAddress: String)
}

class CameraController: UIViewController, CameraControllerProtocol {

    //var viewModel : CameraViewModel?
    // MARK: - CameraControllerProtocol
    var onShowPhoto: (() -> Void)?
    
    weak var delegate: CameraController3wa?
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
    // w3w suggestion view
    internal lazy var w3wSuggestionView : W3wSuggestionView = {
        let view = W3wSuggestionView()        
        return view
    }()
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
    internal var boundingBox : CGRect = CGRect.zero {
        didSet {
            self.overlayView.boundingBox = boundingBox
        }
    }
    // set all views
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        //viewModel = CameraViewModel(config: ocrmanager)
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
        self.overlayView.addSubview(introLbl)
        introLbl.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.videoPreview).offset(-30)
            make.centerX.equalTo(self.videoPreview)
            make.height.equalTo(30)
        }
        
        // set up report issue button
        self.navigationController?.navigationBar.addSubview(reportBtn)
        //self.overlayView.addSubview(reportBtn)
        reportBtn.addTarget(self, action: #selector(self.reportIssue), for: .touchUpInside)
        reportBtn.snp.makeConstraints{(make) in
            make.top.equalTo(self.navigationController!.navigationBar).offset(15)
            make.width.equalTo(120)
            make.height.equalTo(45)
            make.right.equalTo(-20)
        }
        
        // set up capture button
        self.overlayView.addSubview(capturebtn)
        capturebtn.addTarget(self, action: #selector(self.startCapture), for: .touchUpInside)
        capturebtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.introLbl).offset(-60)
            make.centerX.equalTo(self.videoPreview)
            make.width.height.equalTo(60)
        }
    }
    
    func showSuggestionView(threeWordAddress: String) {
        // set up w3w suggestion view
        self.w3wSuggestionView.alpha = 0.0
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseIn, animations: {
            self.w3wSuggestionView.alpha = 1.0
            self.w3wSuggestionView.selected3Wa = threeWordAddress
            self.overlayView.addSubview(self.w3wSuggestionView)
            self.w3wSuggestionView.snp.makeConstraints { (make) in
                make.bottom.equalTo(self.overlayView)
                make.width.equalTo(self.overlayView)
                make.height.equalTo(self.overlayView).dividedBy(2.5)
            }
        }, completion: nil)
    
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        guard let point = touch?.location(in: self.overlayView) else {
            return
        }
        
        for view in boundingBoxViews {
            guard let sublayer = view.shapeLayer as? CAShapeLayer else {
                return
            }
            if let path = sublayer.path, path.contains(point) {
                self.showSuggestionView(threeWordAddress: view.w3wLayer.string as! String)
            }
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
                    box.addToLayer(self.overlayView.layer)
                }
                // Once everything is set up, we can start capturing live video.
                self.videoCapture.start()
            }
        }
    }
    
    @objc func startCapture() {
        self.overlayView.addSubview(self.w3wSuggestionView)
        //self.videoCapture.photoCapture()
    }
    
    @objc func reportIssue() {
        self.sendScreenshotEmail()
    }
}

//MARK: Video capture
extension CameraController: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame sampleBuffer: CMSampleBuffer) {
        imageProcess.updateImageBufferSize(sampleBuffer: sampleBuffer)
        coreML.predictVideo(sampleBuffer: sampleBuffer)
    }
    
    func photoCapture(_ capture: VideoCapture, didCapturePhotoFrame image: UIImage) {
        let pixelBuffer = imageProcess.getCVPixelbuffer(from: image)!
        coreML.predictPhoto(pixelBuffer: pixelBuffer)
        //self.videoCapture.stop()
        //self.onShowPhoto?()
//        self.coordinator?.photo(to: image)
    }
}

//MARK: Process CoreML
extension CameraController: processPredictionsDelegate {
    func showPredictions(predictions: [VNRecognizedObjectObservation]) {
        UIView.animate(withDuration: 0.1) {
            for i in 0..<self.boundingBoxViews.count {
                if i < predictions.count {
                    let prediction = predictions[i]
                    let width = self.view.frame.width
                    let height = self.view.frame.height
                    let scaleFactor = height/self.ImageBufferSize.height
                    let scale = CGAffineTransform.identity.scaledBy(x: scaleFactor, y: scaleFactor)
                    let offset = self.imageProcess.ImageBufferSize.width * scaleFactor - width
                    let actualMarginWidth = -offset / 2.0
                    let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: actualMarginWidth , y: -height)

                    let bestClass = prediction.labels[0].identifier
                    let confidence = prediction.labels[0].confidence
                    
                    // Display the bounding box.
                    let label = String(format: "%@ %.1f", bestClass, confidence * 100)
                    //let color = colors[bestClass] ?? UIColor.red
                    if bestClass == "w3w" && (confidence * 100) > 75.0 {
                        if (self.coreML.currentBuffer != nil) {
                            let croppedImage = self.imageProcess.cropImage(prediction, cvPixelBuffer: self.coreML.currentBuffer!)
                            let rect = self.imageProcess.croppedRect.applying(scale).applying(transform)
                            let recognisedtext = self.ocrmanager.find_3wa(image: croppedImage)
                            guard recognisedtext.isEmpty else {
                                self.boundingBoxViews[i].show(frame: rect, label: label, w3w: "///\(recognisedtext)", color: UIColor.white)
                                //self.boundingBox = rect
                                return
                            }
                        }
                    }
                } else {
                    self.boundingBoxViews[i].hide()
                }
            }
        }
    }
}

//MARK: Send Email
extension CameraController: MFMailComposeViewControllerDelegate {
    
    private func sendScreenshotEmail() {
        guard MFMailComposeViewController.canSendMail() else {
            fatalError("error sending email ")
        }
        
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        
        let emailTo = Config.w3w.sendEmail
        mailComposer.setSubject("Issue")
        mailComposer.setMessageBody("Hi, this image is not working.", isHTML: true)
        mailComposer.setToRecipients(emailTo)
        
        guard coreML.loadCurrentStatebuffer != nil else {
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
                DLog("Mail cancelled")
                controller.dismiss(animated: true, completion: nil)
            case MFMailComposeResult.saved.rawValue:
                DLog("Mail saved")
                controller.dismiss(animated: true, completion: nil)
            case MFMailComposeResult.sent.rawValue:
                DLog("Mail sent")
                controller.dismiss(animated: true, completion: nil)
            case MFMailComposeResult.failed.rawValue:
                DLog("Mail sent failure")
                controller.dismiss(animated: true, completion: nil)
            default:
                break
            }
            controller.dismiss(animated: true, completion: nil)
            videoCapture.start()
    }
}
