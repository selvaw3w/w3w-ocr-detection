import CoreMedia
import CoreML
import UIKit
import Vision
import MessageUI
import SSZipArchive
import SnapKit

protocol CameraViewControllerProtocol: class {
    var onShowPhoto : (() -> Void)? { get set }
}

class CameraViewController: UIViewController, CameraViewControllerProtocol {
    var timer = Timer()


    // MARK: - CameraViewControllerProtocol
    var onShowPhoto: (() -> Void)?
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
//    var maxBoundingBoxViews = 10 {
//        didSet {
//            //setUpBoundingBoxViews()
//        }
//    }
    
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
        coreML.delegate = self
        self.ocrmanager.setAreaOfInterest(viewBounds: self.view.bounds)
        //self.setUpBoundingBoxViews()
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
    
//    // set up maximum bounding box
//    func setUpBoundingBoxViews() {
//        for _ in 0..<maxBoundingBoxViews { //10
//          boundingBoxViews.append(BoundingBoxView())
//        }
//        let labels = coreML.loadLabels()
//        // Assign random colors to the classes.
//        for label in labels {
//            colors[label] = UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1)
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
                // Add the bounding box layers to the UI, on top of the video preview.
//                for box in self.boundingBoxViews {
//                    box.addToLayer(self.overlayView.layer)
//                }
                // Once everything is set up, we can start capturing live video.
                self.videoCapture.start()
            }
        }
    }
    
    @objc func startCapture() {
        self.videoCapture.photoCapture()
    }
    
    @objc func reportIssue() {
        self.sendScreenshotEmail()
    }
}

//MARK: Video capture
extension CameraViewController: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame sampleBuffer: CMSampleBuffer) {
        self.tideUpScreen()
        imageProcess.updateImageBufferSize(sampleBuffer: sampleBuffer)
        coreML.predictVideo(sampleBuffer: sampleBuffer)
    }
    
    func photoCapture(_ capture: VideoCapture, didCapturePhotoFrame image: UIImage) {
        let pixelBuffer = imageProcess.getCVPixelbuffer(from: image)!
        coreML.predictPhoto(pixelBuffer: pixelBuffer)
        //self.videoCapture.stop()
        self.onShowPhoto?()
//        self.coordinator?.photo(to: image)
    }
}

//MARK: Process CoreML
extension CameraViewController: processPredictionsDelegate {

