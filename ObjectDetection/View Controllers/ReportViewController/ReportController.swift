//
//  ReportViewController.swift
//  ObjectDetection
//
//  Created by Lshiva on 05/06/2020.
//  Copyright © 2020 MachineThink. All rights reserved.
//

import UIKit
import SnapKit
import AEXML
import Photos
import MessageUI

 enum ImageSource: Int
  {
    case camera = 1
    case photoLibrary
  }
  
protocol ReportControllerProtocol: class {
    var onBack: (() -> Void)? { get set }
}

class ReportController: BaseViewController, ReportControllerProtocol, UIImagePickerControllerDelegate,UINavigationControllerDelegate, CroppableImageViewDelegateProtocol  {

        
    @IBOutlet weak var annotationView: AnnotateView!
    
    var labelBtnTypes: [UIButton]!
    
    // close button
    internal lazy var closetn : UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.clear
        button.setImage(UIImage(named: "closeBtn"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: Config.Font.type.sourceLight, size: 14.0)
        button.clipsToBounds = true
        return button
    }()
    
    // report issue button
    internal lazy var w3wBtn : UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.red
        button.setTitle(Labels.w3w.rawValue, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: Config.Font.type.sourceLight, size: 14.0)
        button.clipsToBounds = true
        return button
    }()

    // report issue button
    internal lazy var w3wlogoBtn : UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = Config.Font.Color.text
        button.setTitle(Labels.w3wlogo.rawValue, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: Config.Font.type.sourceLight, size: 14.0)
        button.clipsToBounds = true
        return button
    }()

    // report issue button
    internal lazy var otherBtn : UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = Config.Font.Color.text
        button.setTitle(Labels.other.rawValue, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: Config.Font.type.sourceLight, size: 14.0)
        button.clipsToBounds = true
        return button
    }()
    // report issue button
    internal lazy var deleteBtn : UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.clear
        button.setImage(UIImage(named: "Vector"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: Config.Font.type.sourceLight, size: 14.0)
        button.clipsToBounds = true
        return button
    }()

    // close button
    internal lazy var sendEmailbtn : UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = Config.Font.Color.text
        button.setTitle("Report", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: Config.Font.type.sourceLight, size: 14.0)
        button.clipsToBounds = true
        return button
    }()

    var onBack: (() -> Void)?
        
    var image: UIImage? = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    // MARK: - Private methods
    
    func setup() {
        //self.annotationView.imageToCrop = image
        self.pickImageFromSource(ImageSource.camera)
        
        self.annotationView.addSubview(self.w3wBtn)
        self.w3wBtn.addTarget(self, action: #selector(self.labelsSelected), for: .touchUpInside)
        self.w3wBtn.snp.makeConstraints { (make) in
            make.top.equalTo(self.annotationView).offset(50)
            make.width.equalTo(79)
            make.height.equalTo(45)
            make.right.equalTo(-20)
        }
        self.annotationView.addSubview(self.w3wlogoBtn)
        self.w3wlogoBtn.addTarget(self, action: #selector(self.labelsSelected), for: .touchUpInside)
        self.w3wlogoBtn.snp.makeConstraints { (make) in
            make.top.equalTo(self.annotationView).offset(50)
            make.width.equalTo(100)
            make.height.equalTo(45)
            make.right.equalTo(self.w3wBtn.snp.left).offset(-10)
        }

        self.annotationView.addSubview(self.otherBtn)
        self.otherBtn.addTarget(self, action: #selector(self.labelsSelected), for: .touchUpInside)
        self.otherBtn.snp.makeConstraints { (make) in
            make.top.equalTo(self.annotationView).offset(50)
            make.width.equalTo(45)
            make.height.equalTo(45)
            make.right.equalTo(self.w3wlogoBtn.snp.left).offset(-10)
        }

        self.annotationView.addSubview(self.deleteBtn)
        self.deleteBtn.addTarget(self, action: #selector(self.deleteBoundingBox), for: .touchUpInside)
        self.deleteBtn.snp.makeConstraints { (make) in
            make.top.equalTo(self.annotationView).offset(50)
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.right.equalTo(self.otherBtn.snp.left).offset(-10)
        }
        
        self.annotationView.addSubview(self.closetn)
        self.closetn.addTarget(self, action: #selector(self.closeView), for: .touchUpInside)
        self.closetn.snp.makeConstraints { (make) in
            make.top.equalTo(self.annotationView).offset(30)
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.left.equalTo(self.annotationView).offset(30)
        }

        labelBtnTypes = [w3wBtn, w3wlogoBtn, otherBtn]
        
        self.view.addSubview(annotationView)
        annotationView.snp.makeConstraints { (make) in
            make.width.height.equalTo(self.view)
        }
        
        // set up capture button
        self.annotationView.addSubview(sendEmailbtn)
        sendEmailbtn.addTarget(self, action: #selector(self.sendScreenshotEmail), for: .touchUpInside)
        sendEmailbtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.annotationView).offset(-30)
            make.centerX.equalTo(self.annotationView)
            make.width.height.equalTo(60)
        }
    }
    
    @objc func labelsSelected(_ sender: UIButton) {
        labelBtnTypes.forEach({ $0.backgroundColor =  Config.Font.Color.text })
        sender.backgroundColor = UIColor.red
        
        if let labelValue = Labels(rawValue: (sender.titleLabel?.text)!) {
            print(labelValue)
            annotationView.label = labelValue
        }
    }
    
    @objc func closeView() {
        self.onBack?()
    }
    @objc func deleteBoundingBox() {
        self.annotationView.deleteBoundingBoxRect()
    }
    
    func pickImageFromSource(_ theImageSource: ImageSource) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        switch theImageSource
        {
            case .camera:
                print("User chose take new pic button")
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                imagePicker.cameraDevice = UIImagePickerController.CameraDevice.rear;
        case .photoLibrary:
                print("not implemented")
        }
        
            if UIDevice.current.userInterfaceIdiom == .pad
    {
      if theImageSource == ImageSource.camera
      {
      self.present(
        imagePicker,
        animated: true)
        {
          //println("In image picker completion block")
        }
      }
      else
      {
        self.present(
          imagePicker,
          animated: true)
          {
            //println("In image picker completion block")
        }
      }
    }
    else
    {
      self.present(
        imagePicker,
        animated: true)
        {
          print("In image picker completion block")
      }
      
    }
    }
    override func viewDidAppear(_ animated: Bool) {
        let status = PHPhotoLibrary.authorizationStatus()
        if status != .authorized {
        PHPhotoLibrary.requestAuthorization() {
        status in
      }
    }
}
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    print("In \(#function)")
    if let selectedImage = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as? UIImage
    {
      picker.dismiss(animated: true, completion: nil)
      self.annotationView.imageToCrop = selectedImage
    }
}

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    print("In \(#function)")
    picker.dismiss(animated: true, completion: nil)
  }
  
  func saveXML(_ filename: String) {
        
        let xmlRequest = AEXMLDocument()
        
        let annotation = xmlRequest.addChild(name:"Annotation", attributes: ["verified":"yes"])
        annotation.addChild(name: "folder",value: "annotation")
        annotation.addChild(name: "filename",value: "image.png")
        annotation.addChild(name: "path",value: "OCR-PascalVOC-export/Annotations/image.png")
        
        let source = annotation.addChild(name: "source")
        source.addChild(name: "database",value: "unknown")
        
        let size = annotation.addChild(name: "size")
        size.addChild(name: "width", value: "\(self.annotationView.imageSize?.width ?? 0.0)")
        size.addChild(name: "height", value: "\(String(describing: self.annotationView.imageSize?.height ?? 0.0))")
        size.addChild(name: "depth", value: "")
        annotation.addChild(name: "segmented", value: "0")
            
        if self.annotationView.allBoundingBoxRect.count > 0 {
            for box in self.annotationView.allBoundingBoxRect {
                let object = annotation.addChild(name: "object")
                self.writeXMLObject(object, box: box)
            }
        }
        
        if let drawRect = self.annotationView.selectedBoundingBoxRect {
            let object = annotation.addChild(name: "object")
            self.writeXMLObject (object, box: drawRect)
        }
        // prints the same XML structure as original
        print(xmlRequest.xml)
        
        self.save(text: xmlRequest.xml, toDirectory: self.documentDirectory(), withFileName: "\(filename).xml")
        

    }
    
    func writeXMLObject(_ object: AEXMLElement, box: BoundingBox) {
            let drawRect = self.convertScreenCoordinatesToImageCoordinates(box)
            object.addChild(name: "name", value: box.name.rawValue)
            
            let bndbox = object.addChild(name: "bndbox")
            bndbox.addChild(name: "xmin",value: "\(drawRect[0])")
            bndbox.addChild(name: "ymin",value: "\(drawRect[1])")
            bndbox.addChild(name: "xmax",value: "\(drawRect[2])")
            bndbox.addChild(name: "ymax",value: "\(drawRect[3])")
            
    }
    
    func convertScreenCoordinatesToImageCoordinates(_ boxes: BoundingBox) -> [CGFloat] {
            var boxRect = boxes.box
            
            var drawRect: CGRect = CGRect.zero
                drawRect.size = self.annotationView.imageSize!
                drawRect.origin.x = round(boxRect.origin.x / self.annotationView.aspect)
                drawRect.origin.y = round(boxRect.origin.y / self.annotationView.aspect)
                boxRect.size.width = round(boxRect.size.width/self.annotationView.aspect)
                boxRect.size.height = round(boxRect.size.height/self.annotationView.aspect)
                boxRect.origin.x = round(boxRect.origin.x)
                boxRect.origin.y = round(boxRect.origin.y)
                
                let boxXmin = drawRect.minX
                let boxYmin = drawRect.minY
                let boxXmax = drawRect.minX + boxRect.width
                let boxYmax = drawRect.minY + boxRect.height
                
                print(boxXmin)
                print(boxYmin)
                print(boxXmax)
                print(boxYmax)
                return [boxXmin, boxYmin, boxXmax, boxYmax]
    }
    
    func haveValidCropRect(_ haveValidCropRect: Bool) {
        self.sendEmailbtn.isEnabled = haveValidCropRect
    }
    
}

