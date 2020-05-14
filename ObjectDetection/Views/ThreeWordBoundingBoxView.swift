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
        self.layer.borderWidth = 4
        self.layer.borderColor = UIColor.white.cgColor
        self.addSubview(ThreeWordBoundingBoxLbl)
    }
    
    func add(_ parent: UIView) {
        parent.addSubview(self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func show(frame: CGRect, label: String, w3w: String, color: UIColor, textColor: UIColor) {
        
        if !(self.frame == CGRect.zero) {
            UIView.animate(withDuration: 0.5) {
                self.showView(frame: frame, label: label, w3w: w3w, color: color, textColor: textColor)
            }
        } else {
            self.showView(frame: frame, label: label, w3w: w3w, color: color, textColor: textColor)
        }
    }

    func showView(frame: CGRect, label: String, w3w: String, color: UIColor, textColor: UIColor) {
        self.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: frame.height)
        let attributedString = NSMutableAttributedString(string: "///\(w3w)")
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: NSRange(location: 0, length: 3))
        self.ThreeWordBoundingBoxLbl.attributedText = attributedString
        
        if self.ThreeWordBoundingBoxLbl.text != nil {
            let nss = NSString(string: self.ThreeWordBoundingBoxLbl.text!)
            let size = nss.size(withAttributes:  [.font: UIFont(name: Config.Font.type.sourceLight, size: 20.0)!])
            self.ThreeWordBoundingBoxLbl.frame = CGRect(x: Int(0.0), y: Int(frame.size.height), width: Int(size.width), height: Int(25.0))
            self.ThreeWordBoundingBoxLbl.adjustsFontSizeToFitWidth = true
        }
        self.isHidden = false
    }

    func hide() {
        self.isHidden = true
    }
}

