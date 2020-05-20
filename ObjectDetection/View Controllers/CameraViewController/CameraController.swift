import CoreMedia
import CoreML
import UIKit
import Vision
import MessageUI
import SSZipArchive
import SnapKit
import GDPerformanceView_Swift


protocol CameraControllerProtocol: class {
    
    var onShowPhoto : (() -> Void)? { get set }
}

class CameraController: UIViewController, CameraControllerProtocol {
    
    var wGesture: WGesture!

    let maskLayer = CAShapeLayer()
    
    var threeWordBoxes = ThreeWordBoxes()
    
    var performanceView = PerformanceView()
    
    // MARK: - CameraControllerProtocol
    var onShowPhoto: (() -> Void)?
    // toggle multi 3wa detectionvi
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
    var coreml = W3wCoreMLModel()
    // Image Buffer Size
    private var ImageBufferSize = CGSize(width: 1080, height: 1920)
    // ocr
    var ocrmanager = OCRManager.sharedInstance
    // recognised text array
    var recognised3wa = [String]()
    // Render image
    private var context = CIContext()
    // maximum boundingboxes
    var maxBoundingBoxViews = 10
    // w3w suggestion view
    internal lazy var w3wSuggestionView : W3wSuggestionView = {
        let view = W3wSuggestionView()        
        return view
    }()
    
    // record button
    internal lazy var photobtn : UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 30
        button.layer.borderColor = UIColor.white.cgColor
        button.setBackgroundImage(UIImage(named: "Shutter_Button"), for: .normal)
        button.setBackgroundImage(UIImage(named: "closeBtn"), for: .selected)
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
    internal lazy var instructionLbl : UILabel = {
        let label = PaddingUILabel(withInsets: 8, 8, 8, 8)
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = Config.Font.Color.background
        label.text = "Frame the 3 word address you want to scan"
        label.textAlignment = .center
        label.font = label.font.withSize(12.0)
        label.sizeToFit()
        return label
    }()
    
    internal lazy var overlayView : UIView = {
        let overlayView = UIView()
        overlayView.backgroundColor = Config.Font.Color.overlaynonW3w
        overlayView.frame.size = self.view.frame.size
        return overlayView
    }()

    // set all views
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        view.isUserInteractionEnabled = true
        wGesture = WGesture(target: self, action: #selector((showDeveloperMode(gesture:))))
        view.addGestureRecognizer(wGesture)
        
        coreml.delegate = self
        w3wSuggestionView.delegate = self
        self.ocrmanager.setAreaOfInterest(viewBounds: self.view.bounds)
        self.setUpCamera()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PerformanceMonitor.shared().hide()
        PerformanceMonitor.shared().delegate = self
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        resizePreviewLayer()
    }
    
    @objc func showDeveloperMode(gesture: WGesture) {
       if gesture.state == .recognized {
            performanceView.show()
        }
    }
    
    func setup() {
        self.view.addSubview(overlayView)
        self.performanceView.add(overlayView)

        performanceView.snp.makeConstraints{ (make) in
            make.top.equalTo(self.overlayView).offset(20)
            make.left.equalTo(self.overlayView)
            make.width.equalTo(self.overlayView).dividedBy(2)
            make.height.equalTo(self.overlayView).dividedBy(2)
        }
        // set up capture button
        self.overlayView.addSubview(photobtn)
        photobtn.addTarget(self, action: #selector(self.capturePhoto), for: .touchUpInside)
        photobtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.overlayView).offset(-30)
            make.centerX.equalTo(self.videoPreview)
            make.width.height.equalTo(60)
        }