//MARK: Send Email
extension ReportController: MFMailComposeViewControllerDelegate {
    
    @objc private func sendScreenshotEmail() {
        let filename = randomString(length: 10)
        self.saveXML(filename)
        
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
        
        let imageData = self.annotationView.imageToCrop!.jpegData(compressionQuality: 1.0)
        
        mailComposer.addAttachmentData(imageData!, mimeType: "image/jpeg", fileName: "Image_\(filename).jpeg")
        let filepath =  self.read(fromDocumentsWithFileName: "\(filename).xml")
        
        if let fileData = NSData(contentsOfFile: filepath) {
            print("File data loaded.")
            mailComposer.addAttachmentData(fileData as Data, mimeType: "application/xml", fileName: "\(filename).xml")
        }

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
    }
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }

}

extension ReportController {
    private func documentDirectory() -> String {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                .userDomainMask,
                                                                true)
        return documentDirectory[0]
    }
    
    private func append(toPath path: String, withPathComponent pathComponent: String) -> String? {
        if var pathURL = URL(string: path) {
            pathURL.appendPathComponent(pathComponent)
            
            return pathURL.absoluteString
        }
        return nil
    }
    
    private func read(fromDocumentsWithFileName fileName: String) -> String {
        guard let filePath = self.append(toPath: self.documentDirectory(), withPathComponent: fileName) else {
            return ""
        }
        return filePath
//        do {
//            let savedString = try NSData(contentsOfFile: filePath)
//            //String(contentsOfFile: filePath)
//
//            print(savedString)
//        } catch {
//            print("Error reading saved file")
//        }
    }
    private func save(text: String, toDirectory directory: String, withFileName fileName: String) {
        guard let filePath = self.append(toPath: directory, withPathComponent: fileName) else {
            return
        }
    
        do {
            try text.write(toFile: filePath, atomically: true, encoding: .utf8)
        } catch {
            print("Error", error)
            return
        }
        print("Save successful")
    }

}

