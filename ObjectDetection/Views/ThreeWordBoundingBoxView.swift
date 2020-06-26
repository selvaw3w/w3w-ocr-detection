//
//  ThreeWordBoxView.swift
//  ObjectDetection
//
//  Created by Lshiva on 14/05/2020.
//  Copyright © 2020 MachineThink. All rights reserved.
//

import UIKit
import Foundation

class ThreeWordBoundingBoxView: UIView {
    
    internal lazy var ThreeWordBoundingBoxLbl : UILabel = {
        let label = PaddingUILabel(withInsets: 8.0, 8.0, 16.0, 8.0)
        label.backgroundColor = UIColor.white
        label.layer.borderWidth = 2
        label.layer.borderColor = UIColor.white.cgColor
        label.textColor = UIColor.black
        label.layer.contentsScale = UIScreen.main.scale
        label.font = UIFont(name: Config.Font.type.sourceLight, size: 16.0)
        label.textAlignment = .left
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    func setup() {
        self.isHidden = true
        self.isUserInteractionEnabled = false
        self.backgroundColor = UIColor.clear
        self.layer.borderWidth = 2
        self.layer.borderColor = Config.Font.Color.bordercolor.cgColor
        self.addSubview(ThreeWordBoundingBoxLbl)
    }
    
    func add(_ parent: UIView) {
        parent.addSubview(self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func show(frame: CGRect, label: String, w3w: String, color: UIColor, textColor: UIColor, phase: DetectionPhase) {
        
        if !(self.frame == CGRect.zero) {
            UIView.animate(withDuration: 0.5) {
                self.showView(frame: frame, label: label, w3w: w3w, color: color, textColor: textColor, phase: phase)
            }
        } else {
            self.showView(frame: frame, label: label, w3w: w3w, color: color, textColor: textColor, phase: phase)
        }
    }

    func showView(frame: CGRect, label: String, w3w: String, color: UIColor, textColor: UIColor, phase: DetectionPhase) {
        self.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: frame.height)
        let attributedString = NSMutableAttributedString(string: "///\(w3w)")
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: NSRange(location: 0, length: 3))
        self.ThreeWordBoundingBoxLbl.attributedText = attributedString
        
        if self.ThreeWordBoundingBoxLbl.text != nil && phase == .W3wSelected {
            let nss = NSString(string: self.ThreeWordBoundingBoxLbl.text!)
            let size = nss.size(withAttributes:  [.font: UIFont(name: Config.Font.type.sourceLight, size: 20.0)!])
            self.ThreeWordBoundingBoxLbl.frame = CGRect(x: Int(0.0), y: Int(frame.size.height), width: Int(size.width), height: Int(25.0))
            self.ThreeWordBoundingBoxLbl.adjustsFontSizeToFitWidth = true
        }
        
        if phase == .W3wNotStarted || phase == .W3wRecognised || phase == .W3wDetected {
            self.layer.borderColor = Config.Font.Color.bordercolor.cgColor
            self.ThreeWordBoundingBoxLbl.layer.borderColor = UIColor.white.cgColor
            self.ThreeWordBoundingBoxLbl.isHidden = true
        } else if phase == .W3wSelected {
            self.layer.borderColor = UIColor.green.cgColor
            self.ThreeWordBoundingBoxLbl.layer.borderColor = UIColor.green.cgColor  
            self.ThreeWordBoundingBoxLbl.isHidden = false
        }

        self.isHidden = false
    }

    func hide() {
        self.isHidden = true
    }
}

