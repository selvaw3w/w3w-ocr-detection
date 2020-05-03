//
//  PhotoDetectionView.swift
//  ObjectDetection
//
//  Created by Lshiva on 01/05/2020.
//  Copyright © 2020 What3words. All rights reserved.
//

import UIKit
import SnapKit

class PhotoDetectionView: UIView {
    
    var label:UILabel!
    var button:UIButton!

    override init (frame : CGRect) {
        super.init(frame : frame)
        self.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1.0)


        label = UILabel(frame: CGRect(x: 12, y: 8, width: self.frame.size.width-90, height: 50))
        label.text = "Connection error please try again later!!"
        label.textColor = UIColor.white
        label.numberOfLines = 0
        self.addSubview(label)

        button = UIButton(frame: CGRect(x: self.frame.size.width-87, y: 8, width: 86, height: 50))
        button.setTitle("OK", for: .normal)
        button.setTitleColor(UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 1.0), for: .normal)
        button.addTarget(self, action:#selector(self.closeView), for: .touchUpInside)
        self.addSubview(button)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func closeView() {
        print("close button")
        //self.hide()
    }
}
//    var imageView = UIImageView()
//    //close button
//    internal lazy var closeBtn : UIButton = {
//        let button = UIButton(type: .custom)
//        button.setBackgroundImage(UIImage(systemName: "xmark"),for: .normal)
//        button.clipsToBounds = true
//        return button
//    }()
//
//    init() {
//       super.init(frame: CGRect.zero)
//        self.setUp()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func setUp() {
//        self.addSubview(closeBtn)
//        closeBtn.isHidden = false
//        closeBtn.snp.makeConstraints{ (make) in
//            make.top.equalTo(self).offset(50)
//            make.width.height.equalTo(30)
//            make.left.equalTo(20)
//        }
//    }
//
//    func loadImage(_ image: UIImage) {
//        imageView = UIImageView(frame: CGRect(x: (superview?.bounds.origin.x)!, y: (superview?.bounds.origin.y)!, width: (superview?.bounds.width)!, height: (superview?.bounds.height)!))
//        imageView.image = image
//        self.addSubview(imageView)
//        self.show()
//    }
//
//    @objc func closeView() {
//        print("close button")
//        self.hide()
//    }
//
//    func show() {
//        self.isHidden = false
//        self.bringSubviewToFront(self.closeBtn)
//        closeBtn.addTarget(self, action: #selector(self.closeView), for: .touchUpInside)
//        self.closeBtn.isHidden = false
//    }
//
//    func hide() {
//        self.isHidden = true
//        self.closeBtn.isHidden = true
//    }
//}
