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
    
    let step : Float = 5
    var slideValue : Float = 75.0
    
    // semi transparent view for labels
    internal lazy var opaqueView : UIView = {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    // fps
    internal lazy var FpsLbl : UILabel = {
        let label = PaddingUILabel(withInsets: 8.0, 8.0, 16.0, 8.0)
        label.backgroundColor = UIColor.clear
        label.layer.contentsScale = UIScreen.main.scale
        label.font = UIFont(name: Config.Font.type.rockWell, size: 15.0)
        label.textColor = UIColor.black.withAlphaComponent(0.8)
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
        label.font = UIFont(name: Config.Font.type.rockWell, size: 15.0)
        label.textColor = UIColor.black.withAlphaComponent(0.8)
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
        label.font = UIFont(name: Config.Font.type.rockWell, size: 15.0)
        label.textColor = UIColor.black.withAlphaComponent(0.8)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.numberOfLines = 2
        label.sizeToFit()
        return label
    }()
    
    //slider
    internal lazy var thresholdSlider : UISlider = {
        let slider = UISlider()
        slider.minimumValue = 50
        slider.maximumValue = 100
        slider.isContinuous = true
        slider.tintColor = UIColor.green
        return slider
    }()
    
    //slider label
    internal lazy var sliderLbl : UILabel = {
        let label = PaddingUILabel(withInsets: 8.0, 8.0, 16.0, 8.0)
        label.backgroundColor = Config.Font.Color.text
        label.layer.contentsScale = UIScreen.main.scale
        label.font = UIFont(name: Config.Font.type.rockWell, size: 20.0)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.sizeToFit()
        return label
    }()
    
    // 3wa filter switch
    internal lazy var w3wToggle : UISwitch = {
        let w3wSwitch = UISwitch()
        w3wSwitch.isOn = true
        w3wSwitch.setOn(true, animated: false)
        
        return w3wSwitch
    }()
    
    internal lazy var toggleLbl : UILabel = {
        let label = PaddingUILabel(withInsets: 8.0, 8.0, 16.0, 8.0)
        label.backgroundColor = UIColor.clear
        label.layer.contentsScale = UIScreen.main.scale
        label.font = UIFont(name: Config.Font.type.rockWell, size: 15.0)
        label.textColor = UIColor.black.withAlphaComponent(0.8)
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
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.clear
        
        self.addSubview(self.opaqueView)
        self.opaqueView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self)
            make.left.equalTo(10)
            make.width.equalTo(self).dividedBy(2)
            make.height.equalTo(self).dividedBy(5)
        }

        
        self.opaqueView.addSubview(FpsLbl)
        self.opaqueView.addSubview(CpuLbl)
        self.opaqueView.addSubview(MemoryLbl)
        
        self.FpsLbl.snp.makeConstraints { (make) in
            make.top.equalTo(self.opaqueView).offset(10)
            make.centerX.equalTo(self.opaqueView)
            make.width.equalTo(self.opaqueView)
            make.height.equalTo(30)
        }
        
        self.CpuLbl.snp.makeConstraints { (make) in
            make.top.equalTo(FpsLbl.snp.bottom).offset(5)
            make.centerX.equalTo(self.opaqueView)
            make.width.equalTo(self.opaqueView)
            make.height.equalTo(30)
        }
        
        self.MemoryLbl.snp.makeConstraints { (make) in
            make.top.equalTo(CpuLbl.snp.bottom)
            make.centerX.equalTo(self.opaqueView)
            make.width.equalTo(self.opaqueView)
            make.height.equalTo(40)
        }
        // slider
        UIView.animate(withDuration: 0.8) {
            self.thresholdSlider.setValue(self.slideValue, animated: true)
        }
        
        self.sliderValueDidChange(self.thresholdSlider)
        self.thresholdSlider.minimumTrackTintColor = .red
        self.thresholdSlider.maximumTrackTintColor = .gray
        self.thresholdSlider.addTarget(self, action: #selector(self.sliderValueDidChange(_:)), for: .valueChanged)
        self.addSubview(thresholdSlider)
        self.thresholdSlider.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(100)
            make.width.equalTo(self).offset(-30)
            make.centerX.equalTo(self)
        }
        
        self.addSubview(self.sliderLbl)
        self.sliderLbl.snp.makeConstraints { (make) in
            make.top.equalTo(thresholdSlider.snp.bottom)
            make.centerX.equalTo(self)
            make.width.equalTo(70)
            make.height.equalTo(40)
        }
        
        self.w3wToggle.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
        self.switchValueDidChange(self.w3wToggle)
        self.addSubview(self.w3wToggle)
        self.w3wToggle.snp.makeConstraints{ (make) in
            make.top.equalTo(self.sliderLbl.snp.bottom)
            make.right.equalTo(self).offset(-5)
            make.height.equalTo(40)
        }

        self.addSubview(self.toggleLbl)
        self.toggleLbl.snp.makeConstraints{ (make) in
            make.top.equalTo(self.sliderLbl.snp.bottom)
            make.right.equalTo(self.w3wToggle.snp.left).offset(-5)
            make.width.equalTo(self).dividedBy(2)
            make.height.equalTo(40)
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
            self.FpsLbl.text = "FPS: \(fps) fps"
            self.CpuLbl.fadeTransition(0.7)
            self.CpuLbl.text = "CPU: \(String(cpu)) %"
            self.MemoryLbl.fadeTransition(0.7)
            self.MemoryLbl.text = "MEMORY:\n \((memory.used/1024)/1024) mb / \(round((Double(memory.used)/Double(memory.total)) * 100)) %"
            self.sliderLbl.text = "\(self.slideValue)%"
        }
    }
    
    func trackRectForBounds(bounds: CGRect) -> CGRect {
        let rect:CGRect = CGRect(x: 0, y: 0, width: 100, height: 30)
        return rect
    }
    
    @objc func hide() {
        self.isHidden = true
    }
    
    @objc func sliderValueDidChange(_ sender:UISlider!)
    {
        slideValue = round(sender.value / step) * step
        sender.value = slideValue
        Settings.saveObject(value: slideValue, forKey: Config.w3w.currentThreshold)
    }

}

extension PerformanceView {

    @objc func switchValueDidChange(_ sender: UISwitch!) {
        if (sender.isOn == true){
            self.toggleLbl.text = "Turn off 3wa filter"
            Settings.saveBool(value: true, forKey: Config.w3w.current3waFilter)
            
        }
        else{
            self.toggleLbl.text = "Turn on 3wa filter"
            Settings.saveObject(value: false, forKey: Config.w3w.current3waFilter)
        }
    }
}