//            var cropRect = boxes.box
//            var drawRect: CGRect = CGRect.zero
//                drawRect.size = self.annotationView.imageSize!
//                drawRect.origin.x = round(cropRect.origin.x / self.annotationView.aspect)
//                drawRect.origin.y = round(cropRect.origin.y / self.annotationView.aspect)
//                cropRect.size.width = round(cropRect.size.width/self.annotationView.aspect)
//                cropRect.size.height = round(cropRect.size.height/self.annotationView.aspect)
//                cropRect.origin.x = round(cropRect.origin.x)
//                cropRect.origin.y = round(cropRect.origin.y)

//            // covert the screen coordinates to the image coordinates
//            let percentX = annotationViewPoint.x / self.annotationView.viewForImage.frame.size.width
//            let percentY = annotationViewPoint.y / self.annotationView.viewForImage.frame.size.height
//
//            let imagePoint = CGPoint(x: (self.annotationView.imageToCrop?.size.width)! * percentX,  y: (self.annotationView.imageToCrop?.size.height)! * percentY)
//
//
//    print(self.annotationView.allBoundingBoxRect)
//        // let get the point for each bounding box
//        let point = CGPoint(x: self.annotationView.viewForImage.frame.minX, y: self.annotationView.viewForImage.frame.minY)
//        //the annotation view is the screen the boxes are drawn
//        let annotationViewPoint = self.annotationView.viewForImage.convert(point, to: self.annotationView)


//            let drawRect = self.convertScreenCoordinatesToImageCoordinates(box)
//            object.addChild(name: "name", value: box.name.rawValue)
//
//            let bndbox = object.addChild(name: "bndbox")
//            bndbox.addChild(name: "xmin",value: "\(drawRect.minX)")
//            bndbox.addChild(name: "ymin",value: "\(drawRect.minY)")
//            bndbox.addChild(name: "xmax",value: "\(drawRect.maxX)")
//            bndbox.addChild(name: "ymax",value: "\(drawRect.maxY)")


