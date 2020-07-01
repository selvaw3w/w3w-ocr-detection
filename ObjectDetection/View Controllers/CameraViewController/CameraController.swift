import CoreMedia
import CoreML
import UIKit
import Vision
import MessageUI
import SSZipArchive
import SnapKit
import GDPerformanceView_Swift


enum Counter {
        case totalPredictions
        case totalRecognitions
}

enum DetectionPhase {
        case W3wNotStarted
        case W3wDetected
        case W3wRecognised
        case W3wNotRecognised
        case W3wSelected
}

protocol CameraControllerProtocol: class {
    var onShowPhoto : ((UIImage) -> Void)? { get set }
    var onShowReportIssue : ((UIImage) -> Void)? { get set }
}

class CameraController: UIViewController, CameraControllerProtocol {

    var onShowReportIssue: ((UIImage) -> Void)?

    var wGesture: WGesture!

    var detectionPhase : DetectionPhase = .W3wNotStarted
    
    let maskLayer = CAShapeLayer()
    
    var threeWordBoxes = ThreeWordBoxes()
    
    var boundingBoxViews = [BoundingBoxView]()
    
    var performanceView = PerformanceView()
    
    var totalPredictions = 0
    
    var totalRecognitions = 0
        
    // MARK: - CameraControllerProtocol
    var onShowPhoto: ((UIImage) -> Void)?
        
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
        view.frame = CGRect(x: 0.0, y: self.overlayView.bounds.height, width: self.view.bounds.width, height: 300)
        return view
    }()
    
    // set up maximum bounding box
    func setUpBoundingBoxViews() {
        for _ in 0..<maxBoundingBoxViews { //10
          boundingBoxViews.append(BoundingBoxView())
        }
    }

//    // record button
//    internal lazy var photobtn : UIButton = {
//        let button = UIButton(type: .custom)
//        button.layer.cornerRadius = 30
//        button.layer.borderColor = UIColor.white.cgColor
//        button.setBackgroundImage(UIImage(named: "Shutter_Button"), for: .normal)
//        button.setBackgroundImage(UIImage(named: "closeBtn"), for: .selected)
//        button.clipsToBounds = true
//
//        return button
//    }()
//
    // report issue button
    internal lazy var reportBtn : UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = Config.Font.Color.txtBackground
        button.setTitle("Report an issue", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: Config.Font.type.sourceLight, size: 12.0)
        button.clipsToBounds = true
        return button
    }()
    
    // intro text
    internal lazy var instructionLbl : UILabel = {
        let label = PaddingUILabel(withInsets: 8, 8, 8, 8)
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = true
        label.text = "Frame the 3 word address you want to scan"
        label.textAlignment = .center
        label.font = UIFont(name:Config.Font.type.sourceSansBold, size: 18.0)
        label.shadow()
        label.sizeToFit()
        return label
    }()
    
    internal lazy var overlayView : UIView = {
        let overlayView = UIView()
        overlayView.backgroundColor = Config.Font.Color.overlaynonW3w
        overlayView.frame.size = self.view.frame.size
        return overlayView
    }()
    
    // setup all views
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.setUpBoundingBoxViews()
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
            Settings.saveBool(value: true, forKey: Config.w3w.developerMode)
            self.addBoundingBoxToLayer()
        }
    }
    
    func setup() {

        self.view.addSubview(overlayView)
        
        self.performanceView.add(overlayView)
        Settings.saveBool(value: false, forKey: Config.w3w.developerMode)
        
        performanceView.snp.makeConstraints{ (make) in
            make.top.equalTo(self.overlayView).offset(20)
            make.left.equalTo(self.overlayView)
            make.width.equalTo(self.overlayView)
            make.height.equalTo(self.overlayView).dividedBy(1.5)
        }
        // set up capture button
//        self.overlayView.addSubview(photobtn)
//        photobtn.addTarget(self, action: #selector(self.capturePhoto), for: .touchUpInside)
//        photobtn.snp.makeConstraints { (make) in
//            make.bottom.equalTo(self.overlayView).offset(-30)
//            make.centerX.equalTo(self.videoPreview)
//            make.width.height.equalTo(60)
//        }

        // set up intro label
        self.overlayView.addSubview(self.instructionLbl)
        instructionLbl.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.overlayView).offset(-30)
            make.centerX.equalTo(self.videoPreview)
            make.height.equalTo(30)
        }
        
        // set up report issue button
        self.view.addSubview(reportBtn)
        reportBtn.addTarget(self, action: #selector(self.reportIssue), for: .touchUpInside)
        reportBtn.snp.makeConstraints{(make) in
            make.top.equalTo(view).offset(45)
            make.width.equalTo(102)
            make.height.equalTo(32)
            make.right.equalTo(-20)
        }
    }
    
    func showSuggestionView(threeWordAddress: String) {
        // set up w3w suggestion view
        //self.w3wSuggestionView.alpha = 0.0
        
        
        self.w3wSuggestionView.frame = CGRect(x: 0.0, y: self.overlayView.bounds.height, width: self.view.bounds.width, height: 0)

        self.w3wSuggestionView.selected3Wa = threeWordAddress
        self.overlayView.addSubview(self.w3wSuggestionView)
        self.w3wSuggestionView.snp.makeConstraints { (make) in
                make.bottom.equalTo(self.overlayView)
                make.width.equalTo(self.overlayView)
                make.height.equalTo(self.overlayView).dividedBy(2.5)
        }

        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut, .transitionCurlDown], animations: {
            self.view.layoutIfNeeded()
        //UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseIn, animations: {
            //self.w3wSuggestionView.alpha = 1.0
//            self.w3wSuggestionView.selected3Wa = threeWordAddress
//            self.overlayView.addSubview(self.w3wSuggestionView)
//            self.w3wSuggestionView.snp.makeConstraints { (make) in
//                make.bottom.equalTo(self.overlayView)
//                make.width.equalTo(self.overlayView)
//                make.height.equalTo(self.overlayView).dividedBy(2.5)
        }, completion: nil)
    }

