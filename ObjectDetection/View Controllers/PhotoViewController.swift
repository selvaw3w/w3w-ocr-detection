//
//  PhotoViewController.swift
//  ObjectDetection
//
//  Created by Lshiva on 02/05/2020.
//  Copyright © 2020 What3words. All rights reserved.
//

import UIKit
import Vision

protocol PhotoViewControllerProtocol: class {
    var onBack: (() -> Void)? { get set }
}

class PhotoViewController: BaseViewController, PhotoViewControllerProtocol {
    
    var onBack: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.red
    }
    
    override func didSelectCustomBackAction() {
        self.onBack?()
    }
}
