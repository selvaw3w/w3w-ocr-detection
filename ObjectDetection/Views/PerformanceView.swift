//
//  PerformanceView.swift
//  ObjectDetection
//
//  Created by Lshiva on 19/05/2020.
//  Copyright © 2020 MachineThink. All rights reserved.
//

import UIKit
import Foundation
import SnapKit
import GDPerformanceView_Swift

class PerformanceView : UIView {

    // fps
    
    internal lazy var FpsLbl : UILabel = {
        let label = PaddingUILabel(withInsets: 8.0, 8.0, 16.0, 8.0)
        label.backgroundColor = UIColor.clear
        label.layer.contentsScale = UIScreen.main.scale
        label.font = UIFont(name: Config.Font.type.sourceSanRegular, size: 36.0)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.numberOfLines = 2
        label.sizeToFit()
        return label
    }()

    // cpu
    internal lazy var CpuLbl : UILabel = {
        let label = PaddingUILabel(withInsets: 8.0, 8.0, 16.0, 8.0)
        label.backgroundColor = UIColor.clear
        label.layer.contentsScale = UIScreen.main.scale
        label.font = UIFont(name: Config.Font.type.sourceSanRegular, size: 36.0)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.numberOfLines = 2
        label.sizeToFit()
        return label
    }()
    
    // memory
    internal lazy var MemoryLbl : UILabel = {
        let label = PaddingUILabel(withInsets: 8.0, 8.0, 16.0, 8.0)
        label.backgroundColor = UIColor.clear
        label.layer.contentsScale = UIScreen.main.scale
        label.font = UIFont(name: Config.Font.type.sourceSanRegular, size: 36.0)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.numberOfLines = 2
        label.sizeToFit()
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
        self.addSubview(FpsLbl)
        self.addSubview(CpuLbl)
        self.addSubview(MemoryLbl)
        
        self.FpsLbl.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.centerX.equalTo(self)
            make.width.equalTo(self)
            make.height.equalTo(self).dividedBy(3).offset(-10)
        }
        
        self.CpuLbl.snp.makeConstraints { (make) in
            make.top.equalTo(FpsLbl.snp.bottom).offset(10)
            make.centerX.equalTo(self)
            make.width.equalTo(self)
            make.height.equalTo(self).dividedBy(3).offset(-10)
        }
        
        self.MemoryLbl.snp.makeConstraints { (make) in
            make.top.equalTo(CpuLbl.snp.bottom)
            make.centerX.equalTo(self)
            make.width.equalTo(self)
            make.height.equalTo(self).dividedBy(3).offset(-10)
        }
    }
    
    func add(_ parent: UIView) {
        parent.addSubview(self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func show() {
        self.isHidden = false
    }
    
    func display(fps: Int, cpu: Int, memory: MemoryUsage) {
        UIView.animate(withDuration: 0.5) {
            self.FpsLbl.fadeTransition(0.7)
            self.FpsLbl.text = "FPS:\n \(fps) fps"
            
            self.CpuLbl.fadeTransition(0.7)
            self.CpuLbl.text = "CPU:\n \(String(cpu)) %"

            self.MemoryLbl.fadeTransition(0.7)
            
            let memoryUsageMB       = (memory.used/1024)/1024
            let memoryUsagePercent  = round((Double(memory.used)/Double(memory.total)) * 100)
            
            self.MemoryLbl.text = "MEMORY:\n \(memoryUsageMB) mb / \(memoryUsagePercent) %"
        }
    }
    
    @objc func hide() {
        self.isHidden = true
    }
}