//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let touch = touches.first
//        for (_ , threewordbox ) in threeWordBoxes.threeWordBoxes {
//            guard let point = touch?.location(in: threewordbox.threeWordView) else {
//                return
//            }
//
//            if (threewordbox.threeWordView?.bounds.contains(point))! {
//                self.showSuggestionView(threeWordAddress: (threewordbox.threeWordView?.ThreeWordBoundingBoxLbl.text)!)
//                detectionPhase = .W3wSelected
//                self.drawThreeWordBox()
//                self.videoCapture.pause()
//            }
//        }
//    }
    
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
                self.addBoundingBoxToLayer()
                // Once everything is set up, we can start capturing live video.
                self.videoCapture.start()
            }
        }
    }
    
    func addBoundingBoxToLayer() {
        // Add the bounding box layers to the UI, on top of the video preview.
        for box in self.boundingBoxViews {
            box.addToLayer(self.overlayView.layer)
        }
    }
    
//    @objc func capturePhoto(_ sender: UIButton) {
//        photobtn.isSelected = !photobtn.isSelected
//        if photobtn.isSelected {
//            self.videoCapture.photoCapture()
//            self.instructionLbl.text = "Tap to scan again"
//        } else {
//            self.threeWordBoxes.removeAllBoundingBox()
//            self.overlayView.setNeedsDisplay()
//            self.instructionLbl.text = "Frame the 3 word address you want to scan"
//            self.didResumeVideoSession()
//        }
//    }

    @objc func reportIssue() {
        
        guard self.coreml.currentBuffer != nil else {
            return
        }

        let ciimage = CIImage(cvPixelBuffer: coreml.loadCurrentStatebuffer!)
        imageProcess.context = CIContext(options: nil)
        let cgImage = imageProcess.context.createCGImage(ciimage, from: CGRect(x: 0, y: 0, width: self.ImageBufferSize.width, height: self.ImageBufferSize.height))
        let imageObject = UIImage(cgImage: cgImage!)
        self.onShowReportIssue?(imageObject)
    }
}

//MARK: Video capture
extension CameraController: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame sampleBuffer: CMSampleBuffer) {
        imageProcess.updateImageBufferSize(sampleBuffer: sampleBuffer)
        coreml.predictVideo(sampleBuffer: sampleBuffer)
    }
    
    func photoCapture(_ capture: VideoCapture, didCapturePhotoFrame image: UIImage) {
        print("captured photo")
        
        self.videoCapture.pause()
        let maxTries = 30
        var tries = 0
        while tries < maxTries {
            let pixelBuffer = imageProcess.getCVPixelbuffer(from: image)!
            coreml.predictPhoto(pixelBuffer: pixelBuffer)
            tries += 1
        }
    }
}