    func showPredictions(predictions: [VNRecognizedObjectObservation]) {
        
        var recogText = [String]()
        //step 1: loop through predictions
        for prediction in predictions {
            let width = self.view.frame.width
            let height = self.view.frame.height
            let scaleFactor = height/self.ImageBufferSize.height
            let scale = CGAffineTransform.identity.scaledBy(x: scaleFactor, y: scaleFactor)
            let offset = self.imageProcess.ImageBufferSize.width * scaleFactor - width
            let actualMarginWidth = -offset / 2.0
            let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: actualMarginWidth , y: -height)
            let croppedImage = self.imageProcess.cropImage(prediction, cvPixelBuffer: self.coreML.currentBuffer!)
            let rect = self.imageProcess.croppedRect.applying(scale).applying(transform) // rect to display
            let recognisedtext = self.ocrmanager.find_3wa(image: croppedImage)
            
            let showLabel = "///\(recognisedtext)"
            if !recognisedtext.isEmpty {
                recogText.append(showLabel)
    
                let bb = boundingBoxViews.first(where: { (bbView) -> Bool in return bbView.w3wText == showLabel })
                if let b = bb {
                    b.selfDestructtimer = 5
                    b.update(frame: rect, label: "", w3w: showLabel, color: UIColor.white)
                } else {
                    let boundingBoxView = BoundingBoxView()
                    boundingBoxViews.append(boundingBoxView)
                    boundingBoxView.selfDestructtimer = 5
                    boundingBoxView.add(frame: rect, label: "", w3w: showLabel, color: UIColor.white)
                    boundingBoxView.addToLayer(self.overlayView.layer)
                }
                
                // delete
                
//                let boundingBoxtexts = searchW3w(predictions: recogText, boundingBoxes: boundingBoxViews.map({ $0.w3wText! })) as! [String]
//
//                for toRemove in boundingBoxtexts {
//                  for bbox in boundingBoxViews {
//                    if bbox.w3wText == toRemove {
//                    if bbox.selfDestructtimer == nil {
//                        bbox.selfDestructtimer = 5
//                      }
//                    }
//                  }
//                }
            }
//            for toRemove in boundingBoxtexts {
//                boundingBoxViews.removeAll(where: {
//                    $0.selfDestructtimer = 5
//                    return $0.w3wText == toRemove
//                } )
//            }
//
            
//            let answer = zip(recogText, boundingBoxtexts).enumerated().filter() {
//                $0 == $1.1
//            }.map{$0}
//
            //boundingBoxViews.removeAll (where: { (bbView.contains($0) })
//            boundingBoxViews.removeAll(where: { (bbView) -> Bool in
//                print("bbView.w3wText:\(String(describing: bbView.w3wText))")
//                let isContainText = boundingBoxtexts.contains(bbView.w3wText!)
//                bbView.hide()
//                return isContainText
//            })
            //boundingBoxViews.removeAll
        }
        //self.tideUpScreen()
    }
    
    @objc func tideUpScreen() {
        for bbView in boundingBoxViews {
            if bbView.selfDestructtimer != nil {
                bbView.selfDestructtimer! -= 1
                if bbView.selfDestructtimer! < 1 {
                    bbView.hide()
                    boundingBoxViews.removeAll(where: {
                        return $0.w3wText == bbView.w3wText
                    })
                }
            }
        }
    }
    
    func searchW3w(predictions: [String], boundingBoxes: [String]) -> Array<Any> { //[String]
        let predictText = Set(predictions)
        let bbText = Set(boundingBoxes)

        // Return a set with all values contained in both A and B
        //let intersection = setA.intersection(setB)

        // Return a set with all values in A which are not contained in B
        let diff = bbText.subtracting(predictText)

        return Array(diff)

    }
        //step 0 : predictions are all labelled 'w3w' not other, others, w3wlogo with confident score of 75.0 - loop
        //step 1 : get the ocr to give the 3wa
        //step 2 : filter for recognised text, if already exist
        //step 3 : find the text in the bounding box view array, if exist update else add
        
        
//        for i in 0..<self.boundingBoxViews.count { //0 < 0..10
//            print("predictions.count: \(predictions.count)")
//            if i < predictions.count { // others, w3wlogo, other
//                let prediction = predictions[i]
//                let width = self.view.frame.width
//                let height = self.view.frame.height
//                let scaleFactor = height/self.ImageBufferSize.height
//                let scale = CGAffineTransform.identity.scaledBy(x: scaleFactor, y: scaleFactor)
//                let offset = self.imageProcess.ImageBufferSize.width * scaleFactor - width
//                let actualMarginWidth = -offset / 2.0
//                let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: actualMarginWidth , y: -height)
//
//                let bestClass = prediction.labels[0].identifier
//                let confidence = prediction.labels[0].confidence
//
//                // Display the bounding box.
//                let label = String(format: "%@ %.1f", bestClass, confidence * 100)
//                //let color = colors[bestClass] ?? UIColor.red
//                if bestClass == "w3w" && (confidence * 100) > 75.0 {
//                    if (self.coreML.currentBuffer != nil) {
//                        let croppedImage = self.imageProcess.cropImage(prediction, cvPixelBuffer: self.coreML.currentBuffer!)
//                        let rect = self.imageProcess.croppedRect.applying(scale).applying(transform)
//                        let recognisedtext = self.ocrmanager.find_3wa(image: croppedImage)
//                        guard recognisedtext.isEmpty else {
//
//                            let showLabel = "///\(recognisedtext)"
//                            if showLabel == boundingBoxViews[i].w3wText {
//                                self.boundingBoxViews[i].update(frame: rect, label: label, w3w: showLabel, color: UIColor.white)
//                            } else {
//
//                                self.boundingBoxViews[i].add(frame: rect, label: label, w3w: showLabel, color: UIColor.white)
//                            }
//
//                            //self.boundingBox = rect
//                            return
//                        }
//                    }
//                } else {
//                    print("other")
//                }
//            } else {
//                print("Hide:\(i)")
//                self.boundingBoxViews[i].hide()
//            }
//        }
//    }
}

//MARK: Send Email
extension CameraViewController: MFMailComposeViewControllerDelegate {
    
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