        // set up intro label
        self.overlayView.addSubview(self.instructionLbl)
        instructionLbl.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.photobtn.snp.top).offset(-30)
            make.centerX.equalTo(self.videoPreview)
            make.height.equalTo(30)
        }
        
        // set up report issue button
        self.navigationController?.navigationBar.addSubview(reportBtn)
        reportBtn.addTarget(self, action: #selector(self.reportIssue), for: .touchUpInside)
        reportBtn.snp.makeConstraints{(make) in
            make.top.equalTo(self.navigationController!.navigationBar).offset(15)
            make.width.equalTo(120)
            make.height.equalTo(45)
            make.right.equalTo(-20)
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        for (_ , threewordbox ) in threeWordBoxes.threeWordBoxes {
            guard let point = touch?.location(in: threewordbox.threeWordView) else {
                return
            }

            if (threewordbox.threeWordView?.bounds.contains(point))! {
                self.showSuggestionView(threeWordAddress: (threewordbox.threeWordView?.ThreeWordBoundingBoxLbl.text)!)
                self.videoCapture.pause()
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
                // Once everything is set up, we can start capturing live video.
                self.videoCapture.start()
            }
        }
    }
    
    @objc func capturePhoto(_ sender: UIButton) {
        photobtn.isSelected = !photobtn.isSelected
        if photobtn.isSelected {
            self.videoCapture.photoCapture()
            self.instructionLbl.text = "Tap to scan again"
            self.videoCapture.pause()
        } else {
            self.instructionLbl.text = "Frame the 3 word address you want to scan"
            self.didResumeVideoSession()
        }
    }
    
    @objc func reportIssue() {
        self.sendScreenshotEmail()
    }
}

//MARK: Video capture
extension CameraController: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame sampleBuffer: CMSampleBuffer) {
        imageProcess.updateImageBufferSize(sampleBuffer: sampleBuffer)
        coreml.predictVideo(sampleBuffer: sampleBuffer)
    }
    
    func photoCapture(_ capture: VideoCapture, didCapturePhotoFrame image: UIImage) {
        let pixelBuffer = imageProcess.getCVPixelbuffer(from: image)!
        coreml.predictPhoto(pixelBuffer: pixelBuffer)
    }
}

extension CameraController {

    func drawThreeWordBox() {
        let path = UIBezierPath(rect: self.view.bounds)
        for (threeWordAddress, threewordbox) in threeWordBoxes.threeWordBoxes {
            threewordbox.threeWordView?.show(frame: threewordbox.threeWordRect,
            label: "w3w", w3w: threeWordAddress,
            color: UIColor(displayP3Red: 1.0, green: 1.0, blue: 1.0, alpha: CGFloat(threewordbox.countDownTimer / Config.w3w.destructBBViewtimer)),
            textColor: UIColor(displayP3Red: 0.0, green: 0.0, blue: 0.0, alpha: CGFloat(threewordbox.countDownTimer / Config.w3w.destructBBViewtimer)))
            
            if threewordbox.countDownTimer > 1 {
                path.append(UIBezierPath(rect: threewordbox.threeWordRect))
            }
        
            threewordbox.threeWordView?.add(self.overlayView)
        }
        if threeWordBoxes.threeWordBoxes.count > 0 {
            maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
            maskLayer.path = path.cgPath
           // self.overlayView.layer.mask = maskLayer
        }
    }
}

//MARK: Process CoreML
extension CameraController: processPredictionsDelegate {
    func noPredictions() {
        let path = UIBezierPath(rect: self.view.bounds)
        maskLayer.fillRule = CAShapeLayerFillRule.nonZero
        maskLayer.path = path.cgPath
        //self.overlayView.layer.mask = maskLayer
        //boundingBoxes.removeBoundingBoxes()
        self.threeWordBoxes.removeBoundingBoxes()        
    }
    