extension CameraController {

    func drawThreeWordBox() {
        let path = UIBezierPath(rect: self.view.bounds)
        for (threeWordAddress, threewordbox) in threeWordBoxes.threeWordBoxes {
        
            threewordbox.threeWordView?.show(
            frame: threewordbox.threeWordRect,
            label: "w3w",
            w3w: threeWordAddress,
                color: UIColor(red: 0.373, green: 0.788, blue: 0.561, alpha: CGFloat(threewordbox.countDownTimer / Config.w3w.destructBBViewtimer)),
                textColor: UIColor(displayP3Red: 0.0, green: 0.0, blue: 0.0, alpha: CGFloat(threewordbox.countDownTimer / Config.w3w.destructBBViewtimer))
            , phase: detectionPhase)
            
            if threewordbox.countDownTimer > 1 {
                path.append(UIBezierPath(rect: threewordbox.threeWordRect))
            }
        
            threewordbox.threeWordView?.add(self.overlayView)
            threewordbox.threeWordView?.setNeedsDisplay()
        }
        
        if threeWordBoxes.threeWordBoxes.count > 0 {
            maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
            maskLayer.path = path.cgPath
        }
    }
}

//MARK: Process CoreML
extension CameraController: processPredictionsDelegate {
    func noPredictions() {
        let path = UIBezierPath(rect: self.view.bounds)
        maskLayer.fillRule = CAShapeLayerFillRule.nonZero
        maskLayer.path = path.cgPath
        UIView.animate(withDuration: 0.3) {
            self.overlayView.backgroundColor = Config.Font.Color.overlaynonW3w
        }
        self.threeWordBoxes.removeBoundingBoxes()
    }
    
    func showPredictions(predictions: [VNRecognizedObjectObservation]) {
        var i = 0
        for j in 0...9 {
            self.boundingBoxViews[j].hide()
        }
        for prediction in predictions {
            detectionPhase = .W3wDetected
            counterAdd(count: Counter.totalPredictions)
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
                detectionPhase = .W3wRecognised
                counterAdd(count: Counter.totalRecognitions)
                UIView.animate(withDuration: 0.2) {
                    self.overlayView.backgroundColor = Config.Font.Color.overlayW3w
                }
                
                if(!rect.intersects(w3wSuggestionView.frame)) {
                    threeWordBoxes.add(threeWordAddress: recognisedtext[0].threeWordAddress, rect: rect, parent: self.overlayView)
                }
                
                self.showSuggestionView(threeWordAddress: "///\(recognisedtext[0].threeWordAddress)")
                detectionPhase = .W3wSelected
                self.drawThreeWordBox()
                self.videoCapture.pause()
            } else {
            
                detectionPhase = .W3wNotRecognised
                self.boundingBoxViews[i].show(frame: rect, label: prediction.labels[0].identifier, color: Config.Font.Color.bordercolor)
                if i <= 10 {
                    i+=1
                } else {
                    i = 0
                }
            }
        }
            if detectionPhase != .W3wSelected {
                self.drawThreeWordBox()
            }            
            self.threeWordBoxes.removeBoundingBoxes()
    }
    
    func counterAdd(count: Counter) {
        if (count == Counter.totalPredictions) {
            totalPredictions = totalPredictions + 1
        } else if (count == Counter.totalRecognitions) {
            totalRecognitions = totalRecognitions + 1
        }
    }
    
    func counterReset(count: Counter) {
        if (count == Counter.totalPredictions) {
            totalPredictions = 0
        } else if (count == Counter.totalRecognitions) {
            totalRecognitions = 0
        }
    }
}

extension CameraController: W3wSuggestionViewProtocol {
    func didResumeVideoSession() {
        self.videoCapture.resume()
        self.instructionLbl.text = "Frame the 3 word address you want to scan"
       // self.photobtn.isSelected = false
        detectionPhase = .W3wNotStarted
    }
}

extension CameraController : PerformanceMonitorDelegate {

    func performanceMonitor(didReport performanceReport: PerformanceReport) {
        performanceView.display(fps: performanceReport.fps, cpu: Int(performanceReport.cpuUsage), memory: performanceReport.memoryUsage)
    }
}