    func showPredictions(predictions: [VNRecognizedObjectObservation]) {
        print("prediction:\(predictions.count)")
        for prediction in predictions {
            let width = self.view.frame.width
            let height = self.view.frame.height
            let scaleFactor = height/self.ImageBufferSize.height
            let scale = CGAffineTransform.identity.scaledBy(x: scaleFactor, y: scaleFactor)
            let offset = self.imageProcess.ImageBufferSize.width * scaleFactor - width
            let actualMarginWidth = -offset / 2.0
            let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: actualMarginWidth , y: -height)
            
            guard self.coreml.currentBuffer != nil else {
                return
            }
            let croppedImage = self.imageProcess.cropImage(prediction, cvPixelBuffer: self.coreml.currentBuffer!)
            let rect = self.imageProcess.croppedRect.applying(scale).applying(transform)
            let recognisedtext = self.ocrmanager.find_3wa(image: croppedImage)
            if !recognisedtext.isEmpty {
                threeWordBoxes.add(threeWordAddress: recognisedtext, rect: rect, parent: self.view)
            }
        }
            self.drawThreeWordBox()
            self.threeWordBoxes.removeBoundingBoxes()
    }
}

//MARK: Send Email
extension CameraController: MFMailComposeViewControllerDelegate {
    
    private func sendScreenshotEmail() {
        guard MFMailComposeViewController.canSendMail() else {
            showAlertWith(message: AlertMessage(title: "Error", body: "There is no email account registered"), style: .alert)
            return
        }
        
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        
        let emailTo = Config.w3w.sendEmail
        mailComposer.setSubject("Issue")
        mailComposer.setMessageBody("Hi, this image is not working.", isHTML: true)
        mailComposer.setToRecipients(emailTo)
        
        guard coreml.loadCurrentStatebuffer != nil else {
            return
        }
        
        let ciimage = CIImage(cvPixelBuffer: coreml.loadCurrentStatebuffer!)
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

extension CameraController: W3wSuggestionViewProtocol {
    func didResumeVideoSession() {
        self.videoCapture.resume()
        self.instructionLbl.text = "Frame the 3 word address you want to scan"
        self.photobtn.isSelected = false
    }
}

class ThreeWordBox {

    var threeWordAddress    : String
    var threeWordRect     : CGRect
    var threeWordView     : ThreeWordBoundingBoxView?
    var countDownTimer      : Int
    
    init(threeWordAddress: String, threeWordRect: CGRect, threeWordView: ThreeWordBoundingBoxView? = nil) {
        self.threeWordAddress = threeWordAddress
        self.threeWordRect = threeWordRect
        self.threeWordView = threeWordView
        self.countDownTimer = Config.w3w.destructBBViewtimer
    }
}


class ThreeWordBoxes {
    
    var threeWordBoxes : Dictionary<String,ThreeWordBox> = [:]
    
    func add(threeWordAddress: String, rect: CGRect, parent: UIView) {
        if threeWordBoxes[threeWordAddress] != nil {
            threeWordBoxes[threeWordAddress]?.countDownTimer = Config.w3w.destructBBViewtimer
            threeWordBoxes[threeWordAddress]?.threeWordRect = rect
        } else {
            let createboundingBoxView = ThreeWordBoundingBoxView()
            threeWordBoxes[threeWordAddress] = ThreeWordBox(threeWordAddress: threeWordAddress, threeWordRect: rect, threeWordView: createboundingBoxView)
        }
    }
    
    func remove(threeWordBox: ThreeWordBox) {
        threeWordBoxes.removeValue(forKey: threeWordBox.threeWordAddress)
    }
    
    func removeBoundingBoxes() {
        for (_, threeWordbox) in threeWordBoxes {
            threeWordbox.countDownTimer -= 1
            if threeWordbox.countDownTimer < 1 {
                self.remove(threeWordBox: threeWordbox)
                threeWordbox.threeWordView?.hide()
            }
        }
    }
}

extension CameraController : PerformanceMonitorDelegate {

    func performanceMonitor(didReport performanceReport: PerformanceReport) {
        performanceView.display(fps: performanceReport.fps, cpu: Int(performanceReport.cpuUsage), memory: performanceReport.memoryUsage)
    }
    
}
